// Keep image bytes and other unrecognized payload fields out of logs.
function visionLog(event, packet) {
  return {
    type: 'coffee_vision', outcome: 'validated_not_saved',
    receivedAt: new Date().toISOString(), topic: packet.topic,
    qos: packet.qos, retained: Boolean(packet.retain), payloadBytes: packet.payload.length,
    eventId: event.event_id, deviceId: event.device_id, batchId: event.batch_id,
    capturedAt: event.captured_at, summary: event.summary, moisture: event.moisture,
    detections: event.detections.map((item) => ({
      detectionId: item.detection_id, className: item.class_name, status: item.status,
      confidence: item.confidence, bbox: item.bbox ?? null, size: item.size,
      crop: { mimeType: item.crop_image.mime_type, width: item.crop_image.width, height: item.crop_image.height },
    })),
  };
}
module.exports = { visionLog };
