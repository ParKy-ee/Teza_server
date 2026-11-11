const { z } = require('zod');
const sharp = require('sharp');
const positive = z.number().int().positive();
const detection = z.object({
  detection_id: z.number().int().nonnegative(), class_id: z.number().int().nonnegative(),
  class_name: z.string().trim().min(1).max(100), confidence: z.number().finite().min(0).max(1),
  bbox_xyxy: z.tuple([z.number().finite(), z.number().finite(), z.number().finite(), z.number().finite()]),
}).strict();
const schema = z.object({
  schema_version: z.literal(2), device_id: z.string().trim().min(1).max(200),
  frame_id: z.number().int().nonnegative(), timestamp: z.string().datetime({ offset: true }),
  image: z.object({ filename: z.string().min(1).max(255), width: positive, height: positive, annotated_width: positive, annotated_height: positive, format: z.literal('jpeg'), encoding: z.literal('base64'), annotated_base64: z.string().min(1) }).strict(),
  summary: z.object({ total_beans: z.number().int().nonnegative(), counts_by_class: z.record(z.number().int().nonnegative()), classes_found: z.array(z.string().min(1).max(100)) }).strict(),
  detections: z.array(detection).max(500),
}).strict().superRefine((event, ctx) => {
  const issue = (path, message) => ctx.addIssue({ code: 'custom', path, message });
  const counts = Object.create(null); const ids = new Set();
  event.detections.forEach((item, i) => {
    if (ids.has(item.detection_id)) issue(['detections', i, 'detection_id'], 'duplicate detection_id');
    ids.add(item.detection_id); counts[item.class_name] = (counts[item.class_name] || 0) + 1;
    const [x1,y1,x2,y2] = item.bbox_xyxy;
    if (x1 < 0 || y1 < 0 || x1 >= x2 || y1 >= y2 || x2 > event.image.width || y2 > event.image.height) issue(['detections', i, 'bbox_xyxy'], 'bbox outside image or invalid');
  });
  if (event.summary.total_beans !== event.detections.length) issue(['summary','total_beans'], 'does not match detections');
  for (const name of new Set([...Object.keys(counts), ...Object.keys(event.summary.counts_by_class)])) if ((counts[name] || 0) !== (event.summary.counts_by_class[name] || 0)) issue(['summary','counts_by_class',name], 'does not match detections');
  const found = event.summary.classes_found;
  if (new Set(found).size !== found.length || found.length !== Object.keys(counts).length || found.some((name) => !counts[name])) issue(['summary','classes_found'], 'does not match detections');
});
async function parseDetections(payload, limits) {
  if (payload.length > limits.messageBytes) throw new Error('message exceeds maximum size');
  let raw; try { raw = JSON.parse(payload.toString('utf8')); } catch { throw new Error('invalid JSON'); }
  const event = schema.parse(raw); const image = event.image; const data = image.annotated_base64;
  if (data.length > Math.ceil(limits.imageBytes / 3) * 4 || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(data)) throw new Error('image.annotated_base64: invalid or oversized base64');
  const bytes = Buffer.from(data, 'base64');
  if (!bytes.length || bytes.length > limits.imageBytes || bytes.toString('base64') !== data || image.annotated_width * image.annotated_height > limits.imagePixels) throw new Error('image.annotated_base64: invalid or oversized image');
  try {
    const pipeline = sharp(bytes, { limitInputPixels: limits.imagePixels, failOn: 'error' });
    const metadata = await pipeline.metadata();
    if (metadata.format !== 'jpeg' || metadata.width !== image.annotated_width || metadata.height !== image.annotated_height) throw new Error('dimensions mismatch');
    await pipeline.raw().toBuffer();
  } catch { throw new Error('image.annotated_base64: invalid JPEG or dimensions'); }
  return event;
}
module.exports = { parseDetections };
