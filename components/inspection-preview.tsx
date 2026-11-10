"use client";

import { useState } from "react";
import { Camera, ScanLine, Scale, Info } from "lucide-react";
import type { Lot } from "./workspace-types";

const results = [
  { id: "good", name: "เมล็ดดี", english: "Good", count: 78, color: "#568d62" },
  { id: "shell", name: "เมล็ดหูช้าง", english: "Shell", count: 4, color: "#d1a15c" },
  { id: "full_black", name: "เมล็ดดำ", english: "Full Black", count: 3, color: "#6f7771" },
  { id: "hull_husk", name: "เศษกะลา / เปลือกเชอร์รี่แห้ง", english: "Hull / Husk", count: 2, color: "#b98863" },
  { id: "broken", name: "เมล็ดแตกหัก", english: "Broken / Chipped / Cut", count: 5, color: "#cf885c" },
  { id: "parchment", name: "เมล็ดกะลา", english: "Parchment / Pergamino", count: 3, color: "#b7a265" },
  { id: "immature", name: "เมล็ดดิบ / อ่อน", english: "Immature / Unripe", count: 5, color: "#9ba868" },
];
const total = results.reduce((sum, item) => sum + item.count, 0);
const defects = total - results[0].count;

export function InspectionPreview({ lot }: { lot: Lot }) {
  const [selected, setSelected] = useState("all");
  const active = results.find((item) => item.id === selected);
  if (!lot.code.startsWith("DEMO-LOT-")) return (
    <section className="inspection-empty card">
      <ScanLine size={20} /><div><b>ยังไม่มีชุดตรวจจากอุปกรณ์</b><p>เมื่อเชื่อมระบบรับผลตรวจแล้ว ภาพและผลตรวจของล็อตนี้จะแสดงที่นี่</p></div>
    </section>
  );
  return (
    <section className="inspection-section">
      <div className="section-heading"><div><h2>ผลตรวจจากภาพ</h2><p>ตัวอย่างหน้าจอชุดตรวจจาก Edge AI</p></div><span className="sample-badge">ข้อมูลจำลอง</span></div>
      <div className="card inspection-card">
        <div className="inspection-meta"><div><span className="eyebrow">INSPECTION PREVIEW</span><h3>ชุดตรวจตัวอย่าง · {lot.code}</h3><p>Raspberry Pi · โมเดลตัวอย่าง · รอตรวจสอบ</p></div><span className="sample-badge">ยังไม่เชื่อมอุปกรณ์</span></div>
        <div className="inspection-metrics">
          <div><small>น้ำหนักตัวอย่างที่ชั่ง</small><strong>350 <em>กรัม</em></strong><span>ตัวอย่างจากเครื่องชั่งจำลอง</span></div>
          <div><small>วัตถุที่ตรวจพบทั้งหมด</small><strong>{total} <em>รายการ</em></strong><span>จำนวนคาดการณ์จากภาพ</span></div>
          <div><small>พบข้อบกพร่อง</small><strong>{defects} <em>รายการ · {(defects / total * 100).toFixed(1)}%</em></strong><span>รวม 6 คลาสที่ไม่ใช่ Good</span></div>
        </div>
        <div className="inspection-content">
          <div><div className="inspection-subhead"><b>ภาพจากชุดตรวจ</b><span>ตัวอย่างตำแหน่งแสดงภาพ</span></div><div className="image-placeholder"><Camera size={28}/><b>ภาพต้นฉบับและภาพผลตรวจ</b><span>รอเชื่อมไฟล์ภาพจากอุปกรณ์</span></div><div className="image-caption"><ScanLine size={14}/> {active ? `เลือกคลาส ${active.english} · ${active.count} รายการ` : "เลือกคลาสเพื่อดูจำนวนในชุดตรวจ"}</div></div>
          <div><div className="inspection-subhead"><b>ผลจำแนก 7 คลาส</b><button className="text-button" onClick={() => setSelected("all")}>ดูทั้งหมด</button></div><div className="class-list">{results.map((item) => <button type="button" key={item.id} className={`class-row ${selected === item.id ? "class-active" : ""}`} onClick={() => setSelected(item.id)}><span className="class-dot" style={{background:item.color}}/><span className="class-name"><b>{item.name}</b><small>{item.english}</small></span><span className="class-count"><b>{item.count}</b><small>{(item.count / total * 100).toFixed(1)}%</small></span></button>)}</div></div>
        </div>
        <div className="inspection-note"><Info size={16}/><span>เปอร์เซ็นต์ = จำนวนวัตถุในคลาส ÷ จำนวนวัตถุที่ตรวจพบทั้งหมด × 100 รวม Good และ Hull / Husk โดยถือว่าแต่ละวัตถุถูกนับเพียงครั้งเดียว ตัวเลขเป็นค่าคาดการณ์จากภาพ ไม่ใช่ร้อยละโดยน้ำหนักหรือเกรดที่ยืนยันแล้ว</span></div>
        <div className="inspection-weight"><Scale size={15}/> น้ำหนักแยกตามคลาส: ยังไม่มีข้อมูลที่ชั่งแยก จึงไม่คำนวณจากจำนวนเมล็ด</div>
      </div>
    </section>
  );
}
