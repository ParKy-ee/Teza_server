# เตรียมรับ Coffee Vision ผ่าน MQTT

อ้างอิงไฟล์ Coffee Vision — Payload & Server Handoff: สัญญา v2.0 ในเอกสารเป็น **HTTP JSON** ยังไม่ได้กำหนด MQTT topic, QoS, authentication หรือ application acknowledgement ที่ใช้จริง ส่วนนี้จึงเป็นโครงสำหรับทดลองรับ JSON เดียวกันผ่าน MQTT ไม่ใช่การยืนยันว่าทีม Pi รองรับ MQTT แล้ว

## Payload ที่รับ

หนึ่งข้อความเป็นผลตรวจ **หนึ่งภาพ** มี `schema_version`, `event_id`, `device_id`, `batch_id`, `captured_at` พร้อม timezone, เวอร์ชันโมเดลและ class map, `count_scope: "frame"`, `moisture` (หรือ null), `summary`, และ `detections` แต่ละ detection มี `detection_id`, `class_name`, `status`, confidence, `size` (หรือ null) และ `crop_image` ที่มี JPEG Base64 ไม่ใช่ data URI โดย `bbox` และ `track_id` เป็น optional; bbox ต้องมี `source_image` ประกอบ ข้อมูลนี้ไม่มีภาพต้นฉบับ มีเพียงภาพ crop รายวัตถุ

คลาสที่ตกลงในเอกสาร: `good`, `shell`, `full_black`, `hull_husk`, `broken_chipped_cut`, `parchment`, `immature_unripe` โดย `good` ใช้ `normal` และอีกหกคลาสใช้ `defect` ค่าใน summary ต้องตรงกับ detections ทั้งหมด `hull_husk` อาจเป็นเศษเปลือก จึงเป็นจำนวนวัตถุ ไม่ใช่จำนวนเมล็ดทั้งหมด

## ตั้งค่าทดลอง

ติดตั้ง dependencies ด้วย `npm install` เพิ่มค่าต่อไปนี้ใน `.env` ให้ตรงกับ broker ที่ทีมใช้งาน (topic ข้างล่างเป็นตัวอย่างเท่านั้น):

```env
MQTT_URL="mqtt://127.0.0.1:1884"
MQTT_TOPIC="coffee/vision/v2/events"
MQTT_USERNAME=""
MQTT_PASSWORD=""
MQTT_MAX_MESSAGE_BYTES=10485760
MQTT_MAX_IMAGE_BYTES=524288
MQTT_MAX_IMAGE_PIXELS=4000000
```

จาก root รัน `npm run mqtt:subscribe` ใน terminal แยกจาก `npm run dev` หยุดด้วย Ctrl+C ตัวรับ subscribe QoS 1 และพยายาม reconnect ตรวจผลด้วย `npm run test:mqtt` ก่อนใช้งาน จำนวน detection จำกัด 500 รายการต่อ event และเพดานข้างต้นเป็นค่าเริ่มต้นที่เสนอ ต้องตกลงกับทีม edge และ broker ขนาด MQTT packet ที่ broker ยอมรับด้วย

### เปิด Mosquitto สำหรับพัฒนา

```powershell
docker compose up -d mosquitto
docker compose logs -f mosquitto
```

broker ใน Compose เปิด port `1884` ทุก network interface ของเครื่อง รวมทั้ง `127.0.0.1` ใช้ port 1884 เพื่อหลีกเลี่ยง broker อื่นที่อาจใช้ 1883 อยู่ ค่าใน `.env.example` ปรับให้ตรงแล้ว แต่ไฟล์ `.env` ที่สร้างไว้ก่อนต้องแก้ `MQTT_URL` เอง หากใช้ broker เดิมให้คง URL เดิมไว้

ตั้ง `MQTT_TOPIC` ใน `.env` แล้วเริ่ม subscriber ในอีก terminal ด้วย `npm run mqtt:subscribe` อุปกรณ์ในวง Wi-Fi ใช้ `mqtt://<Wi-Fi-IP-ของ-server>:1884` ตรวจ IP ปัจจุบันด้วย `ipconfig`; เมื่อ IP เปลี่ยน ให้อุปกรณ์ผู้ส่งเปลี่ยน IP ตาม ไม่ต้องแก้ Compose อาจต้องอนุญาต TCP 1884 ใน Windows Firewall และตรวจว่าเครือข่ายไม่แยก client ออกจากกัน การตั้งค่าปัจจุบันอนุญาต anonymous บนทุก interface ที่เข้าถึงได้ ใครที่เข้าถึง port ได้จึง publish/subscribe ได้ ใช้สำหรับทดสอบบนเครือข่ายที่เชื่อถือเท่านั้น ก่อนใช้งานจริงให้ตั้ง authentication, ACL และ TLS

## พฤติกรรมและข้อจำกัด

### อ่านข้อความความชื้น

รัน `npm run mqtt:moisture` เป็น backend worker แยกจาก `npm run dev` โดยใช้ `MQTT_URL`, `MQTT_USERNAME` และ `MQTT_PASSWORD` เดียวกับ broker ตั้ง `MQTT_MOISTURE_TOPIC` ได้ใน `.env` ค่าเริ่มต้นคือ `coffee/moisture/data` เมื่อมีข้อความ worker จะแสดง topic, เวลา server รับ, สถานะ retained และเนื้อหาใน terminal โดยอ่าน JSON ได้และแสดงข้อความปกติเมื่อไม่ใช่ JSON

รูปแบบ payload ความชื้นยังไม่ได้ตกลงกัน worker จึงยังไม่ระบุว่าค่าที่ได้รับคือความชื้นเมล็ดหรืออากาศ ไม่บันทึกฐานข้อมูล ไม่ให้หน้าเว็บอ่านค่า และไม่มี application acknowledgement ให้หยุดด้วย Ctrl+C

- `mqtt/contract.cjs` ตรวจโครงสร้าง class/status, summary, moisture, bbox, Base64, JPEG และขนาดภาพ; `mqtt/subscriber.cjs` รับข้อความและแสดงเพียง metadata โดยไม่พิมพ์ภาพหรือ credentials
- ผล `validated_not_saved` หมายถึงตรวจรูปแบบผ่าน **ยังไม่บันทึกภาพหรือข้อมูลลง PostgreSQL และยังไม่แสดงในหน้าล็อต** ข้อความที่ไม่ผ่านจะพิมพ์เหตุผลและไม่บันทึกเช่นกัน
- มีฟังก์ชัน `mqtt/ingest.cjs` ที่จับคู่ `batch_id` กับ `Lot.code` แบบตรงตัว และเตรียมบันทึก JPEG crop ใน transaction แต่ยังไม่ได้เชื่อมกับ subscriber หรือใช้งานกับฐานข้อมูลจริง ดูข้อจำกัด migration ใน `docs/prisma-edge-review.md`
- QoS 1 เป็นการรับประกันระดับ MQTT transport เท่านั้น ไม่ใช่การยืนยันว่าแอปบันทึก event สำเร็จ โครงนี้ไม่มี durable queue, deduplication, retry ระดับแอป หรือ application ACK/NACK อย่าใช้เป็น ingestion production หรือให้ Pi ลบข้อมูลต้นทางตาม MQTT ACK
- ก่อนเชื่อมจริง ต้องตกลง topic และ ACL, device authentication/TLS, ขนาดและอัตราข้อความ, persistent session, application ACK/retry/dead-letter, การป้องกัน event ID ซ้ำ/เนื้อหาเปลี่ยน และวิธีบันทึกภาพกับ metadata ให้กู้คืนได้ครบ event
- สรุปผลเป็นราย frame เท่านั้น ห้ามบวกข้าม frame เป็นยอดล็อตโดยไม่มีการป้องกันนับซ้ำ น้ำหนักและเกรดไม่ได้อยู่ใน event นี้ และอัตราตามจำนวนใช้แทนร้อยละโดยมวลไม่ได้

สัญญาเดิมมีตัวอย่างในเอกสารที่ระบุ `bbox` แต่บางส่วนไม่มี `source_image`; เมื่อส่ง bbox จริงต้องแนบ source_image ตามข้อกำหนด ส่วน Base64 placeholder ในเอกสารไม่ใช่ภาพ JPEG จริง จึงไม่ผ่านตัวตรวจ
