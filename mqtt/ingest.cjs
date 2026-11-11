const { parseEvent } = require('./contract.cjs');

/**
 * Resolve payload batch_id as Lot.code, then persist the validated event.
 * No source image is present in v2: crop images are not source-frame images.
 * The caller must handle event-id conflicts and application acknowledgement.
 */
async function ingestEvent(prisma, payload, limits) {
  const event = await parseEvent(payload, limits);
  return prisma.$transaction(async (tx) => {
    const lot = await tx.lot.findUnique({ where: { code: event.batch_id }, select: { id: true } });
    if (!lot) throw new Error(`No lot found for batch_id: ${event.batch_id}`);
    const lotId = lot.id;
    const record = await tx.detectionEvent.create({ data: {
      eventId: event.event_id, deviceId: event.device_id, batchId: event.batch_id,
      lotId, createdAt: new Date(event.captured_at), totalCount: event.summary.total_count,
      normalCount: event.summary.normal_count, defectCount: event.summary.defect_count,
      countsByClass: event.summary.counts_by_class,
    } });
    for (const item of event.detections) {
      const crop = await tx.lotImage.create({ data: {
        lotId, detectionEventId: record.id, imageType: 'crop', jpegBase64: item.crop_image.data,
      } });
      const coordinates = item.bbox?.coordinates;
      await tx.detection.create({ data: {
        cropImageId: crop.id, detectionId: item.detection_id, className: item.class_name,
        status: item.status, confidence: item.confidence,
        bboxX1: coordinates?.[0], bboxY1: coordinates?.[1], bboxX2: coordinates?.[2], bboxY2: coordinates?.[3],
        lengthMm: item.size?.length, widthMm: item.size?.width,
      } });
    }
    return { eventId: record.eventId, detectionCount: event.detections.length };
  });
}
module.exports = { ingestEvent };
