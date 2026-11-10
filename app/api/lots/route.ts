import { db } from "@/lib/db";
import { lotSchema } from "@/lib/validation";
import { NextResponse } from "next/server";
export async function GET(){try{return NextResponse.json(await db.lot.findMany({orderBy:{createdAt:"desc"},include:{observations:{orderBy:{createdAt:"desc"}}}}));}catch{return NextResponse.json({error:"เชื่อมต่อฐานข้อมูลไม่ได้ ตรวจสอบ PostgreSQL และ migration"},{status:503});}}
export async function POST(req:Request){try{const data=lotSchema.parse(await req.json());return NextResponse.json(await db.lot.create({data}),{status:201});}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"บันทึกไม่สำเร็จ"},{status:400});}}
