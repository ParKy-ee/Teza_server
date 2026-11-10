const { PrismaClient } = require('@prisma/client');
require('@next/env').loadEnvConfig(process.cwd());
const db = new PrismaClient();

// Each lot is inserted only when its demo code is absent; existing records are never overwritten.
const samples = [
  { code: 'DEMO-LOT-001', name: 'ตัวอย่าง · ดอยเหนือ', origin: 'เชียงใหม่', variety: 'Arabica', process: 'Washed', status: 'พร้อมขาย', weight: 120, observations: [['ความชื้น','10.8','%'],['ตำหนิ','4','เมล็ด']] },
  { code: 'DEMO-LOT-002', name: 'ตัวอย่าง · ภูเขา', origin: 'เชียงราย', variety: 'Arabica', process: 'Honey', status: 'กำลังตรวจ', weight: 85, observations: [['ความชื้น','11.4','%'],['Water activity','0.56','aw']] },
  { code: 'DEMO-LOT-003', name: 'ตัวอย่าง · สวนใต้', origin: 'ชุมพร', variety: 'Robusta', process: 'Natural', status: 'พักล็อต', weight: 150, observations: [['ความชื้น','12.1','%'],['ตำหนิ','8','เมล็ด']] },
  { code: 'DEMO-LOT-004', name: 'ตัวอย่าง · แม่แจ่ม', origin: 'เชียงใหม่', variety: 'Arabica', process: 'Natural', status: 'พร้อมขาย', weight: 95, observations: [['ความชื้น','10.5','%'],['Water activity','0.53','aw']] },
  { code: 'DEMO-LOT-005', name: 'ตัวอย่าง · ดอยช้าง', origin: 'เชียงราย', variety: 'Arabica', process: 'Washed', status: 'กำลังตรวจ', weight: 110, observations: [['ความชื้น','11.2','%'],['ตำหนิ','5','เมล็ด']] },
];
async function main() {
  for (const { observations, ...lot } of samples) {
    const existing = await db.lot.findUnique({ where: { code: lot.code } });
    if (existing) { console.log(`Skipped ${lot.code}: already exists`); continue; }
    await db.lot.create({ data: { ...lot, notes: 'ข้อมูลจำลองสำหรับทดลองใช้งาน', observations: { create: observations.map(([type, value, unit]) => ({ type, value, unit, source: 'ข้อมูลจำลอง', notes: 'ค่าตัวอย่าง ไม่ใช่ผลตรวจจริง' })) } } });
    console.log(`Created ${lot.code}`);
  }
}
main().catch((error) => { console.error(error); process.exitCode = 1; }).finally(() => db.$disconnect());
