# ViperHub NextGen

![State](https://img.shields.io/badge/state-foundation-orange)
![Runtime](https://img.shields.io/badge/runtime-Potassium_AV_partial-yellow)

Multi-game Luau foundation พร้อม WindUI และโครงสร้างแยก game module
สถานะปัจจุบัน: local release candidate สำหรับ beta foundation (ยังไม่เผยแพร่); **ยังไม่มีฟีเจอร์ gameplay**
ตรวจ foundation/UI จริงบน Potassium/Windows ในทั้งสองเกมแล้วบางส่วน; ดู tests/runtime/verification.json และ tests/runtime/AnimeExpeditions-2026-09-24.json

| เกม | Place ID ที่ตรวจสอบแล้ว | Module | Runtime |
| --- | --- | --- | --- |
| Anime Vanguards | 16146832113 | Placeholder 0.1.0 | Potassium/Windows: partial |
| Anime Expeditions | 84515722934860 | Placeholder 0.1.0 | Potassium/Windows: partial |

การรองรับนี้คือการตรวจตัวเกมและโครง module เท่านั้น ไม่ครอบคลุมทุกแมพใน Universe

## เริ่มพัฒนาบน Windows

ต้องมี Git, Node.js 22+ และ PowerShell เครื่องมือ Luau, darklua และ StyLua จะดาวน์โหลดแบบ pin version และตรวจ SHA-256
ไม่ต้องติดตั้ง npm package ไม่มีบริการ paid tool

คัดลอกทั้ง block ใน PowerShell:

~~~powershell
Set-Location 'C:\Users\phiraphat.pk\Documents\projects\_github\viper-hub-nextgen'
./scripts/check.ps1
~~~

check ตรวจ format, strict type analysis, unit tests, bundled bootstrap ด้วย mock runtime, compile artifact และ rebuild เทียบ hash
ผลลัพธ์ build อยู่ใน dist/; local smoke harness อยู่ใน work/runtime-smoke.lua ซึ่งไม่ commit

~~~powershell
./scripts/build.ps1
./scripts/verify-release.ps1 -Development
~~~

## ทดสอบ runtime

เชื่อมต่อ client กับ MCP แล้วให้ agent เรียก execute_file โดยใช้ absolute path ของ work/runtime-smoke.lua
ตามด้วย get_data_by_code ที่อ่าน tests/runtime/Readback.luau และตรวจ UI ที่สร้างจริง
ดูขั้นตอนปิด–เปิดใหม่และตรวจ config ใน [TESTING](docs/TESTING.md)

Loader URL: **ยังไม่มี deployment URL จริง** เพราะยังไม่ได้เผยแพร่ release; ตั้ง remote เป็น https://github.com/phiraphatdev/ViperHub-NextGen แล้ว
รูปแบบ URL หลัง release คือ https://raw.githubusercontent.com/OWNER/REPO/ARTIFACT_COMMIT/dist/loader.lua
ห้ามถือ placeholder ข้างต้นเป็น URL ใช้งานได้ ปลายทางเริ่มต้นคือ phiraphatdev/ViperHub-NextGen; VIPER_REPOSITORY ใช้ override สำหรับ deployment/test

## เอกสาร

- [คู่มือผู้ใช้](docs/USER_MANUAL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [เพิ่ม game module](docs/CONTRIBUTING.md)
- [Executor compatibility](docs/EXECUTORS.md)
- [Testing](docs/TESTING.md)
- [Release](docs/RELEASING.md)
- [Security](docs/SECURITY.md)
- [Third-party attribution](THIRD_PARTY_NOTICES.md)

status.json เริ่มด้วย disabled ทั้งสองเกมจนกว่าจะผ่าน runtime gate
นโยบาย release แยก Dev/Beta/Stable; Beta เลือกเปิดเฉพาะเกมที่มีหลักฐานจริง ดู [Release](docs/RELEASING.md)
ชุดทดสอบ local ใช้ artifact ที่ build บนเครื่อง จึงไม่ต้องเผยแพร่ GitHub หรือเปิด endpoint ภายนอกเพื่อทดสอบ
