import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params;
    const image = await db.lotImage.findUnique({ where: { id }, select: { jpegBase64: true } });
    if (!image) return NextResponse.json({ error: "ไม่พบภาพ" }, { status: 404 });
    return new Response(new Uint8Array(Buffer.from(image.jpegBase64, "base64")), { headers: { "Content-Type": "image/jpeg", "Cache-Control": "private, no-store", "X-Content-Type-Options": "nosniff" } });
  } catch {
    return NextResponse.json({ error: "โหลดภาพไม่สำเร็จ" }, { status: 503 });
  }
}
