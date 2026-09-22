# Releasing

การอนุมัติ scaffold ไม่ใช่การอนุมัติ commit/tag/push/release; งานนี้ยังไม่มี source commit หรือ tag

## Three revisions avoid self-referential hashes

S = clean source commit ที่รวม src, vendor, tests, scripts และ lock files
A = artifact commit ที่เก็บ dist ซึ่ง build จาก S; manifest.sourceCommit=S
B = publication metadata commit ที่ตั้ง manifest.artifactRevision=A และอัปเดต manifest.txt/status ตามหลักฐาน

Loader อ่าน metadata จาก main และอ่าน code จาก GitHub Raw /A/dist/...
S ไม่จำเป็นต้องเท่ากับ A หรือ B และไม่เขียน SHA ของ commit ที่บรรจุไฟล์ตัวเอง

## Release gate

1. ตกลง owner/repo, release version และ executor/OS matrix กับผู้ใช้
2. อัปเดต module metadata, manifest version และ changelog ให้ตรงกัน
3. รัน check.ps1 และ commit source เป็น S หลังได้รับอนุมัติ
4. ทดสอบ artifact จาก S ใน Roblox จริงตาม TESTING.md
5. บันทึกหลักฐานใน work/runtime-verification.json โดย sourceCommit=S; ไม่แก้ tracked source ระหว่างทดสอบ
6. รัน ./scripts/build.ps1 -Release -Repository 'OWNER/REPO' จาก clean source checkout
7. commit artifact เป็น A หลังได้รับอนุมัติ แล้วตั้ง artifactRevision ของ manifest เป็น SHA ของ A
8. อัปเดต manifest.txt ให้สะท้อน artifactRevision และ status จากผลจริง แล้ว commit metadata เป็น B
9. รัน verify-release.ps1 เพื่อตรวจ artifact hashes, revision A, source inputs เทียบ S และ rebuild
10. Tag B ด้วย semantic version vX.Y.Z และเผยแพร่เมื่อผู้ใช้อนุมัติ

Build release ปฏิเสธ source ที่ไม่ clean, repository ที่ไม่ถูกต้อง หรือ runtime evidence ที่ไม่ตรง source commit
การตรวจ matrix ครบทุก target เป็น reviewer gate; script ไม่อ้างว่าหลักฐานจาก executor เดียวครอบคลุมทุกตัว

## Development

build.ps1 ปกติสร้าง mode=development และ sourceCommit=null เพื่อไม่อ้าง provenance ที่ยังไม่มี
verify-release.ps1 -Development ตรวจ hashes และ rebuild ได้ แต่ไม่รับรอง release
check.ps1 ไม่เปลี่ยน release metadata กลับเป็น development หากกำลังตรวจ release checkout
ไม่อัปเดต dist ด้วยมือ และไม่แก้ไฟล์ source ระหว่างสร้าง artifact commit กับ metadata commit

## Recovery

หาก build ล้มเหลว อย่า commit artifact ที่ได้บางส่วน แก้ source แล้วรัน build และ verify ใหม่
หาก release ผิด ให้ชี้ publication metadata ไปยัง artifact revision เดิมที่ตรวจแล้วและอัปเดต changelog
status.json สามารถ disable เฉพาะเกมโดยไม่ rebuild game code

