import { db } from "@/lib/db";
import { observationSchema } from "@/lib/validation";
import { NextResponse } from "next/server";
export async function PUT(
  req: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { id } = await params;
    return NextResponse.json(
      await db.observation.update({
        where: { id },
        data: observationSchema.parse(await req.json()),
      }),
    );
  } catch (e) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "แก้ไขไม่สำเร็จ" },
      { status: 400 },
    );
  }
}
export async function DELETE(
  _req: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { id } = await params;
    await db.observation.delete({ where: { id } });
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ error: "ลบไม่สำเร็จ" }, { status: 400 });
  }
}
