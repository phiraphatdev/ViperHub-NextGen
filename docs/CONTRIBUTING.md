# Contributing

อ่าน manifest.json, ARCHITECTURE.md และ header ของโมดูลที่เกี่ยวข้องก่อนแก้ไข
การเพิ่ม dependency หรือเปลี่ยน interface/โครงสร้างต้องเสนอให้ผู้ใช้อนุมัติก่อน

## เพิ่มเกม

1. ยืนยันหน้า Roblox และ Place ID; จดแหล่งข้อมูลและวันที่ใน docs/games/<Game>/README.md
2. เพิ่ม Metadata.luau, Config.luau และ Entry.luau ตาม contract ใน types/GameModule.luau
3. เพิ่ม Metadata ใน Registry; ห้าม import behavior ของเกมอื่น
4. เพิ่ม game artifact entry ใน build pipeline และ manifest schema validator
5. เพิ่ม docs README/UPDATES/SECURITY และสถานะ disabled ใน status.json
6. เพิ่ม test exact-match, unsupported place และ lifecycle ของเกมนั้น
7. ตรวจ local gates และยืนยัน behavior จริงก่อนเปลี่ยน availability

## เมื่อเกม patch

ระบุ affected game และหลักฐานที่เปลี่ยนก่อนแก้ ย้ายค่า path/name ที่เปลี่ยนบ่อยไว้ใน Config
แยก VERSION กับ LAST_UPDATED ใน Metadata และปรับ manifest.games ให้ตรงกัน
อัปเดต CHANGELOG และ UPDATES พร้อมผลตรวจและข้อจำกัด
ไม่ตีความ error ทุกชนิดเป็น game maintenance

## Vendor changes

อ่าน source ของ revision ที่จะใช้ ตรวจ remote downloads, filesystem assumptions และ lifecycle
อัปเดต THIRD_PARTY_NOTICES และทั้ง upstream/vendored hash ทุกครั้ง
ห้ามแก้ dist โดยตรง; build จาก src/vendor ที่ตรวจไว้แล้ว

