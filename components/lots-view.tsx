"use client";
import { Coffee, Search, Pencil, Trash2, Plus } from "lucide-react";
import type { Lot, Observation } from "./workspace-types";
import { InspectionPreview } from "./inspection-preview";
type Props = { lots: Lot[]; filtered: Lot[]; lot?: Lot; selected: string; query: string; setQuery: (value: string) => void; setSelected: (id: string) => void; editLot: (lot?: Lot) => void; editObs: (observation?: Observation) => void; remove: (kind: "lots" | "observations", id: string) => void };
export function LotsView({ lots, filtered, lot, selected, query, setQuery, setSelected, editLot, editObs, remove }: Props) {
 return <>
                  <div className="two-col">
                    <section>
                      <div className="section-heading compact">
                        <div>
                          <h2>
                            ล็อตทั้งหมด{" "}
                            <span className="count">{lots.length}</span>
                          </h2>
                          <p>เลือกล็อตเพื่อดูรายละเอียด</p>
                        </div>
                      </div>
                      <div className="search">
                        <Search size={17} />
                        <input
                          placeholder="ค้นหาชื่อ รหัส หรือแหล่งปลูก"
                          value={query}
                          onChange={(e) => setQuery(e.target.value)}
                        />
                      </div>
                      <div className="card lot-list">
                        {filtered.length === 0 ? (
                          <div className="empty">ไม่พบล็อต</div>
                        ) : (
                          filtered.map((l) => (
                            <button
                              key={l.id}
                              onClick={() => setSelected(l.id)}
                              className={`lot-row ${selected === l.id ? "selected" : ""}`}
                            >
                              <span className="lot-icon">
                                <Coffee size={18} />
                              </span>
                              <span className="grow">
                                <b>{l.name}</b>
                                <small>
                                  {l.code} · {l.origin || "ไม่ระบุแหล่งปลูก"}
                                </small>
                              </span>
                              <span className="badge">{l.status}</span>
                            </button>
                          ))
                        )}
                      </div>
                    </section>
                    <section>
                      {lot ? (
                        <>
                          <div className="card detail-card">
                            <div className="detail-head">
                              <div>
                                <div className="eyebrow">LOT DETAILS</div>
                                <h2>{lot.name}</h2>
                                <p>{lot.code}</p>
                              </div>
                              <div className="actions">
                                <button
                                  onClick={() => editLot(lot)}
                                  aria-label="แก้ไขล็อต"
                                >
                                  <Pencil size={16} />
                                </button>
                                <button
                                  onClick={() => remove("lots", lot.id)}
                                  aria-label="ลบล็อต"
                                >
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </div>
                            <div className="detail-grid">
                              {[
                                ["แหล่งปลูก", lot.origin],
                                ["สายพันธุ์", lot.variety],
                                ["กระบวนการ", lot.process],
                                [
                                  "น้ำหนัก",
                                  lot.weight === null
                                    ? ""
                                    : `${lot.weight} กก.`,
                                ],
                                ["สถานะ", lot.status],
                                ["หมายเหตุ", lot.notes],
                              ].map(([k, v]) => (
                                <div key={k}>
                                  <small>{k}</small>
                                  <b>{v || "—"}</b>
                                </div>
                              ))}
                            </div>
                          </div>
                          <InspectionPreview key={lot.id} lot={lot} />
                          <div className="section-heading">
                            <div>
                              <h2>รายการตรวจ</h2>
                              <p>ข้อมูลและแหล่งที่มาของล็อตนี้</p>
                            </div>
                            <button
                              className="outline"
                              onClick={() => editObs()}
                            >
                              <Plus size={15} /> เพิ่มรายการ
                            </button>
                          </div>
                          <div className="card list">
                            {lot.observations.length === 0 ? (
                              <div className="empty">ยังไม่มีรายการตรวจ</div>
                            ) : (
                              lot.observations.map((o) => (
                                <div className="observation" key={o.id}>
                                  <div className="grow">
                                    <b>
                                      {o.type} · {o.value} {o.unit}
                                    </b>
                                    <small>
                                      แหล่งที่มา: {o.source || "ไม่ระบุ"}
                                      {o.notes ? ` · ${o.notes}` : ""}
                                    </small>
                                  </div>
                                  <div className="actions">
                                    <button
                                      onClick={() => editObs(o)}
                                      aria-label="แก้ไขรายการตรวจ"
                                    >
                                      <Pencil size={15} />
                                    </button>
                                    <button
                                      onClick={() =>
                                        remove("observations", o.id)
                                      }
                                      aria-label="ลบรายการตรวจ"
                                    >
                                      <Trash2 size={15} />
                                    </button>
                                  </div>
                                </div>
                              ))
                            )}
                          </div>
                        </>
                      ) : (
                        <div className="card empty">
                          เลือกหรือเพิ่มล็อตเพื่อดูรายละเอียด
                        </div>
                      )}
                    </section>
                  </div>

</>;
}
