# ViperHub NextGen

![State](https://img.shields.io/badge/state-beta_foundation-blue)
![Runtime](https://img.shields.io/badge/runtime-Potassium_Windows_limited-yellow)

Multi-game Luau foundation พร้อม WindUI และโครงสร้างแยก game module
สถานะปัจจุบัน: beta foundation; ตรวจสถานะเปิดใช้งานล่าสุดที่ `status.json` ก่อนโหลด; **ยังไม่มีฟีเจอร์ gameplay**
มีหลักฐาน runtime foundation บน Potassium/Windows ในทั้งสองเกม แต่ไม่ได้รับรองทุก executor หรือ physical/touch input; ดู `tests/runtime/` สำหรับบันทึกที่ติดตามใน repo โดย local build ไม่บังคับ JSON evidence gate

| เกม | Place ID ที่ตรวจสอบแล้ว | Module | Runtime |
| --- | --- | --- | --- |
| Anime Vanguards | 16146832113 | Local candidate 0.2.0; published foundation 0.1.0 | Potassium/Windows: older beta foundation evidence |
| Anime Expeditions | 84515722934860 | Local candidate 0.2.0; published foundation 0.1.0 | Potassium/Windows: older beta foundation evidence |

การรองรับนี้คือการตรวจตัวเกมและโครง module เท่านั้น ไม่ครอบคลุมทุกแมพใน Universe

## เริ่มพัฒนาบน Windows

ต้องมี Git, Node.js 22+ และ PowerShell เครื่องมือ Luau, darklua และ StyLua จะดาวน์โหลดแบบ pin version และตรวจ SHA-256
ไม่ต้องติดตั้ง npm package ไม่มีบริการ paid tool

คัดลอกทั้ง block ใน PowerShell:

~~~powershell
Set-Location 'C:\Users\phiraphat.pk\Documents\projects\_github\viper-hub-nextgen'
./scripts/check.ps1
~~~

check สร้าง dist/manifest ใหม่ แล้วตรวจ format, strict type analysis, unit tests, bundled bootstrap ด้วย mock runtime, compile artifact และ rebuild เทียบ hash
ผลลัพธ์ build อยู่ใน dist/; local smoke harness อยู่ใน work/runtime-smoke.lua ซึ่งไม่ commit

~~~powershell
./scripts/build.ps1 -Release
./scripts/check.ps1
./scripts/verify-release.ps1
~~~

## ทดสอบ runtime

เชื่อมต่อ client กับ MCP แล้วให้ agent เรียก execute_file โดยใช้ absolute path ของ work/runtime-smoke.lua
ตามด้วย get_data_by_code ที่อ่าน tests/runtime/Readback.luau และตรวจ UI ที่สร้างจริง
ดูขั้นตอนปิด–เปิดใหม่และตรวจ config ใน [TESTING](docs/TESTING.md)

Loader URL ของ release ที่ tag แล้วใช้ artifact commit ที่ประกาศ; module ภายในจะอิง `manifest.json.artifactRevision` ถ้ามี SHA หรือ `main/dist/` หากเป็น `null`
รูปแบบ loader แบบ pin คือ `https://raw.githubusercontent.com/phiraphatdev/ViperHub-NextGen/<artifactRevision>/dist/loader.lua`
Beta 0.1.0: [loader.lua](https://raw.githubusercontent.com/phiraphatdev/ViperHub-NextGen/af39a11236b66776d756b5362cdebcc7df3dfce4/dist/loader.lua)
สำหรับอัปเดตถัดไป build/check สามารถใช้ `artifactRevision: null` และโหลด game/UI module จาก `main/dist/` ได้; อย่านำ build ในเครื่องไปอ้างว่าเผยแพร่แล้วจนกว่าจะ commit/push และตรวจ Raw จริง
**ข้อควรระวังการย้ายเวอร์ชัน:** loader v0.1.0 เดิมไม่รองรับ manifest ที่ไม่มี SHA; เมื่อจะเผยแพร่ระบบ build ใหม่ ต้องประกาศ loader URL ใหม่และตรวจ runtime ก่อน เพราะลิงก์ v0.1.0 ด้านบนจะไม่เข้ากันกับ manifest ใหม่บน main
อย่าใช้ SHA เก่าหรือเดา revision เอง; `VIPER_REPOSITORY` ใช้ override สำหรับ deployment/test

## เอกสาร

- [คู่มือผู้ใช้](docs/USER_MANUAL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [เพิ่ม game module](docs/CONTRIBUTING.md)
- [Executor compatibility](docs/EXECUTORS.md)
- [Testing](docs/TESTING.md)
- [Release](docs/RELEASING.md)
- [Security](docs/SECURITY.md)
- [Third-party attribution](THIRD_PARTY_NOTICES.md)

ตรวจ `status.json` ก่อนใช้งาน: `ready` จึงโหลดได้ ส่วน `disabled`/`maintenance` จะหยุดอย่างปลอดภัย
นโยบาย release แยก Dev/Beta/Stable; Beta เลือกเปิดเฉพาะเกมที่มีหลักฐานจริง ดู [Release](docs/RELEASING.md)
ชุดทดสอบ local ใช้ artifact ที่ build บนเครื่อง จึงไม่ต้องเผยแพร่ GitHub หรือเปิด endpoint ภายนอกเพื่อทดสอบ
