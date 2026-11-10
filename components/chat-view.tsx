"use client";
import { Chat } from "./chat";
import type { Lot } from "./workspace-types";
type Props = { lots: Lot[]; lot?: Lot; selected: string; setSelected: (id: string) => void };
export function ChatView({ lots, lot, selected, setSelected }: Props) {
 return <>
                  <div className="chat-select">
                    <label htmlFor="lotselect">เลือกล็อตสำหรับสนทนา</label>
                    <select
                      id="lotselect"
                      value={selected}
                      onChange={(e) => setSelected(e.target.value)}
                    >
                      <option value="">เลือกล็อต</option>
                      {lots.map((l) => (
                        <option key={l.id} value={l.id}>
                          {l.code} · {l.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="card chat-card">
                    {lot ? (
                      <Chat key={lot.id} lot={lot} />
                    ) : (
                      <div className="empty">เพิ่มล็อตก่อนเริ่มสนทนา</div>
                    )}
                  </div>

</>;
}
