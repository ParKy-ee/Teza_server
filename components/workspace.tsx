"use client";
import { useCallback, useEffect, useState } from "react";
import { LayoutDashboard, Coffee, MessageCircle, Plus, Leaf, X } from "lucide-react";
import { Dashboard } from "./dashboard";
import { LotsView } from "./lots-view";
import { ChatView } from "./chat-view";
import { EditDialog } from "./edit-dialog";
import { blank, blankObservation, type Lot, type Observation, type View } from "./workspace-types";

async function call(url: string, method: string, body?: unknown) {
  const res = await fetch(url, {
    method,
    headers: { "Content-Type": "application/json" },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || "เกิดข้อผิดพลาด");
  return data;
}
export default function Workspace() {
  const [lots, setLots] = useState<Lot[]>([]);
  const [view, setView] = useState<View>("dashboard");
  const [selected, setSelected] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [modal, setModal] = useState<"lot" | "observation" | null>(null);
  const [editing, setEditing] = useState("");
  const [form, setForm] = useState(blank);
  const [obs, setObs] = useState(blankObservation);
  const [busy, setBusy] = useState(false);
  const refresh = useCallback(async () => {
    try {
      const data: Lot[] = await call("/api/lots", "GET");
      setLots(data);
      setSelected((s) =>
        data.some((l) => l.id === s) ? s : data[0]?.id || "",
      );
      setError("");
    } catch (e) {
      setError(e instanceof Error ? e.message : "โหลดข้อมูลไม่ได้");
    } finally {
      setLoading(false);
    }
  }, []);
  useEffect(() => {
    refresh();
  }, [refresh]);
  const lot = lots.find((l) => l.id === selected);
  function editLot(l?: Lot) {
    setEditing(l?.id || "");
    setForm(
      l
        ? {
            code: l.code,
            name: l.name,
            origin: l.origin,
            variety: l.variety,
            process: l.process,
            status: l.status,
            weight: l.weight?.toString() || "",
            notes: l.notes,
          }
        : blank,
    );
    setModal("lot");
  }
  function editObs(o?: Observation) {
    setEditing(o?.id || "");
    setObs(
      o
        ? {
            type: o.type,
            value: o.value,
            unit: o.unit,
            source: o.source,
            notes: o.notes,
          }
        : blankObservation,
    );
    setModal("observation");
  }
  async function save(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    try {
      if (modal === "lot") {
        const data = {
          ...form,
          weight: form.weight ? Number(form.weight) : null,
        };
        await call(
          editing ? `/api/lots/${editing}` : "/api/lots",
          editing ? "PUT" : "POST",
          data,
        );
      } else {
        await call(
          editing ? `/api/observations/${editing}` : "/api/observations",
          editing ? "PUT" : "POST",
          { ...obs, lotId: selected },
        );
      }
      setModal(null);
      await refresh();
    } catch (e) {
      setError(e instanceof Error ? e.message : "บันทึกไม่สำเร็จ");
    } finally {
      setBusy(false);
    }
  }
  async function remove(kind: "lots" | "observations", id: string) {
    if (
      !confirm(
        kind === "lots"
          ? "ลบล็อตและรายการตรวจทั้งหมดของล็อตนี้"
          : "ลบรายการตรวจนี้",
      )
    )
      return;
    try {
      await call(`/api/${kind}/${id}`, "DELETE");
      await refresh();
    } catch (e) {
      setError(e instanceof Error ? e.message : "ลบไม่สำเร็จ");
    }
  }
  const filtered = lots.filter((l) =>
    `${l.code} ${l.name} ${l.origin}`
      .toLowerCase()
      .includes(query.toLowerCase()),
  );
  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">
          <span>✳</span>
          <div>
            TEZA<small>LOT LAB</small>
          </div>
        </div>
        <div className="nav-label">WORKSPACE</div>
        <nav>
          {[
            ["dashboard", LayoutDashboard, "ภาพรวม"],
            ["lots", Coffee, "จัดการล็อต"],
            ["chat", MessageCircle, "ผู้ช่วย AI"],
          ].map(([id, Icon, label]) => {
            const I = Icon as typeof Coffee;
            return (
              <button
                key={id as string}
                className={view === id ? "active" : ""}
                onClick={() => setView(id as View)}
              >
                <I size={18} />
                {label as string}
              </button>
            );
          })}
        </nav>
        <div className="sidebar-bottom">
          <Leaf size={17} />
          <div>
            <b>จากล็อต สู่คุณภาพ</b>
            <small>จัดการข้อมูลกาแฟในที่เดียว</small>
          </div>
        </div>
      </aside>
      <main className="main">
        <header className="topbar">
          <span>
            TEZA /{" "}
            <b>
              {view === "dashboard"
                ? "ภาพรวม"
                : view === "lots"
                  ? "จัดการล็อต"
                  : "ผู้ช่วย AI"}
            </b>
          </span>
          <span className="top-status">
            <i /> พื้นที่ทำงาน
          </span>
        </header>
        <div className="content">
          <div className="heading">
            <div>
              <div className="eyebrow">COFFEE INTELLIGENCE PLATFORM</div>
              <h1>
                {view === "dashboard"
                  ? "ภาพรวมล็อตกาแฟ"
                  : view === "lots"
                    ? "จัดการล็อตกาแฟ"
                    : "ผู้ช่วยวิเคราะห์ล็อต"}
              </h1>
              <p>
                {view === "dashboard"
                  ? "ติดตามข้อมูลล็อตและผลตรวจของคุณในที่เดียว"
                  : view === "lots"
                    ? "จัดการข้อมูลล็อตและบันทึกผลตรวจอย่างเป็นระบบ"
                    : "ใช้ข้อมูลที่บันทึกไว้เป็นบริบทในการสนทนา"}
              </p>
            </div>
            <button className="primary" onClick={() => editLot()}>
              <Plus size={17} /> เพิ่มล็อตใหม่
            </button>
          </div>
          {error && (
            <div className="alert" role="alert">
              {error}{" "}
              <button onClick={() => setError("")} aria-label="ปิด">
                <X size={16} />
              </button>
            </div>
          )}
          {loading ? (
            <div className="empty">กำลังโหลดข้อมูล...</div>
          ) : (
            <>
              {view === "dashboard" && <Dashboard lots={lots} setSelected={setSelected} setView={setView} editLot={() => editLot()} />}
              {view === "lots" && <LotsView lots={lots} filtered={filtered} lot={lot} selected={selected} query={query} setQuery={setQuery} setSelected={setSelected} editLot={editLot} editObs={editObs} remove={remove} />}
              {view === "chat" && <ChatView lots={lots} lot={lot} selected={selected} setSelected={setSelected} />}
            </>
          )}
        </div>
      </main>
      {modal && (
        <EditDialog modal={modal} editing={editing} busy={busy} form={form} obs={obs} setForm={setForm} setObs={setObs} setModal={setModal} save={save} />
      )}
    </div>
  );
}
