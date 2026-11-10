---
document_id: coffee-standards-and-sources
title: Coffee quality standards and source registry
language: th
version: 2
status: curated_reference_draft
reviewed_as_of: 2026-10-11
intended_use: source registry for human review and later SVM or retrieval indexing
scope:
  - green coffee physical quality
  - moisture measurement
  - storage and safety interpretation
  - coffee process control and equipment evidence
---

# ทะเบียนมาตรฐานและแหล่งอ้างอิงคุณภาพกาแฟ

เอกสารนี้รวบรวมแหล่งข้อมูลเรื่องคุณภาพกายภาพของกาแฟสารเพื่อใช้ทบทวนเกณฑ์และเตรียมทำคลังความรู้/ดัชนีค้นหาในภายหลัง แต่ละแหล่งมีขอบเขตการใช้กำกับไว้ เพื่อลดโอกาสนำตัวเลขจากคนละมาตรฐานมาใช้ปะปนกัน

สถานะของเอกสารนี้: **ทะเบียนแหล่งอ้างอิงสำหรับทบทวน ยังไม่ได้รับอนุมัติเป็น rule set ที่ระบบใช้ตัดเกรดจริง** เอกสารมาตรฐานอาจมีข้อกำหนดการเข้าถึงหรือการใช้งาน ให้ปฏิบัติตามเงื่อนไขของเจ้าของมาตรฐาน

## กติกาการนำข้อมูลไปใช้

- ใช้เฉพาะข้อมูลที่อยู่ใน `ขอบเขตที่ยืนยันได้` ของ source ID ที่ระบุ
- เก็บชื่อมาตรฐาน หน่วย ขอบเขตสินค้า วิธีทดสอบ ปี/รุ่น และ URL ไว้กับข้อกำหนดเสมอ
- ตัวเลขที่ขัดกันไม่ได้แปลว่ามาตรฐานหนึ่งผิด ให้ตรวจชนิดกาแฟ รูปสินค้า วิธีวัด ตลาด และวันที่ใช้ก่อนเปรียบเทียบ
- แยก **ข้อกำหนดมาตรฐาน**, **วิธีทดสอบ**, **แนวปฏิบัติด้านความปลอดภัย**, **ข้อมูลผู้ผลิตเครื่องมือ** และ **บทความอธิบาย** ออกจากกัน
- ห้ามให้ SVM สร้าง threshold, ตัดเกรด, แปลงหน่วย หรือสรุปว่าล็อตปลอดภัยจากการอนุมานข้อความเพียงอย่างเดียว
- เมื่อไม่มีข้อมูลพอ ให้ตอบ `insufficient_source_or_context` และบอกข้อมูลที่ขาดแทนการเติมค่ามาตรฐานเอง
- สถานะอ้างอิง `primary` หมายถึงเอกสารจากองค์กรผู้กำหนด/ผู้จัดทำมาตรฐาน หรือเอกสารวิชาการ/คู่มือทางการของเจ้าของข้อมูลนั้น; `vendor` เป็นข้อมูลผู้ผลิตเครื่องมือ; `secondary` เป็นข้อมูลประกอบที่ยังไม่ยืนยันเป็นมาตรฐาน

## หมวด A — เกณฑ์สินค้าและคุณภาพกาแฟสาร

### SRC-TH-ARABICA-5701-2561

- ประเภท: มาตรฐานสินค้าเกษตรไทย; เอกสารจากสำนักงานมาตรฐานสินค้าเกษตรและอาหารแห่งชาติ
- ชื่อ: มกษ. 5701-2561 เมล็ดกาแฟอะราบิกา (Arabica Green Coffee)
- สถานะแหล่งข้อมูล: primary; ระบุเป็นมาตรฐานสินค้าเกษตรประเภททั่วไปในบัญชีของ มกอช.
- ขอบเขตที่ยืนยันได้: สำหรับเมล็ดกาแฟ Arabica; กำหนดความชื้นไม่เกิน 12.5% โดยมวล; มีข้อกำหนดเรื่องกลิ่น สี ร่องรอยแมลง ข้อบกพร่อง ขนาด และความคลาดเคลื่อนตามเอกสาร
- วิธีความชื้น: ภาคผนวกของมาตรฐานระบุวิธี gravimetry; หากใช้เครื่องวัดวิธีอื่น ต้องทวนสอบความถูกต้องเทียบกับวิธีอบในตู้อบลมร้อน
- ขอบเขตที่ห้ามสรุป: การผ่านค่า Moisture ไม่ได้แปลว่าผ่านข้อกำหนดคุณภาพอื่นหรือได้คะแนนชิมระดับใด
- ที่มา: [PDF มกษ. 5701-2561](https://acfs-backend.acfs.go.th/storage/ProductStandards/Files//20190625123845_193079.pdf); [บัญชีมาตรฐานของ มกอช.](https://agristandards.acfs.go.th/กลุ่มย่อยไม้ยืนต้น/)

### SRC-TH-ROBUSTA-5700-2561

- ประเภท: มาตรฐานสินค้าเกษตรไทย; เอกสารจากสำนักงานมาตรฐานสินค้าเกษตรและอาหารแห่งชาติ
- ชื่อ: มกษ. 5700-2561 เมล็ดกาแฟโรบัสตา (Robusta Green Coffee)
- สถานะแหล่งข้อมูล: primary; ระบุเป็นมาตรฐานสินค้าเกษตรประเภททั่วไปในบัญชีของ มกอช.
- ขอบเขตที่ยืนยันได้: สำหรับเมล็ดกาแฟ Robusta; กำหนดความชื้นไม่เกิน 12.5% โดยมวล และมีเกณฑ์ข้อบกพร่อง/ขนาดเฉพาะ Robusta
- วิธีความชื้น: อ้างภาคผนวกวิธีวิเคราะห์ของมาตรฐาน; เครื่องมือวิธีอื่นต้องทวนสอบตามหลักเกณฑ์ที่กำหนด
- ขอบเขตที่ห้ามสรุป: อย่านำเกณฑ์ defect หรือสูตรเกรดของ Arabica มาใช้กับ Robusta โดยอัตโนมัติ
- ที่มา: [PDF มกษ. 5700-2561](https://acfs-backend.acfs.go.th/storage/ProductStandards/Files//20190624165300_803969.pdf); [บัญชีมาตรฐานของ มกอช.](https://agristandards.acfs.go.th/กลุ่มย่อยไม้ยืนต้น/)

### SRC-SCA-LEGACY-ARABICA-HANDBOOK-2013

- ประเภท: เกณฑ์ SCAA/SCA รุ่นเดิมสำหรับ Arabica; คู่มือข้อบกพร่องและการคัดเกรด
- ชื่อ: SCAA Arabica Green Coffee Defect Handbook; เผยแพร่ 2004 และปรับปรุง 2013
- สถานะแหล่งข้อมูล: คู่มือขององค์กรวิชาชีพรุ่นเดิม; ใช้อ้างเฉพาะ profile/protocol ที่ตั้งใจใช้ระบบดั้งเดิม
- ขอบเขตที่ยืนยันได้: ใช้ตัวอย่าง green coffee 350 กรัมสำหรับการจัดชั้นข้อบกพร่อง; ระบุช่วงความชื้น 10–12% สำหรับ Washed coffee เมื่อถึงเวลานำเข้า
- ขอบเขตที่ห้ามสรุป: ข้อความ 10–12% มีเงื่อนไขว่าเป็น Washed coffee ณ เวลานำเข้า จึงไม่ใช่เกณฑ์ครอบคลุมทุก process ทุกจุดในห่วงโซ่ หรือมาตรฐานสากลเพียงค่าเดียว
- ความสัมพันธ์กับ CVA: SCA อธิบายว่า Physical Assessment ของ CVA อิงระบบ green coffee grading ปี 2004 แต่ CVA พิจารณาคุณค่าหลายด้านร่วมกัน ไม่ย่อเหลือ Moisture หรือคะแนนเดียว
- ที่มา: [SCAA Arabica Green Coffee Defect Handbook](https://community-roast-world.s3.dualstack.ap-northeast-1.amazonaws.com/original/2X/c/c7996b42d1307af1820c3d7f8af057dcdf3064e6.pdf); [SCA Coffee Value Assessment](https://sca.coffee/value-assessment/)

### SRC-ICO-ICC-RESOLUTION-420

- ประเภท: โครงการปรับปรุงคุณภาพกาแฟส่งออกของ International Coffee Organization
- ชื่อ: International Coffee Council Resolution No. 420, 21 May 2004
- สถานะแหล่งข้อมูล: primary สำหรับโครงการ/เป้าหมายที่ระบุใน Resolution; ตัวเอกสารระบุลักษณะสมัครใจของโครงการ
- ขอบเขตที่ยืนยันได้: ระบุ moisture 8–12.5% วัดด้วย ISO 6673 สำหรับเป้าหมาย coffee ที่ระบุ “S” บน ICO Certificate of Origin และแยกสถานะ moisture non-conformance เป็น “XM”
- ข้อยกเว้น: อนุญาตกาแฟ specialty บางชนิดที่มีความชื้นตามธรรมชาติสูง หากระบุ nomenclature/grade เฉพาะ
- ขอบเขตที่ห้ามสรุป: ห้ามเสนอ 8–12.5% ว่าเป็นเกณฑ์ Specialty ของ SCA หรือข้อบังคับสากลที่ใช้กับทุกธุรกรรมโดยไม่ตรวจสัญญา/ตลาด
- ที่มา: [ICO ICC Resolution 420](https://ico.org/documents/iccres420e.pdf)

## หมวด B — กรอบประเมินมูลค่าและศัพท์ของ SCA

### SRC-SCA-CVA-FRAMEWORK

- ประเภท: กรอบประเมินมูลค่ากาแฟของ Specialty Coffee Association
- ชื่อ: Coffee Value Assessment (CVA)
- สถานะแหล่งข้อมูล: primary framework ของ SCA
- ขอบเขตที่ยืนยันได้: แยก Physical, Descriptive, Affective และ Extrinsic Assessment; Physical กล่าวถึงสี ข้อบกพร่อง ความชื้น และขนาด ส่วน Sensory Descriptive บันทึกคุณลักษณะ เช่น กลิ่น รส สัมผัส และ aftertaste
- ขอบเขตที่ห้ามสรุป: กรอบนี้ไม่สนับสนุนให้สรุปคุณค่าทั้งล็อตจาก moisture, cupping score, screen size หรือ attribute เดียว
- ที่มา: [หน้า SCA Coffee Value Assessment](https://sca.coffee/value-assessment/)

### SRC-SCA-CVA-MOISTURE-PROTOCOL-2024

- ประเภท: เอกสารอธิบายระบบ CVA ที่จัดทำโดย SCA
- ชื่อ: A System to Assess Coffee Value: Understanding the SCA’s Coffee Value Assessment, June 2024
- สถานะแหล่งข้อมูล: SCA-authored framework guide; เป็นเอกสารอธิบายระบบ ไม่ใช่ตัวแทนทุก provisional/product standard ฉบับปัจจุบัน
- ขอบเขตที่ยืนยันได้: แยก Physical Assessment of Green Coffee, sample mechanics, capacitive determination of moisture และ bean-size assessment ออกจากการประเมินเชิงประสาทสัมผัส/มูลค่า
- ขอบเขตที่ห้ามสรุป: ห้ามอ่านคู่มือปี 2024 เป็นหลักฐานว่า threshold ใด threshold หนึ่งยังใช้เป็นมาตรฐานปัจจุบันโดยไม่ตรวจ SCA product standard ฉบับปัจจุบัน
- ที่มา: [SCA-authored CVA guide, June 2024 (PDF)](https://static1.squarespace.com/static/584f6bbef5e23149e5522201/t/667182ffdde8a5081afc2d8c/1718715138872/SCA+-+A+System+to+Asssess+Coffee+Value+-+June+2024+%28Secured%29.pdf); [รายชื่อมาตรฐาน SCA](https://sca.coffee/research/coffee-standards)

## หมวด C — วิธีทดสอบและสอบเทียบ Moisture

### SRC-ISO-6673-2025

- ประเภท: International Standard — test method/reference method
- ชื่อ: ISO 6673:2025, Green coffee — Determination of loss in mass at 105 °C; edition 3; published November 2025
- สถานะแหล่งข้อมูล: primary standard จาก ISO; สถานะ Published ตามหน้ามาตรฐานที่ตรวจเมื่อ 2026-10-11
- ขอบเขตที่ยืนยันได้: กำหนดวิธีหาการสูญเสียมวลที่ 105 °C สำหรับ green coffee; โดยข้อตกลงระหว่างผู้เกี่ยวข้องสามารถใช้ loss in mass นี้เป็นวิธีประเมิน water content และใช้เป็นวิธีอ้างอิงสำหรับสอบเทียบวิธีอื่น
- ขอบเขตที่ห้ามสรุป: ISO 6673 เป็นวิธีวัด ไม่ใช่ threshold ว่า 10%, 12% หรือ 12.5% จึงถือว่าเกรดใด
- ที่มา: [ISO 6673:2025](https://www.iso.org/standard/87697.html)

### SRC-METHOD-CAPACITANCE-COFFEE

- ประเภท: หลักการวัดทางอ้อม / แนวทางใช้และสอบเทียบเครื่องมือ
- แหล่งหลัก: SCA CVA guide 2024 และข้อกำหนดตรวจทวนเครื่องมือใน มกษ. 5701-2561
- ขอบเขตที่ยืนยันได้: เครื่อง capacitance ประเมิน Moisture จากคุณสมบัติทางไฟฟ้าของตัวอย่างและ calibration ที่สัมพันธ์กับชนิดวัสดุ; หากใช้แทนวิธีอ้างอิงต้องบันทึก calibration และผลการทวนสอบ
- วิธีที่ยืนยันจากเอกสาร มกษ. 5701: วิธีมาตรฐานที่ระบุเป็น gravimetry; วิธีเครื่องวัดอื่นต้องทวนสอบเปรียบเทียบกับวิธีอบตู้อบลมร้อน
- ขอบเขตที่ห้ามสรุป: อย่าเก็บตัวเลขจากเครื่อง capacitive เสมือนเป็นผล ISO 6673 โดยตรง; เครื่องวัดความชื้นไม่ได้วัด Water Activity แทนให้อัตโนมัติ
- ที่มา: [มกษ. 5701-2561](https://acfs-backend.acfs.go.th/storage/ProductStandards/Files//20190625123845_193079.pdf); [SCA-authored CVA guide 2024](https://static1.squarespace.com/static/584f6bbef5e23149e5522201/t/667182ffdde8a5081afc2d8c/1718715138872/SCA+-+A+System+to+Asssess+Coffee+Value+-+June+2024+%28Secured%29.pdf)

### SRC-VENDOR-SINAR-AGRIPRO

- ประเภท: เอกสารผลิตภัณฑ์จากผู้ผลิตเครื่องมือ; vendor source ไม่ใช่มาตรฐาน
- ชื่อ: Sinar AgriPro 6095 Green Coffee Moisture Analyser
- ขอบเขตที่ยืนยันได้จากผู้ผลิต: เครื่องวัดใช้หลักการ capacitance และชดเชยอุณหภูมิอัตโนมัติ; ข้อกำหนดผลิตภัณฑ์ระบุค่าความแม่นยำตาม application
- วิธีใช้ในระบบ: เก็บยี่ห้อ รุ่น calibration/commodity mode และอุณหภูมิประกอบผลอ่าน หากอ่านค่าจากเครื่องโดยตรง
- ขอบเขตที่ห้ามสรุป: สเปกของเครื่องรุ่นนี้ไม่รับรองความแม่นยำของเครื่องรุ่นอื่นและไม่แทนการทวนสอบในล็อตจริง
- ที่มา: [Sinar product page](https://www.sinar.co.uk/product-page/agripro-6095-green-coffee-moisture-analyser)

## หมวด D — การทำแห้ง การเก็บรักษา และความเสี่ยงด้านความปลอดภัย

### SRC-CODEX-OTA-COFFEE-CXP-69-2009

- ประเภท: Code of Practice ด้านป้องกัน ochratoxin A ระหว่างผลิตและแปรรูปกาแฟ
- ชื่อ: Codex CXC 69-2009 (เดิม CAC/RCP 69-2009), Prevention and Reduction of Ochratoxin A Contamination in Coffee
- สถานะแหล่งข้อมูล: primary technical code ของ Codex Alimentarius/FAO-WHO
- ขอบเขตที่ยืนยันได้: ให้ติดตามการทำแห้งจากตัวอย่างหลายจุดและทำซ้ำ; ระบุการสอบเทียบเครื่องมือภาคสนามเทียบ ISO 6673; อธิบายการลดความเสี่ยงเชื้อราด้วยการควบคุม aw/ความชื้นและการหลีกเลี่ยงการเปียกซ้ำ
- ข้อจำกัด: aw/moisture เป็นปัจจัยที่ช่วยจัดการความเสี่ยง ไม่ใช่ผลตรวจยืนยันว่า lot มี/ไม่มีรา หรือมี/ไม่มี OTA; การยืนยันสารปนเปื้อนต้องใช้การวิเคราะห์ที่เหมาะสม
- ที่มา: [Codex code of practice (PDF)](https://www.fao.org/input/download/standards/11250/CXP_069e.pdf)

### SRC-SCA-LEGACY-AW-2018

- ประเภท: เอกสาร SCA ฉบับปรับปรุง 2018 เรื่อง green coffee quality และ water activity
- ขอบเขตที่ยืนยันได้: เอกสารระบุ aw ต่ำกว่า 0.70 สำหรับ Specialty grade green coffee และอธิบายว่า aw กับ Moisture Content เป็นคนละคุณสมบัติ
- ข้อจำกัด: เป็นเอกสารฉบับเก่า; ตรวจ protocol/SCA standard ฉบับปัจจุบันและขอบเขตกาแฟก่อนสร้างกฎผลิตจริง; ค่า aw ปัจจุบันไม่ยืนยันว่าในอดีตไม่เคยเกิดการเสื่อมเสีย
- ที่มา: [SCA Coffee Standards, revised 2018](https://editordecafe.com/wp-content/uploads/2019/03/6ec09-coffeestandards-digital.pdf); [หน้า SCA CVA ปัจจุบัน](https://sca.coffee/value-assessment/)

### SRC-RESEARCH-STORAGE-COFFEE-2023

- ประเภท: บทความวิจัย peer-reviewed เรื่อง storage และ sensory/chemical stability; ใช้เป็นหลักฐานประกอบ ไม่ใช่เกณฑ์เกรด
- ขอบเขตที่ยืนยันได้: งานทดลองกับกาแฟ pulped-natural และเงื่อนไขบรรจุ/อุณหภูมิที่ระบุ พบว่าการเก็บในบรรจุภัณฑ์ barrier สูงร่วมกับสภาพแวดล้อมเย็นช่วยรักษาคุณลักษณะในเงื่อนไขการทดลองนั้น
- ขอบเขตที่ห้ามสรุป: ผลเฉพาะชนิดกาแฟ ตัวอย่าง บรรจุภัณฑ์ และระยะเวลาที่ทดลอง ห้ามใช้ทำนายอายุของล็อตอื่นโดยไม่มีข้อมูลเทียบเคียง
- ที่มา: [Effect of storage conditions on the chemical and sensory quality of pulped natural coffee (2023)](https://www.sciencedirect.com/science/article/pii/S0022474X23001091)

## หมวด E — งานวิจัยและหลักฐานประกอบกระบวนการแปรรูป

แหล่งในหมวดนี้เป็นงานวิจัยเฉพาะตัวอย่างและเงื่อนไขการทดลอง ไม่ใช่มาตรฐานสินค้า หรือสูตร/threshold ที่ใช้ได้กับกาแฟทุกแหล่งโดยอัตโนมัติ ใช้ตั้งสมมติฐานของ Process Run และออกแบบการทดลองเท่านั้น

### SRC-RESEARCH-COFFEE-CONTROLLED-FERMENTATION-2023

- ประเภท: งานวิจัยต้นฉบับด้านการหมักและคุณภาพประสาทสัมผัส
- ชื่อ: Effect of fermentation on the physicochemical characteristics and sensory quality of Arabica coffee
- สถานะแหล่งข้อมูล: primary research; ตีพิมพ์ใน 3 Biotech (2023), DOI 10.1007/s13205-023-03768-9
- ขอบเขตที่ยืนยันได้: ทดลองกับ Arabica สายพันธุ์ Yellow Catuaí IAC 62 และยีสต์ Saccharomyces cerevisiae โดยศึกษาความสัมพันธ์ของเวลา อุณหภูมิ pH ความชื้น น้ำตาล และกรดอินทรีย์กับผล sensory
- ขอบเขตที่ห้ามสรุป: สภาวะที่เหมาะในงานทดลองไม่ใช่ setpoint สากล และไม่ได้รับประกันโน้ตไวน์/ดอกไม้/ผลไม้หรือการไม่เกิด over-fermentation ในล็อตอื่น
- ที่มา: [PubMed record and abstract](https://pubmed.ncbi.nlm.nih.gov/37982081/); [full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC10654292/)

### SRC-RESEARCH-HYBRID-COFFEE-DRYER-2023

- ประเภท: งานวิจัยต้นฉบับด้านการออกแบบและประเมินเครื่องอบกาแฟ
- ชื่อ: Design and evaluation of a hybrid solar dryer for postharvesting processing of parchment coffee
- สถานะแหล่งข้อมูล: primary research; Renewable Energy, volume 215 (2023), DOI 10.1016/j.renene.2023.118961
- ขอบเขตที่ยืนยันได้: ระบบทดลองผสานเครื่องอบแบบ solar tunnel, ความร้อนเชิงกลจากเตาชีวมวล และ photovoltaic; รายงานเวลาอบและการกระจายอุณหภูมิ/ความชื้นอากาศที่ดีขึ้นใน configuration ที่ทดสอบ
- ขอบเขตที่ห้ามสรุป: งานนี้ไม่ได้ทดสอบฮีตเตอร์ไฟฟ้าตามแบบที่เสนอโดยตรง และไม่ได้รับรองเป้าหมาย 10.5–11.5% หรือยืนยันว่าไม่มีรา/สาร OTA
- ที่มา: [บทความและข้อมูล DOI (Elsevier/IDEAS)](https://doi.org/10.1016/j.renene.2023.118961)

### SRC-RESEARCH-COFFEE-OPTICAL-DEFECT-2022

- ประเภท: งานวิจัยต้นฉบับด้าน machine vision / NIR สำหรับคัดเมล็ดกาแฟ
- ชื่อ: Real-time defect inspection of green coffee beans using NIR snapshot hyperspectral imaging
- สถานะแหล่งข้อมูล: primary research; Computers and Electronics in Agriculture 197 (2022), article 106970, DOI 10.1016/j.compag.2022.106970
- ขอบเขตที่ยืนยันได้: ทดลองใช้ภาพ hyperspectral ย่าน NIR และ deep learning กับเมล็ดกาแฟสาร 1,026 เมล็ด รายงานความแม่นยำรวม 98.6% ในชุดทดลอง และเสนอระบบคัดแยกอัตโนมัติแบบ real-time
- ขอบเขตที่ห้ามสรุป: ตัวเลขความแม่นยำผูกกับชุดข้อมูล/โมเดลในการทดลอง ไม่ใช่การรับรองเครื่อง RGB sorter ทั่วไป; ยังต้องทดสอบ false accept/false reject กับตัวอย่างและชนิด defect จริงของระบบ และใช้การสุ่มตรวจยืนยัน
- ที่มา: [บทความฉบับผู้จัดพิมพ์](https://doi.org/10.1016/j.compag.2022.106970)

### SRC-RESEARCH-COFFEE-ROASTING-TECHNOLOGIES-2020

- ประเภท: งานวิจัยต้นฉบับเปรียบเทียบเทคโนโลยีการคั่ว
- ชื่อ: Effects of coffee roasting technologies on cup quality and bioactive compounds of specialty coffee beans
- สถานะแหล่งข้อมูล: primary research; Food Science & Nutrition 8 (2020), 6120–6130, DOI 10.1002/fsn3.1904
- ขอบเขตที่ยืนยันได้: เปรียบเทียบ drum, fluidized-bed และ traditional roaster กับกาแฟหลายแหล่งและหลายระดับคั่ว; งานนี้พบผลบางประการขึ้นกับเครื่องคั่วและระดับคั่ว และอธิบายการถ่ายเทความร้อนแบบ fluidized bed
- ขอบเขตที่ห้ามสรุป: งานทดลองไม่ได้พิสูจน์ว่ากราฟคั่วซ้ำได้เหมือนกัน 100%; ความสม่ำเสมอต้องประเมินจากข้อมูล input, batch, sensor, roast curve และผลผลิตของเครื่องจริง
- ที่มา: [Full text at PubMed Central](https://pmc.ncbi.nlm.nih.gov/articles/PMC7684626/); [DOI](https://doi.org/10.1002/fsn3.1904)

## หมวด F — บทความประกอบที่ยังไม่ยืนยัน

### SRC-SECONDARY-PROCOFFEEDRIP-SCA-ARTICLE

- ประเภท: บทความภาษาไทยจากเว็บไซต์ร้าน/ผู้ประกอบการ; secondary source
- URL ที่ผู้ใช้ส่ง: [มาตรฐานกาแฟโดย SCA หรือ Specialty Coffee Association](https://www.procoffeedrip.com/article/5/มาตรฐานกาแฟ-โดยสมาคมกาแฟพิเศษ-sca-หรือ-specialty-coffee-association)
- สถานะ: ลิงก์เปิดอ่านไม่ได้ระหว่างการตรวจแหล่งข้อมูล จึงยังไม่ยืนยันข้อความ ตัวเลข รุ่นมาตรฐาน หรือวันที่ของเนื้อหา
- วิธีนำไปใช้: เก็บไว้เป็นแหล่งที่ต้องกลับมาตรวจ; ห้ามใช้แทนเอกสาร primary หรือใช้เติม threshold ใน SVM จนกว่าจะตรวจเนื้อหาและ cross-reference กับเจ้าของมาตรฐาน

## สรุปแหล่งข้อมูลตามชนิดการอ้าง

- **เกณฑ์สินค้าไทย:** `SRC-TH-ARABICA-5701-2561`, `SRC-TH-ROBUSTA-5700-2561`
- **กรอบและคู่มือ SCA:** `SRC-SCA-CVA-FRAMEWORK`, `SRC-SCA-CVA-MOISTURE-PROTOCOL-2024`, `SRC-SCA-LEGACY-ARABICA-HANDBOOK-2013`, `SRC-SCA-LEGACY-AW-2018`
- **ข้อกำหนดโครงการส่งออก:** `SRC-ICO-ICC-RESOLUTION-420`
- **วิธีทดสอบ/ทวนสอบ:** `SRC-ISO-6673-2025`, `SRC-METHOD-CAPACITANCE-COFFEE`
- **แนวปฏิบัติความปลอดภัย/เก็บรักษา:** `SRC-CODEX-OTA-COFFEE-CXP-69-2009`, `SRC-RESEARCH-STORAGE-COFFEE-2023`
- **งานวิจัยกระบวนการแปรรูป:** `SRC-RESEARCH-COFFEE-CONTROLLED-FERMENTATION-2023`, `SRC-RESEARCH-HYBRID-COFFEE-DRYER-2023`, `SRC-RESEARCH-COFFEE-OPTICAL-DEFECT-2022`, `SRC-RESEARCH-COFFEE-ROASTING-TECHNOLOGIES-2020`
- **ผู้ผลิตเครื่องมือ:** `SRC-VENDOR-SINAR-AGRIPRO`
- **แหล่งที่รอตรวจ:** `SRC-SECONDARY-PROCOFFEEDRIP-SCA-ARTICLE`

## โครงข้อมูลที่แนะนำสำหรับค้นคืนภายหลัง

เมื่อแปลงเอกสารนี้เป็น source records ให้เก็บ field ต่อไปนี้ต่อหนึ่งข้อความ/ข้อกำหนด:

```yaml
source_id: SRC-TH-ARABICA-5701-2561
source_type: product_standard
authority: primary
title: มกษ. 5701-2561 เมล็ดกาแฟอะราบิกา
edition_or_year: 2561
scope_species: arabica
scope_product_stage: green_coffee
process_scope: all_processes_unless_clause_says_otherwise
metric: moisture_content
threshold: <= 12.5
unit: percent_by_mass
test_method: gravimetry_per_standard
claim: ข้อความสั้นที่ยืนยันได้ตามเอกสาร
limitations:
  - ไม่ใช่ผล sensory หรือ cupping
  - ต้องตรวจข้อกำหนดข้ออื่นของมาตรฐานแยก
source_url: https://acfs-backend.acfs.go.th/storage/ProductStandards/Files//20190625123845_193079.pdf
checked_at: 2026-10-11
```

ให้ SVM คืน `source_id`, `claim`, `scope`, `limitations` และ `source_url` ไปพร้อมคำตอบเสมอ ห้ามรวมขอบเขตของ source หลายฉบับจนทำให้ดูเหมือนเป็นข้อกำหนดเดียวกัน
