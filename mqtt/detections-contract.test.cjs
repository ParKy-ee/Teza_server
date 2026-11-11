const test = require('node:test');
const assert = require('node:assert/strict');
const sharp = require('sharp');
const { parseDetections } = require('./detections-contract.cjs');
const limits = { messageBytes: 1_000_000, imageBytes: 100_000, imagePixels: 100_000 };
async function sample() {
  const image = await sharp({ create: { width: 8, height: 8, channels: 3, background: '#abcdef' } }).jpeg().toBuffer();
  return { schema_version: 2, device_id: 'coffee-pi5', frame_id: 4, timestamp: '2026-11-11T09:42:07.572550+00:00', image: { filename: 'frame.jpg', width: 8, height: 8, annotated_width: 8, annotated_height: 8, format: 'jpeg', encoding: 'base64', annotated_base64: image.toString('base64') }, summary: { total_beans: 1, counts_by_class: { borer: 1 }, classes_found: ['borer'] }, detections: [{ detection_id: 1, class_id: 1, class_name: 'borer', confidence: 0.875, bbox_xyxy: [1.1, 2.2, 5.5, 6.6] }] };
}
const parse = (data) => parseDetections(Buffer.from(JSON.stringify(data)), limits);
test('accepts numerical version, borer and fractional bbox with a real JPEG', async () => { const event = await parse(await sample()); assert.deepEqual(event.detections[0].bbox_xyxy, [1.1, 2.2, 5.5, 6.6]); });
test('rejects placeholders, inconsistent counts, and invalid bounds', async () => {
  let event = await sample(); event.image.annotated_base64 = '<Base64 image: 29264 characters>'; await assert.rejects(parse(event));
  event = await sample(); event.summary.total_beans = 9; await assert.rejects(parse(event));
  event = await sample(); event.detections[0].bbox_xyxy[2] = 9; await assert.rejects(parse(event));
});
