import { z } from "zod";
export const lotSchema = z.object({code:z.string().trim().min(1).max(80),name:z.string().trim().min(1).max(200),origin:z.string().max(200),variety:z.string().max(200),process:z.string().max(100),status:z.string().max(100),weight:z.number().positive().nullable(),notes:z.string().max(5000)});
export const observationSchema = z.object({lotId:z.string().min(1),type:z.string().trim().min(1).max(100),value:z.string().trim().min(1).max(1000),unit:z.string().max(100),source:z.string().max(200),notes:z.string().max(5000)});
