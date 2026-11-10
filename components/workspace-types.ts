export type Observation = {
  id: string;
  lotId: string;
  type: string;
  value: string;
  unit: string;
  source: string;
  notes: string;
};
export type Lot = {
  id: string;
  code: string;
  name: string;
  origin: string;
  variety: string;
  process: string;
  status: string;
  weight: number | null;
  notes: string;
  createdAt: string;
  observations: Observation[];
};
export const blank = {
  code: "",
  name: "",
  origin: "",
  variety: "Arabica",
  process: "",
  status: "กำลังตรวจ",
  weight: "",
  notes: "",
};
export const blankObservation = {
  type: "ความชื้น",
  value: "",
  unit: "%",
  source: "",
  notes: "",
};

export type LotForm = typeof blank;
export type ObservationForm = typeof blankObservation;
export type View = "dashboard" | "lots" | "chat";
