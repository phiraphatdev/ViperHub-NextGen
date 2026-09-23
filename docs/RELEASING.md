# Releasing

ใช้ `git rev-parse HEAD` ตรวจ source commit ของ candidate ปัจจุบัน; ยังไม่ tag, push หรือเผยแพร่

## ระดับการปล่อย

| ระดับ | เกณฑ์ | ขอบเขต |
| --- | --- | --- |
| Dev | Local unit/mock/build ผ่าน | ใช้ local harness; ไม่เปิด production |
| Beta | หลักฐานจริงของ startup, UI, controls และ config readback อย่างน้อยหนึ่ง environment **ต่อเกมที่จะเปิด** พร้อมระบุข้อจำกัด | เกมอื่นคง `disabled`; ไม่อ้างรองรับ executor อื่น |
| Stable | เพิ่ม rejoin persistence และ cleanup สำหรับเกมที่ลงทะเบียนทั้งหมด | ตรวจเส้นทาง published loader ก่อนประกาศ |

Beta ไม่บังคับรายชื่อ executor หรือให้ทุกเกมใน registry ผ่านพร้อมกัน แต่ไม่ผ่อน hash, sourceCommit,
artifactRevision, การตรวจรูปแบบข้อมูล หรือการหยุดโหลดอย่างปลอดภัย การทดสอบผ่านด้วย control-object methods
ต้องอธิบายว่าไม่ได้รับรอง physical/touch input; ห้ามเขียนเป็นผลอุปกรณ์จริง

## Three revisions avoid self-referential hashes

S = clean source commit ที่รวม src, vendor, tests, scripts และ lock files
A = artifact commit ที่เก็บ dist ซึ่ง build จาก S; manifest.sourceCommit=S
B = publication metadata commit ที่ตั้ง manifest.artifactRevision=A และอัปเดต manifest.txt/status ตามหลักฐาน

Loader อ่าน metadata จาก main และอ่าน code จาก GitHub Raw /A/dist/...
S ไม่จำเป็นต้องเท่ากับ A หรือ B และไม่เขียน SHA ของ commit ที่บรรจุไฟล์ตัวเอง

## Release gate

1. ตกลง owner/repo และ release version กับผู้ใช้; ไม่กำหนดรายชื่อ executor ที่ต้องใช้
2. อัปเดต module metadata, manifest version และ changelog ให้ตรงกัน
3. รัน check.ps1 และ commit source เป็น S หลังได้รับอนุมัติ
4. ทดสอบ artifact จาก S ใน Roblox จริงตาม TESTING.md
5. บันทึกหลักฐานใน work/runtime-verification.json โดย sourceCommit=S; ไม่แก้ tracked source ระหว่างทดสอบ
6. รัน ./scripts/build.ps1 -Release -Repository 'OWNER/REPO' จาก clean source checkout
7. commit artifact เป็น A หลังได้รับอนุมัติ แล้วตั้ง artifactRevision ของ manifest เป็น SHA ของ A
8. อัปเดต manifest.txt ให้สะท้อน artifactRevision และ status จากผลจริง แล้ว commit metadata เป็น B
9. รัน verify-release.ps1 เพื่อตรวจ artifact hashes, revision A, source inputs เทียบ S และ rebuild
10. Tag B ด้วย semantic version vX.Y.Z และเผยแพร่เมื่อผู้ใช้อนุมัติ

Build release ปฏิเสธ source ที่ไม่ clean, repository ที่ไม่ถูกต้อง หรือ runtime evidence ที่ไม่ตรง source commit/artifact hashes
Stable gate ต้องมีผล `passed` อย่างน้อยหนึ่ง runtime run ต่อทุกเกมที่ลงทะเบียน
Beta gate ต้องมีผล `passed` อย่างน้อยหนึ่ง runtime run ต่อเกมที่ระบุใน `-Games` เท่านั้น
หลักฐานแต่ละ run ต้องระบุชื่อ executor ที่ใช้จริง และการผ่านบนตัวหนึ่งไม่ใช่คำรับรองว่าใช้ได้กับตัวอื่น
ทุก run ต้องมี executor/client version, OS, เวลา, Place ID และ observation; Beta บังคับ startup, UI, controls, config readback ส่วน Stable เพิ่ม rejoin persistence และ cleanup
ตัวอย่าง Beta: `./scripts/build.ps1 -Release -Tier Beta -Games AnimeVanguards,AnimeExpeditions -Repository 'phiraphatdev/ViperHub-NextGen'`
ไม่มี MCP หรือหลักฐานไม่ครบให้คง status เป็น partial/disabled และห้ามอ้างว่า release พร้อม
`verify-release` ตรวจ immutable source fields ใน manifest เทียบ S; อนุญาตเฉพาะ build/publication fields ที่ต้องเปลี่ยนใน A/B
`status.json` เป็น operational metadata ที่อาจเปลี่ยนใน B จึงตรวจ schema/game keys/state แต่ไม่ได้อ้างว่า sourceCommit ผูก reason/status แบบ byte-for-byte

## Development

build.ps1 ปกติสร้าง mode=development และ sourceCommit=null เพื่อไม่อ้าง provenance ที่ยังไม่มี
verify-release.ps1 -Development ตรวจ hashes และ rebuild ได้ แต่ไม่รับรอง release
check.ps1 ไม่เปลี่ยน release metadata กลับเป็น development หากกำลังตรวจ release checkout
ไม่อัปเดต dist ด้วยมือ และไม่แก้ไฟล์ source ระหว่างสร้าง artifact commit กับ metadata commit

## Recovery

หาก build ล้มเหลว อย่า commit artifact ที่ได้บางส่วน แก้ source แล้วรัน build และ verify ใหม่
หาก release ผิด ให้ชี้ publication metadata ไปยัง artifact revision เดิมที่ตรวจแล้วและอัปเดต changelog
status.json สามารถ disable เฉพาะเกมโดยไม่ rebuild game code
