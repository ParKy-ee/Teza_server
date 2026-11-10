"use client";
import type { Dispatch, FormEvent, SetStateAction } from "react";
import { X } from "lucide-react";
import type { LotForm, ObservationForm } from "./workspace-types";
type Props = { modal: "lot" | "observation"; editing: string; busy: boolean; form: LotForm; obs: ObservationForm; setForm: Dispatch<SetStateAction<LotForm>>; setObs: Dispatch<SetStateAction<ObservationForm>>; setModal: Dispatch<SetStateAction<"lot" | "observation" | null>>; save: (event: FormEvent) => void };
export function EditDialog({ modal, editing, busy, form, obs, setForm, setObs, setModal, save }: Props) {
 return (
        <div className="overlay" onClick={() => setModal(null)}>
          <form
            className="dialog"
            onSubmit={save}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="detail-head">
              <div>
                <div className="eyebrow">
                  {modal === "lot" ? "LOT DETAILS" : "OBSERVATION"}
                </div>
                <h2>
                  {editing ? "แก้ไข" : "เพิ่ม"}
                  {modal === "lot" ? "ล็อตกาแฟ" : "รายการตรวจ"}
                </h2>
              </div>
              <button
                type="button"
                className="close"
                onClick={() => setModal(null)}
                aria-label="ปิด"
              >
                <X size={19} />
              </button>
            </div>
            {modal === "lot" ? (
              <div className="form-grid">
                {[
                  ["code", "รหัสล็อต *"],
                  ["name", "ชื่อล็อต *"],
                  ["origin", "แหล่งปลูก"],
                  ["variety", "สายพันธุ์"],
                  ["process", "กระบวนการ"],
                  ["weight", "น้ำหนัก (กก.)"],
                ].map(([key, label]) => (
                  <label key={key}>
                    {label}
                    <input
                      required={key === "code" || key === "name"}
                      type={key === "weight" ? "number" : "text"}
                      min={key === "weight" ? "0.01" : undefined}
                      step={key === "weight" ? "any" : undefined}
                      value={form[key as keyof LotForm]}
                      onChange={(e) =>
                        setForm({ ...form, [key]: e.target.value })
                      }
                    />
                  </label>
                ))}
                <label>
                  สถานะ
                  <select
                    value={form.status}
                    onChange={(e) =>
                      setForm({ ...form, status: e.target.value })
                    }
                  >
                    <option>กำลังตรวจ</option>
                    <option>พร้อมขาย</option>
                    <option>พักล็อต</option>
                  </select>
                </label>
                <label className="wide">
                  หมายเหตุ
                  <textarea
                    value={form.notes}
                    onChange={(e) =>
                      setForm({ ...form, notes: e.target.value })
                    }
                  />
                </label>
              </div>
            ) : (
              <div className="form-grid">
                {[
                  ["type", "ประเภทการตรวจ *"],
                  ["value", "ผลที่บันทึก *"],
                  ["unit", "หน่วย"],
                  ["source", "แหล่งที่มา"],
                ].map(([key, label]) => (
                  <label key={key}>
                    {label}
                    <input
                      required={key === "type" || key === "value"}
                      value={obs[key as keyof ObservationForm]}
                      onChange={(e) =>
                        setObs({ ...obs, [key]: e.target.value })
                      }
                    />
                  </label>
                ))}
                <label className="wide">
                  หมายเหตุ
                  <textarea
                    value={obs.notes}
                    onChange={(e) => setObs({ ...obs, notes: e.target.value })}
                  />
                </label>
              </div>
            )}
            <div className="dialog-actions">
              <button
                type="button"
                className="outline"
                onClick={() => setModal(null)}
              >
                ยกเลิก
              </button>
              <button className="primary" disabled={busy}>
                {busy ? "กำลังบันทึก..." : "บันทึก"}
              </button>
            </div>
          </form>
        </div>
 );
}
