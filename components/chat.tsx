"use client";
import { useState, type FormEvent } from "react";
import { MessageCircle, Send } from "lucide-react";
import type { Lot } from "./workspace-types";

type Message = { role: "user" | "assistant"; content: string };
export function Chat({ lot }: { lot: Lot }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");
  async function send(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const content = input.trim();
    if (!content || pending) return;
    const next: Message[] = [...messages, { role: "user" as const, content }].slice(-20);
    setMessages(next); setInput(""); setError(""); setPending(true);
    try {
      const response = await fetch("/api/chat", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ lotId: lot.id, messages: next }) });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || "เชื่อมต่อ AI ไม่ได้");
      setMessages((previous) => [...previous, { role: "assistant", content: data.content }]);
    } catch (cause) { setError(cause instanceof Error ? cause.message : "ส่งข้อความไม่สำเร็จ"); }
    finally { setPending(false); }
  }
  return <div className="chat-root">
    <div className="chat-intro"><div className="iconbox"><MessageCircle size={19}/></div><div><b>ผู้ช่วยวิเคราะห์ล็อต</b><p>ถามเกี่ยวกับ {lot.code} จากข้อมูลที่บันทึกไว้</p></div><span className="badge">OLLAMA</span></div>
    <div className="messages" aria-live="polite">
      {messages.length === 0 && <div className="welcome"><span>✳</span><h3>สวัสดีครับ มีอะไรให้ช่วย</h3><p>ลองถามเกี่ยวกับคุณภาพ ข้อมูลที่ยังขาด ข้อควรตรวจสอบของล็อตนี้</p></div>}
      {messages.map((message, index) => <div className={`message ${message.role === "user" ? "user" : "assistant"}`} key={index}>{message.content}</div>)}
      {pending && <div className="message assistant">กำลังประมวลผล...</div>}
      {error && <div className="alert" role="alert">{error} · ตรวจสอบ Ollama และโมเดล</div>}
    </div>
    <form className="composer" onSubmit={send}><textarea value={input} onChange={(event) => setInput(event.target.value)} placeholder="ถามเกี่ยวกับล็อตนี้..." aria-label="ข้อความถึง AI" onKeyDown={(event) => { if (event.key === "Enter" && !event.shiftKey && !event.nativeEvent.isComposing) { event.preventDefault(); event.currentTarget.form?.requestSubmit(); } }}/><button className="send" type="submit" disabled={pending || !input.trim()} aria-label="ส่งข้อความ"><Send size={17}/></button></form>
    <p className="footnote">AI ใช้ข้อมูลล็อตที่บันทึกไว้ ควรตรวจสอบคำตอบก่อนนำไปใช้</p>
  </div>;
}
