const { z } = require('zod');
const sharp = require('sharp');

const classes = ['good', 'shell', 'full_black', 'hull_husk', 'broken_chipped_cut', 'parchment', 'immature_unripe'];
const identifier = z.string().min(1).max(200);
const timestamp = z.string().datetime({ offset: true });
const positiveInt = z.number().int().positive();
const count = z.number().int().nonnegative();
const counts = z.object(Object.fromEntries(classes.map((name) => [name, count]))).strict();
const bbox = z.object({ format: z.literal('xyxy'), unit: z.literal('px'), coordinates: z.tuple([count, count, count, count]) }).strict();
const size = z.object({ length: z.number().positive().finite(), width: z.number().positive().finite(), unit: z.literal('mm'), method: identifier, calibration_id: identifier }).strict();
const crop = z.object({ mime_type: z.literal('image/jpeg'), encoding: z.literal('base64'), width: positiveInt, height: positiveInt, data: z.string().min(1) }).strict();
const detection = z.object({ detection_id: identifier, class_name: z.enum(classes), status: z.enum(['normal', 'defect']), confidence: z.number().finite().min(0).max(1), crop_image: crop, bbox: bbox.optional(), size: size.nullable(), track_id: identifier.nullable().optional(), model_class_id: count.optional() }).strict();
const moisture = z.object({ value: z.number().finite().min(0).max(100).nullable(), unit: z.literal('percent'), kind: z.enum(['bean_moisture', 'ambient_relative_humidity']), sensor_id: identifier, measured_at: timestamp, status: z.enum(['ok', 'error', 'stale']) }).strict();
const schema = z.object({ schema_version: z.literal('2.0'), event_id: identifier, device_id: identifier, batch_id: identifier, captured_at: timestamp, model_version: identifier, class_map_version: identifier, count_scope: z.literal('frame'), source_image: z.object({ width: positiveInt, height: positiveInt }).strict().optional(), moisture: moisture.nullable(), summary: z.object({ total_count: count, normal_count: count, defect_count: count, counts_by_class: counts }).strict(), detections: z.array(detection).max(500) }).strict().superRefine((event, ctx) => {
  const add = (path, message) => ctx.addIssue({ code: 'custom', path, message });
  const seen = new Set(); const actual = Object.fromEntries(classes.map((name) => [name, 0]));
  event.detections.forEach((item, index) => {
    if (seen.has(item.detection_id)) add(['detections', index, 'detection_id'], 'duplicate detection_id');
    seen.add(item.detection_id); actual[item.class_name]++;
    if (item.status !== (item.class_name === 'good' ? 'normal' : 'defect')) add(['detections', index, 'status'], 'status does not match class');
    if (item.bbox) {
      const [x1, y1, x2, y2] = item.bbox.coordinates;
      if (!event.source_image || x1 >= x2 || y1 >= y2 || x2 > event.source_image.width || y2 > event.source_image.height) add(['detections', index, 'bbox'], 'invalid bbox or missing source_image');
    }
  });
  for (const name of classes) if (event.summary.counts_by_class[name] !== actual[name]) add(['summary', 'counts_by_class', name], 'does not match detections');
  if (event.summary.total_count !== event.detections.length || event.summary.normal_count !== actual.good || event.summary.defect_count !== event.detections.length - actual.good) add(['summary'], 'counts do not match detections');
  if (event.moisture && ((event.moisture.status === 'ok') !== (event.moisture.value !== null))) add(['moisture', 'value'], 'ok requires a value; error/stale requires null');
});

async function parseEvent(buffer, limits) {
  if (buffer.length > limits.messageBytes) throw new Error('message exceeds maximum size');
  let value; try { value = JSON.parse(buffer.toString('utf8')); } catch { throw new Error('invalid JSON'); }
  const event = schema.parse(value);
  for (const [index, item] of event.detections.entries()) {
    const image = item.crop_image; const data = image.data;
    if (data.length > Math.ceil(limits.imageBytes / 3) * 4 || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(data)) throw new Error(`detections[${index}].crop_image.data: invalid or oversized base64`);
    const bytes = Buffer.from(data, 'base64');
    if (!bytes.length || bytes.length > limits.imageBytes || bytes.toString('base64') !== data) throw new Error(`detections[${index}].crop_image.data: invalid base64`);
    if (image.width * image.height > limits.imagePixels) throw new Error(`detections[${index}].crop_image: too many pixels`);
    try {
      const pipeline = sharp(bytes, { limitInputPixels: limits.imagePixels, failOn: 'error' });
      const metadata = await pipeline.metadata();
      if (metadata.format !== 'jpeg' || metadata.width !== image.width || metadata.height !== image.height) throw new Error('format or dimensions mismatch');
      await pipeline.raw().toBuffer();
    } catch { throw new Error(`detections[${index}].crop_image: invalid JPEG or dimensions`); }
  }
  return event;
}
module.exports = { classes, schema, parseEvent };
