import { db } from "@/lib/db";
import { observationSchema } from "@/lib/validation";
import { NextResponse } from "next/server";
export async function POST(req:Request){try{return NextResponse.json(await db.observation.create({data:observationSchema.parse(await req.json())}),{status:201});}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"บันทึกไม่สำเร็จ"},{status:400});}}
