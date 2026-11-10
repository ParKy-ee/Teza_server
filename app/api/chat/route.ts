import { db } from "@/lib/db";
import { NextResponse } from "next/server";
import { z } from "zod";
const schema = z.object({
  lotId: z.string().min(1),
  messages: z
    .array(
      z.object({
        role: z.enum(["user", "assistant"]),
        content: z.string().min(1).max(4000),
      }),
    )
    .min(1)
    .max(20),
});
export async function POST(req: Request) {
  try {
    const { lotId, messages } = schema.parse(await req.json());
    const lot = await db.lot.findUnique({
      where: { id: lotId },
      include: { observations: true },
    });
    if (!lot) return NextResponse.json({ error: "ไม่พบล็อต" }, { status: 404 });
    const response = await fetch(
      `${(process.env.OLLAMA_URL || "http://127.0.0.1:11434").replace(/\/$/, "")}/api/chat`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          model: process.env.OLLAMA_MODEL || "qwen3.5:2b-q4_K_M",
          stream: false,
          think: false,
          messages: [
            {
              role: "system",
              content: `คุณเป็นผู้ช่วยวิเคราะห์ข้อมูลกาแฟ ตอบภาษาไทยโดยอิงข้อมูลล็อตที่ให้เท่านั้น ระบุข้อมูลที่ขาด ไม่แต่งผลตรวจ เกรด หรือราคาตลาด และไม่อ้างว่ามีข้อมูลตลาดสด ข้อมูลล็อต: ${JSON.stringify(lot)}`,
            },
            ...messages.slice(-12),
          ],
        }),
        signal: AbortSignal.timeout(240000),
      },
    );
    if (!response.ok) throw new Error(`Ollama ตอบกลับ ${response.status}`);
    const result = await response.json();
    if (!result.message?.content)
      throw new Error("Ollama ไม่ส่งข้อความตอบกลับ");
    return NextResponse.json({
      content: result.message.content,
      model: result.model,
    });
  } catch (e) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "เชื่อมต่อ Ollama ไม่ได้" },
      { status: 502 },
    );
  }
}
