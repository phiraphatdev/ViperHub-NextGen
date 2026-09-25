# Testing

## Local gates

รัน ./scripts/check.ps1 เพื่อ rebuild dist/manifest แล้วตรวจ source format, --!strict analysis, edge cases, bundle compilation,
bootstrap integration ใน mock environment และ deterministic rebuild
การตรวจ release เพิ่มเติมให้รัน `./scripts/build.ps1 -Release`, `./scripts/check.ps1`, แล้ว `./scripts/verify-release.ps1`; verify-release จะปฏิเสธ manifest แบบ development
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

จดชื่อ/เวอร์ชัน executor, OS, PlaceId, artifact hash และผลที่สังเกตได้จริงเพื่อใช้ประเมิน compatibility
การบันทึก runtime evidence เป็นคำแนะนำ ไม่ใช่ไฟล์ JSON ที่ `build.ps1` หรือ `check.ps1` บังคับอ่าน
`tests/release-guards.test.mjs` ทดสอบ discovery และ local metadata guards เท่านั้น ไม่ใช่หลักฐาน runtime
ห้ามบันทึกว่า runtime ผ่านจาก mock tests หรือเมื่อไม่มี client

## Current result

Local 0.2.2 candidate integrity gates cover wrong SHA, missing hash capability and byte-size mismatch; live client verification is pending. The adapter relies on immediate owned-GUI/connection cleanup rather than invoking WindUI's asynchronous `window:Destroy()` in parallel.

Local 0.2.1 candidate: startup readback passed in both connected games. Anime Vanguards confirmed invalid LeftAlt keeps the chosen F4 key; at that point the adapter called WindUI `Destroy()` as well as deleting the owned GUI. The immutable 0.1.0 loader was observed to fail with `MANIFEST_INVALID` against current main, then the main loader was restored to `ready`. See ../tests/runtime/0.2.1-audit.json. This is historical evidence only; it does not verify the 0.2.2 change.

2026-09-24: Anime Vanguards current-source foundation partially verified on Potassium v2.5.0 / Windows using the local harness. Startup, visible UI, settings file readback, loader rerun and restoration were observed. Rejoin and physical input remain pending. See ../tests/runtime/AnimeVanguards-2026-09-24.json.

2026-09-24: Anime Expeditions foundation partially verified on Potassium v2.5.0 / Windows using the local harness. Startup, visible UI, settings file readback, loader rerun and restoration were observed. Rejoin and physical input remain pending. See ../tests/runtime/AnimeExpeditions-2026-09-24.json.

A client connected during the task: Potassium v2.4.9 / Windows, Anime Vanguards place version 22443. Foundation startup, live control methods, config write/readback, destroy/reopen persistence and simulated RightShift keyboard toggling passed. Rejoin and the other game/executors remain pending. See ../tests/runtime/verification.json.
Artifact and local mock checks are reproducible using check.ps1; console output is the current local evidence.
