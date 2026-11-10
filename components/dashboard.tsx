"use client";
import { Coffee, ClipboardList, Database, ArrowUpRight } from "lucide-react";
import type { Lot, View } from "./workspace-types";
type Props = { lots: Lot[]; setSelected: (id: string) => void; setView: (view: View) => void; editLot: () => void };
export function Dashboard({ lots, setSelected, setView, editLot }: Props) {
 const totalObs = lots.reduce((n, l) => n + l.observations.length, 0);
 return <>
                  <div className="stats">
                    <div className="card stat">
                      <div>
                        <span>ล็อตทั้งหมด</span>
                        <Coffee size={18} />
                      </div>
                      <strong>{lots.length}</strong>
                      <small>ล็อตในระบบ</small>
                    </div>
                    <div className="card stat">
                      <div>
                        <span>รายการตรวจ</span>
                        <ClipboardList size={18} />
                      </div>
                      <strong>{totalObs}</strong>
                      <small>รายการที่บันทึกแล้ว</small>
                    </div>
                    <div className="card stat">
                      <div>
                        <span>น้ำหนักรวม</span>
                        <Database size={18} />
                      </div>
                      <strong>
                        {lots
                          .reduce((n, l) => n + (l.weight || 0), 0)
                          .toLocaleString()}{" "}
                        <em>กก.</em>
                      </strong>
                      <small>จากล็อตที่ระบุน้ำหนัก</small>
                    </div>
                  </div>
                  <div className="section-heading">
                    <div>
                      <h2>จำนวนล็อตตามสถานะ</h2>
                      <p>คำนวณจากล็อตที่บันทึกในฐานข้อมูล · เลือกสถานะเพื่อดูล็อตแรก</p>
                    </div>
                  </div>
                  <div className="card status-chart" aria-label="กราฟจำนวนล็อตตามสถานะ">
                    {Array.from(new Set(["กำลังตรวจ", "พร้อมขาย", "พักล็อต", ...lots.map((item) => item.status)])).map((status) => {
                      const count = lots.filter((item) => item.status === status).length;
                      return (
                        <button className="chart-row" key={status} onClick={() => {
                          const first = lots.find((item) => item.status === status);
                          if (first) { setSelected(first.id); setView("lots"); }
                        }} disabled={count === 0} aria-label={`${status} ${count} ล็อต${count ? " ดูล็อตแรก" : ""}`}>
                          <span>{status}</span>
                          <span className="chart-track"><span className="chart-bar" style={{ width: `${lots.length ? count / lots.length * 100 : 0}%` }} /></span>
                          <strong>{count}</strong>
                        </button>
                      );
                    })}
                  </div>
                  <div className="section-heading">
                    <div>
                      <h2>ล็อตล่าสุด</h2>
                      <p>ข้อมูลล็อตและแหล่งปลูกที่บันทึกไว้</p>
                    </div>
                    <button
                      className="text-button"
                      onClick={() => setView("lots")}
                    >
                      ดูทั้งหมด <ArrowUpRight size={16} />
                    </button>
                  </div>
                  <div className="card list">
                    {lots.length === 0 ? (
                      <div className="empty">
                        <Coffee />
                        <h3>ยังไม่มีล็อตกาแฟ</h3>
                        <p>เริ่มต้นด้วยการเพิ่มล็อตแรกของคุณ</p>
                        <button className="outline" onClick={() => editLot()}>
                          เพิ่มล็อต
                        </button>
                      </div>
                    ) : (
                      lots.slice(0, 5).map((l) => (
                        <button
                          className="list-row"
                          key={l.id}
                          onClick={() => {
                            setSelected(l.id);
                            setView("lots");
                          }}
                        >
                          <span className="lot-icon">
                            <Coffee size={18} />
                          </span>
                          <span className="grow">
                            <b>{l.name}</b>
                            <small>
                              {l.code} · {l.origin || "ยังไม่ระบุแหล่งปลูก"}
                            </small>
                          </span>
                          <span className="badge">{l.status}</span>
                          <ArrowUpRight size={16} />
                        </button>
                      ))
                    )}
                  </div>
                  <div className="info-banner">
                    <span>✳</span>
                    <div>
                      <b>ข้อมูลที่ดี เริ่มจากการบันทึกที่ชัดเจน</b>
                      <p>
                        เพิ่มผลตรวจและแหล่งที่มา
                        เพื่อให้วิเคราะห์ล็อตได้แม่นยำขึ้น
                      </p>
                    </div>
                  </div>

</>;
}
