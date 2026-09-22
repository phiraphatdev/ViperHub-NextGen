# Testing

## Local gates

รัน ./scripts/check.ps1 เพื่อตรวจ source format, --!strict analysis, edge cases, bundle compilation,
bootstrap integration ใน mock environment และ deterministic rebuild
Tests ใช้ native Luau CLI ไม่มีการเชื่อมต่อเกมหรือส่ง RemoteEvent

Unit scenarios ครอบคลุม nil/wrong types/NaN/infinity, bounds, version ordering, exact place detection,
cleanup reverse order/idempotency/failure, config validation/reopened store, filesystem errors,
HTTP failure/status/body size/deadline, malformed manifests/status และ compiler/export failures

Mock integration ตรวจ unsupported place, missing repository, successful placeholder/UI composition,
rerun teardown และ startup failure cleanup แต่ไม่จำลองพฤติกรรม WindUI ทั้งหมด

## Actual Roblox smoke test

1. อ่าน roblox-mcp skill และ list_clients เลือก client ที่ถูกต้องก่อน execute
2. รัน build.ps1 เพื่อสร้าง work/runtime-smoke.lua; ตรวจว่าทดสอบบน environment ที่ได้รับอนุญาต
3. execute_file absolute path ของ harness; อย่านับ scheduled execution ว่าสำเร็จ
4. อ่าน tests/runtime/Readback.luau ผ่าน get_data_by_code ควรพบ ready, alive=true, gameId ตรงและ windowPresent=true
5. ตรวจ UI จริงว่า Overview/Settings/Diagnostics แสดงและไม่มี gameplay action
6. ลอง toggle, slider, dropdown และ keybind บน input device จริง
7. Save settings แล้วอ่านไฟล์กลับ ตรวจค่า ไม่ดูแค่ notification
8. รัน harness ซ้ำ ตรวจ context เก่าหยุด ไม่มี window/connection สะสม
9. ปิดและเปิดใหม่ และ rejoin แล้วทดสอบ load config ค่าต้องอยู่ตามที่บันทึก
10. destroy context แล้วตรวจ root GUI ของ session ถูกลบ และไม่เกิด callback ที่ยังเปลี่ยน state

ชื่อ/เวอร์ชัน executor, OS, PlaceId, source commit, artifact hash และผลแต่ละข้อเป็นหลักฐานที่ต้องบันทึก
tests/runtime/verification.json บันทึกผลจริงแบบ partial พร้อม artifact hashes
สำหรับ release ให้สร้าง work/runtime-verification.json ซึ่งอยู่นอก Git commit ที่กำลังทดสอบ
รูปแบบอย่างน้อย: status, sourceCommit, executor, clientVersion, os, checks พร้อมหลักฐานจริง
ห้ามเติม passed ถ้าไม่มี client หรืออาศัย mock tests อย่างเดียว

## Current result

A client connected during the task: Potassium v2.4.9 / Windows, Anime Vanguards place version 22443. Foundation startup, live control methods, config write/readback, destroy/reopen persistence and simulated RightShift keyboard toggling passed. Rejoin and the other game/executors remain pending. See ../tests/runtime/verification.json.
Artifact and local mock checks are reproducible using check.ps1; console output is the current local evidence.

