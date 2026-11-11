const test = require('node:test');
const assert = require('node:assert/strict');
const sharp = require('sharp');
const { classes, parseEvent } = require('./contract.cjs');
const { ingestEvent } = require('./ingest.cjs');
const { visionLog } = require('./logging.cjs');
const limits = { messageBytes: 1024 * 1024, imageBytes: 100_000, imagePixels: 100_000 };
async function sample() {
  const data = (await sharp({ create: { width: 4, height: 3, channels: 3, background: '#61865a' } }).jpeg().toBuffer()).toString('base64');
  return { schema_version: '2.0', event_id: 'event-1', device_id: 'pi-1', batch_id: 'batch-1', captured_at: '2026-11-10T14:30:00+07:00', model_version: 'v1', class_map_version: 'v1', count_scope: 'frame', moisture: null, summary: { total_count: 1, normal_count: 1, defect_count: 0, counts_by_class: Object.fromEntries(classes.map((key) => [key, key === 'good' ? 1 : 0])) }, detections: [{ detection_id: 'det-1', class_name: 'good', status: 'normal', confidence: 0.9, size: null, crop_image: { mime_type: 'image/jpeg', encoding: 'base64', width: 4, height: 3, data } }] };
}
const parse = (event) => parseEvent(Buffer.from(JSON.stringify(event)), limits);
test('accepts a valid JPEG event and a zero-detection event', async () => {
  const event = await sample(); assert.equal((await parse(event)).event_id, 'event-1');
  event.detections = []; event.summary.total_count = 0; event.summary.normal_count = 0; event.summary.counts_by_class.good = 0; await parse(event);
});
test('rejects mismatched summary, class status, invalid base64 and image dimensions', async () => {
  const event = await sample(); event.summary.total_count = 2; await assert.rejects(parse(event));
  event.summary.total_count = 1; event.detections[0].status = 'defect'; await assert.rejects(parse(event));
  event.detections[0].status = 'normal'; event.detections[0].crop_image.data = 'data:image/jpeg;base64,AAAA'; await assert.rejects(parse(event));
  const fresh = await sample(); fresh.detections[0].crop_image.width = 5; await assert.rejects(parse(fresh));
});
test('rejects invalid bbox and oversized message', async () => {
  const event = await sample(); event.detections[0].bbox = { format: 'xyxy', unit: 'px', coordinates: [0, 0, 1, 1] }; await assert.rejects(parse(event));
  await assert.rejects(parseEvent(Buffer.alloc(50), { ...limits, messageBytes: 1 }));
});
test('maps batch_id to the lot code and saves validated Base64 and detection', async () => {
  const event = await sample(); const saved = {};
  const tx = {
    lot: { findUnique: async (query) => { assert.deepEqual(query.where, { code: 'batch-1' }); return { id: 'lot-1' }; } },
    detectionEvent: { create: async ({ data }) => { saved.event = data; return { id: 'db-event', eventId: data.eventId }; } },
    lotImage: { create: async ({ data }) => { saved.image = data; return { id: 'crop-1' }; } },
    detection: { create: async ({ data }) => { saved.detection = data; } },
  };
  const prisma = { $transaction: async (callback) => callback(tx) };
  await ingestEvent(prisma, Buffer.from(JSON.stringify(event)), limits);
  assert.equal(saved.image.lotId, 'lot-1');
  assert.equal(saved.image.detectionEventId, 'db-event');
  assert.equal(saved.image.jpegBase64, event.detections[0].crop_image.data);
  assert.deepEqual(Buffer.from(saved.image.jpegBase64, 'base64'), Buffer.from(event.detections[0].crop_image.data, 'base64'));
  assert.equal(saved.detection.cropImageId, 'crop-1');
  assert.equal(saved.detection.imageId, undefined);
  assert.equal(saved.event.createdAt.toISOString(), '2026-11-10T07:30:00.000Z');
});
test('rejects an unknown batch without creating any event or image', async () => {
  const event = await sample(); let writes = 0;
  const tx = { lot: { findUnique: async () => null }, detectionEvent: { create: async () => { writes++; } }, lotImage: { create: async () => { writes++; } } };
  await assert.rejects(ingestEvent({ $transaction: async (callback) => callback(tx) }, Buffer.from(JSON.stringify(event)), limits), /No lot found for batch_id: batch-1/);
  assert.equal(writes, 0);
});
test('vision log contains detection details but never the Base64 image', async () => {
  const event = await sample();
  const entry = visionLog(event, { topic: 'coffee/vision/v2/events', qos: 1, retain: false, payload: Buffer.from('test') });
  assert.equal(entry.detections[0].className, 'good');
  assert.equal(entry.outcome, 'validated_not_saved');
  assert.equal(JSON.stringify(entry).includes(event.detections[0].crop_image.data), false);
});
