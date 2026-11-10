# TEZA Lot Lab

เว็บแอปสำหรับจัดการล็อตกาแฟ บันทึกรายการตรวจ ดู Dashboard และสนทนากับ Ollama โดยใช้ข้อมูลของล็อตที่เลือก พัฒนาด้วย Next.js, TypeScript, Prisma และ PostgreSQL

## สิ่งที่ต้องเตรียม

- Node.js 20.9 ขึ้นไปและ npm
- Docker Desktop พร้อม Docker Compose สำหรับ PostgreSQL หรือ PostgreSQL ที่ใช้งานอยู่แล้ว
- Ollama และโมเดลที่ติดตั้งแล้ว หากต้องการใช้ AI Chat

## เริ่มต้นใช้งานครั้งแรก

เปิด PowerShell ที่ root ของโปรเจกต์ แล้วทำตามลำดับ:

### 1. ติดตั้ง dependencies

```powershell
cd D:\Teza_server
npm install
```

### 2. ตั้งค่าฐานข้อมูลและ environment

ถ้ายังไม่มีไฟล์ `.env` ให้คัดลอกจากตัวอย่าง **ไม่ต้องคัดลอกทับ `.env` ที่ตั้งค่าไว้แล้ว**:

```powershell
Copy-Item .env.example .env
```

แก้ `DATABASE_URL` ใน `.env` ให้ตรงกับ PostgreSQL ที่ใช้งานจริง ตัวอย่างรูปแบบ:

```env
DATABASE_URL="postgresql://USER:PASSWORD@localhost:5432/DATABASE?schema=public"
OLLAMA_URL="http://127.0.0.1:11434"
OLLAMA_MODEL="qwen3.5:2b-q4_K_M"
```

แทน `USER`, `PASSWORD` และ `DATABASE` ด้วยค่าของเครื่อง หากใช้ Docker Compose ให้ตรวจ `POSTGRES_USER`, `POSTGRES_PASSWORD` และ `POSTGRES_DB` ใน `docker-compose.yml` ว่าตรงกับ URL ข้างต้น **ค่าใน `.env.example` อาจไม่ตรงกับ Compose ที่แก้ไขแล้ว** อักขระพิเศษใน username หรือ password ต้อง URL-encode

หากใช้ PostgreSQL จาก Compose ให้เริ่มบริการและตรวจ log:

```powershell
docker compose up -d db
docker compose logs -f db
```

เมื่อเห็น `database system is ready to accept connections` ให้กด `Ctrl + C` เพื่อออกจาก log โดยฐานข้อมูลยังทำงานอยู่ Compose เก็บข้อมูลใน Docker volume `teza_db` การเปลี่ยน `POSTGRES_USER`, `POSTGRES_PASSWORD` หรือ `POSTGRES_DB` ใน Compose หลังสร้าง volume แล้ว **ไม่ได้เปลี่ยนข้อมูลบัญชีหรือฐานที่มีอยู่โดยอัตโนมัติ** อย่าลบ volume เพื่อแก้ปัญหาโดยไม่ได้ตรวจข้อมูลก่อน

### 3. สร้าง Prisma Client และตาราง

```powershell
npm run db:generate
npm run db:migrate
```

`db:migrate` ใช้ Prisma Migrate Deploy เพื่อใช้ migration ที่มีอยู่กับฐานข้อมูลที่ระบุใน `DATABASE_URL` ตรวจ URL ให้ถูกต้องก่อนรัน

### 4. เพิ่มข้อมูลตัวอย่าง (ไม่บังคับ)

```powershell
npm run db:seed
```

คำสั่งเพิ่มล็อต `DEMO-LOT-001` ถึง `DEMO-LOT-005` และรายการตรวจจำลองลงฐานข้อมูลจริง รันซ้ำได้: ล็อตที่มีรหัสตรงกันจะถูกข้ามและไม่เขียนทับ กราฟ Dashboard รวมข้อมูลตัวอย่างกับล็อตอื่นในฐานข้อมูล

### 5. เริ่มเว็บแอป

```powershell
npm run dev
```

เปิด [http://localhost:3000](http://localhost:3000) หน้า Dashboard และ CRUD ใช้งานได้โดยไม่ต้องเปิด Ollama ส่วน AI Chat ต้องมี Ollama และโมเดลพร้อมใช้งาน

## ตั้งค่า AI Chat

ตรวจโมเดลที่มีในเครื่องด้วย:

```powershell
ollama list
```

ตั้ง `OLLAMA_MODEL` ใน `.env` ให้ตรงกับโมเดลที่ติดตั้ง และตรวจว่า Ollama ทำงานที่ `OLLAMA_URL` ค่าเริ่มต้นคือ `http://127.0.0.1:11434` จากนั้นรีสตาร์ต Next.js เมื่อเปลี่ยน `.env` หน้า Chat ส่งข้อความและข้อมูลล็อตที่เลือกผ่าน Next.js server ไปยัง Ollama ประวัติสนทนาอยู่ในหน่วยความจำของหน้าเว็บ

## โครงสร้างโปรเจกต์

```text
app/
  page.tsx                 หน้าเริ่มต้น
  layout.tsx               โครง HTML และ metadata
  globals.css              รูปแบบหน้าจอ
  api/
    lots/                  API อ่าน สร้าง แก้ไข และลบล็อต
    observations/          API สร้าง แก้ไข และลบรายการตรวจ
    chat/                  API ส่งบริบทล็อตไปยัง Ollama
components/
  workspace.tsx            จัดการ state และเชื่อมส่วนต่าง ๆ
  workspace-types.ts       types และค่าเริ่มต้นที่ใช้ร่วมกัน
  dashboard.tsx            Dashboard และกราฟสถานะล็อต
  lots-view.tsx            หน้ารายการและรายละเอียดล็อต
  inspection-preview.tsx   ตัวอย่าง UI ผลตรวจจาก Edge AI
  chat-view.tsx, chat.tsx  หน้าเลือกล็อตและบทสนทนา
  edit-dialog.tsx          ฟอร์มล็อตและรายการตรวจ
lib/
  db.ts                    Prisma Client
  validation.ts            ตรวจสอบข้อมูลที่ส่งเข้า API
prisma/
  schema.prisma            โครงสร้างฐานข้อมูลของแอป
  migrations/              ประวัติ migration
  seed.cjs                 เพิ่มข้อมูลตัวอย่าง
docs/                      แผนระบบและแบบร่างการเชื่อม Edge
prototype/                 ต้นแบบก่อนสร้าง Next.js
docker-compose.yml         PostgreSQL สำหรับพัฒนาในเครื่อง
.env.example               ตัวอย่าง environment variables
```

PostgreSQL เป็นบริการแยกจาก Next.js โดย Prisma เชื่อมผ่าน `DATABASE_URL` ข้อมูลล็อตและรายการตรวจที่แอปแสดงมาจากฐานข้อมูล ส่วน `docs/coffee-schema.draft.sql` เป็นแบบร่างอ้างอิง ไม่ใช่ schema ที่แอปใช้โดยอัตโนมัติ

## คำสั่งที่ใช้บ่อย

| คำสั่ง | การใช้งาน |
| --- | --- |
| `npm run dev` | เริ่ม Next.js สำหรับพัฒนา |
| `npm run build` | สร้าง Prisma Client และ build สำหรับ production |
| `npm run start` | เริ่ม production server หลัง build |
| `npm run db:generate` | สร้าง Prisma Client จาก schema |
| `npm run db:migrate` | ใช้ migration ที่มีอยู่กับฐานข้อมูล |
| `npm run db:seed` | เพิ่มล็อตตัวอย่างที่ยังไม่มี |
| `docker compose logs -f db` | ดู log PostgreSQL แบบต่อเนื่อง |

## สถานะและขอบเขตปัจจุบัน

- ส่วนผลตรวจภาพในหน้าล็อตเป็น **UI จำลอง** สำหรับล็อต `DEMO-LOT-*` ยังไม่ได้รับภาพหรือผลตรวจจากอุปกรณ์จริง ดูแบบข้อมูลที่เสนอใน [docs/edge-inspection-design.md](docs/edge-inspection-design.md)
- ระบบยังไม่มี authentication/authorization การเชื่อม sensor หรือ edge การอัปโหลดภาพ และการเชื่อมตลาดหรือการขายจริง จึงควรใช้ในสภาพแวดล้อมพัฒนาก่อน
- การลบล็อตจะลบรายการตรวจที่เกี่ยวข้องด้วย
- คำตอบ AI และข้อมูลจำลองต้องตรวจสอบก่อนนำไปใช้ตัดสินใจ ข้อมูลผลตรวจจากโมเดลไม่ใช่เกรดที่ได้รับการรับรอง
