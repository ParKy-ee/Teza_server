import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params;
    const images = await db.lotImage.findMany({
      where: { lotId: id },
      orderBy: { createdAt: "desc" },
      select: {
        id: true, imageType: true, createdAt: true,
        detectionEvent: { select: { eventId: true, deviceId: true, batchId: true, createdAt: true } },
        cropDetection: { select: { id: true, detectionId: true, className: true, confidence: true, bboxX1: true, bboxY1: true, bboxX2: true, bboxY2: true, imageId: true } },
        detections: { select: { id: true, detectionId: true, className: true, confidence: true, bboxX1: true, bboxY1: true, bboxX2: true, bboxY2: true, cropImageId: true } },
      },
    });
    return NextResponse.json(images.map((image) => ({ ...image, imageUrl: `/api/images/${image.id}` })));
  } catch {
    return NextResponse.json({ error: "โหลดภาพไม่สำเร็จ ตรวจสอบฐานข้อมูลและ migration" }, { status: 503 });
  }
}
