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
รูปแบบ release: status=`passed`, sourceCommit, artifactHashes, tier (`beta` หรือ `stable`), targetGames และ runs อย่างน้อยหนึ่งรายการต่อเกมใน scope โดยไม่กำหนด executor ล่วงหน้า
แต่ละคู่ gameId/executor ต้องไม่ซ้ำกัน และทุก run ที่ส่งมาต้องผ่านครบ
แต่ละ run ต้องมี gameId, executor, executorVersion, clientVersion, os, testedAt (ISO timestamp), placeId, status=`passed`
และ checks object: Beta บังคับ startup/ui/controls/configReadback; Stable บังคับเพิ่ม rejoinPersistence/cleanup แต่ละอันมี result=`passed` และ observed ที่เป็นผลอ่านกลับจริง
Beta ต้องมี `limits` บอกสิ่งที่ยังไม่ผ่านหรือไม่ได้ทดสอบอย่างชัดเจน ผลของเกมที่ไม่ได้เลือกไม่ขวาง beta แต่เกมนั้นต้องคง `disabled`
`tests/release-guards.test.mjs` ใช้ข้อมูล fixture จำลองเพื่อทดสอบ validator เท่านั้น ไม่ใช่หลักฐาน runtime
ห้ามเติม passed ถ้าไม่มี client หรืออาศัย mock tests อย่างเดียว

## Current result

2026-09-24: Anime Vanguards current-source foundation partially verified on Potassium v2.5.0 / Windows using the local harness. Startup, visible UI, settings file readback, loader rerun and restoration were observed. Rejoin and physical input remain pending. See ../tests/runtime/AnimeVanguards-2026-09-24.json.

2026-09-24: Anime Expeditions foundation partially verified on Potassium v2.5.0 / Windows using the local harness. Startup, visible UI, settings file readback, loader rerun and restoration were observed. Rejoin and physical input remain pending. See ../tests/runtime/AnimeExpeditions-2026-09-24.json.

A client connected during the task: Potassium v2.4.9 / Windows, Anime Vanguards place version 22443. Foundation startup, live control methods, config write/readback, destroy/reopen persistence and simulated RightShift keyboard toggling passed. Rejoin and the other game/executors remain pending. See ../tests/runtime/verification.json.
Artifact and local mock checks are reproducible using check.ps1; console output is the current local evidence.
