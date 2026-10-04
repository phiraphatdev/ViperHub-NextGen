# คู่มือผู้ใช้ ViperHub NextGen

> **สถานะ 0.2.2 candidate; ตรวจ `manifest.json` บน main เพื่อยืนยันรุ่นที่เผยแพร่** — ตรวจ `status.json` ล่าสุดก่อนใช้งาน
> และยังไม่มีฟีเจอร์ช่วยเล่นหรือควบคุมเกม เอกสารนี้อธิบาย UI และการทดสอบ foundation เท่านั้น

## 1. ViperHub NextGen คืออะไร

ViperHub NextGen เป็นโครงพื้นฐาน Luau สำหรับแยก module ตามเกม ใช้ WindUI แสดงข้อมูลเกม
และเก็บการตั้งค่า UI โดยไม่รวมฟีเจอร์ gameplay ในเวอร์ชันนี้ การพบชื่อเกมในรายการด้านล่าง
**ไม่ได้หมายความว่าทุกแมพหรือทุก executor ผ่านการทดสอบแล้ว**

| เกม | Place ID ที่ลงทะเบียน | สถานะ production | ผลทดสอบที่มี |
| --- | ---: | --- | --- |
| Anime Vanguards | `16146832113` | ดู `status.json` | มีหลักฐาน foundation บน Potassium/Windows |
| Anime Expeditions | `84515722934860` | ดู `status.json` | มีหลักฐาน foundation บน Potassium/Windows |

ระบบตรวจ Place ID ที่ลงทะเบียนก่อน แล้วใช้ Universe GameId ที่ตรวจสอบกับ Roblox API เป็น fallback สำหรับ sub-place; นี่เป็นการระบุชื่อเกม ไม่ใช่หลักฐานว่าทุกด่านผ่านการทดสอบ runtime แล้ว
ผล Potassium ข้างต้นบันทึกไว้ใน `tests/runtime/verification.json`, `tests/runtime/AnimeVanguards-2026-09-24.json` และ `tests/runtime/AnimeExpeditions-2026-09-24.json`; ยังไม่ยืนยันการ rejoin
หรือความเข้ากันได้ของ executor อื่น ๆ; โครงการไม่กำหนดรายชื่อ executor ที่รับรองล่วงหน้า

## 2. ก่อนเริ่มใช้งาน

- ใช้เฉพาะ Roblox client/สภาพแวดล้อมที่คุณได้รับอนุญาตให้ทดสอบ
- ใช้ loader URL ที่ผู้ดูแลประกาศและเมื่อเกมใน `status.json` เป็น `ready`; นักพัฒนาใช้ local smoke harness ได้
- ต้องมี `loadstring` และ Roblox runtime; การดาวน์โหลด release ในอนาคตต้องมี HTTP ที่ใช้งานได้
- การบันทึกข้าม session ต้องมี `readfile`, `writefile`, `isfile`, `isfolder` และ `makefolder` ครบ
  ถ้าไม่มี UI ยังใช้ได้ แต่ Settings จะแสดง `Session only: filesystem APIs unavailable`
- ไม่มี API `syn.*` และไม่มี obfuscation; `src/` เปิดอ่านได้สาธารณะ

## 3. ทดสอบ foundation จากไฟล์ในเครื่อง (สำหรับผู้ทดสอบ)

ต้องมี Git, Node.js 22+, PowerShell และ checkout ของโครงการ คำสั่งต่อไปนี้ **ตรวจ/build ในเครื่อง**
ไม่ใช่คำสั่งให้เปิดฟีเจอร์ production:

```powershell
Set-Location 'C:\Users\phiraphat.pk\Documents\projects\_github\viper-hub-nextgen'
./scripts/check.ps1
./scripts/build.ps1
```

ไฟล์ทดสอบที่สร้างคือ `work/runtime-smoke.lua` ซึ่งไม่ถูก commit ผู้ทดสอบที่มี client เชื่อมกับ
`roblox-executor-mcp` จึงค่อยเรียก `execute_file` ด้วย **absolute path** ของไฟล์นี้ใน Place ID ที่ตรงกัน
แล้วอ่านสถานะด้วย `tests/runtime/Readback.luau` ตาม [คู่มือทดสอบ](TESTING.md)
การรันคำสั่งในเครื่องผ่าน ไม่ได้ยืนยันว่า UI ทำงานจริงใน Roblox

หากรันด้วย Potassium โดยตรงและไม่ต้องการคัดลอกไฟล์ ให้เปิด PowerShell ที่ root ของ repo แล้วใช้:

```powershell
./scripts/run-runtime.ps1
```

เปิด terminal นี้ค้างไว้ แล้วบันทึกบรรทัดต่อไปนี้ใน Potassium เพื่อใช้รันซ้ำ:

```lua
loadstring(game:HttpGet("http://127.0.0.1:8766/runtime-smoke.lua"))()
```

เมื่อแก้ source ให้กด Ctrl+C และรัน `./scripts/run-runtime.ps1` ใหม่เพื่อ build และให้บริการ harness ล่าสุด

**อย่าคัดลอก loader URL แบบเดาเอง:** ใช้ URL ที่ประกาศใน GitHub Release. ถ้า `manifest.json.artifactRevision` เป็น SHA จะ pin module ที่ revision นั้น; ถ้าเป็น `null` จะโหลดจาก `main/dist/`
ตรวจ `status.json` ว่าเกมที่เข้าอยู่เป็น `ready`; foundation นี้ยังไม่มีฟีเจอร์ gameplay

## 4. เมื่อเปิด UI ได้แล้ว

### หน้าตาและธีม (ทุกเกม)

- แถบซ้ายแบ่งกลุ่ม: **Home** (หน้าแรก), กลุ่มฟีเจอร์ของเกม และ **System** (Settings, Diagnostics) ด้านล่างมีการ์ดผู้เล่น แถบหัวมีแท็กชื่อเกมและเวอร์ชัน
- เปลี่ยนธีมที่ **Settings → Theme** ได้ทันที มีธีมของ ViperHub 14 แบบ (Viper ค่าเริ่มต้น, Sakura, Ocean, Sunset, Galaxy, Blood Moon, Gold Rush, Frost, Matrix, Cyberpunk, Lava, Royal, Toxic, Shadow) และธีมของ WindUI อีกหลายแบบ ระบบจำค่าที่เลือก
- Anime Vanguards มีหน้า **Dashboard** เป็นหน้าแรก: การ์ดผู้เล่น สถานะสดของ Joiner / Auto Play / Macro / Webhook / Session และยอด Gems, Gold, Rerolls, Trophies

### Overview

แสดงชื่อเกมที่ตรวจพบ, เวอร์ชัน module และวันที่อัปเดต พร้อมข้อความว่าเป็น foundation เท่านั้น
ไม่มีปุ่ม auto-farm หรือฟีเจอร์ gameplay

### Settings

| รายการ | วิธีใช้ | ค่าเริ่มต้น/ขอบเขต |
| --- | --- | --- |
| Notifications | เปิดหรือปิด notification ทั่วไป; ข้อผิดพลาดสำคัญยังแสดง | เปิด |
| UI scale | ปรับขนาดหน้าต่าง | `1.0`; ช่วง `0.8–1.3`, step `0.05` |
| Theme | เลือกธีม | `Dark` เท่านั้นในเวอร์ชันนี้ |
| Toggle UI | เลือกปุ่มซ่อน/แสดง UI | `RightShift`; รองรับ Control, Insert/Delete, Home/End และ F1–F12; ไม่รองรับ `LeftAlt` |
| Save settings | บันทึกและอ่านกลับเพื่อตรวจผล | ต้องมี filesystem APIs ครบ |

ค่าที่เปลี่ยนใน Settings และ Joiner บันทึกอัตโนมัติเมื่อ executor รองรับ filesystem APIs ครบ; ปุ่ม **Save settings** ยังใช้ตรวจการเขียนไฟล์ด้วยตนเองได้ Keybind มีผลทันทีเมื่อ WindUI ส่งสัญญาณเปลี่ยนค่า
ถ้าเปิด Notifications จะเห็น `Saved and read back` เมื่อเขียนและอ่านกลับสำเร็จ
ถ้าปิด Notifications อาจไม่มีข้อความสำเร็จ ให้ตรวจค่าภายหลังแทน
ข้อผิดพลาดที่ทำให้เริ่มระบบไม่ได้ยังแสดงแม้ปิด Notifications เพื่อไม่ให้หน้า UI หายโดยไม่มีคำอธิบาย
ข้อความ `Not saved; inspect Diagnostics` หมายถึงการบันทึกไม่สำเร็จ ไม่ควรถือว่าค่าคงอยู่หลัง rejoin

ไฟล์ config ใช้ path คงที่ `ViperHubNextGen/<GameId>.json` ในพื้นที่ไฟล์ของ executor
เช่น `ViperHubNextGen/AnimeVanguards.json` แต่ตำแหน่งจริงบนอุปกรณ์ขึ้นกับ executor
มีเฉพาะฟิลด์ config ที่รู้จักเท่านั้นที่โหลดกลับ; ค่าผิดชนิดหรือเกินช่วงจะถูกปรับเป็นค่าที่ปลอดภัย
การอ่านกลับหลัง Save ไม่เท่ากับยืนยัน persistence หลังปิดเกมหรือ rejoin

### Auto Play (Anime Vanguards)

| รายการ | วิธีใช้ |
| --- | --- |
| Auto play - ingame | เปิดแล้ว vote start และเปิด Auto Play ของเกมให้ในแมตช์ ใช้พร้อม Play Macro ไม่ได้ |
| Stage Preset Rules | เลือก preset ที่บันทึกไว้ในเกมต่อโหมด (None = ไม่เปลี่ยน preset) แก้ได้เฉพาะตอนปิด Auto play - ingame; กฎทำงานเฉพาะตอนเปิด และจะเปลี่ยน preset ก่อนเปิด Auto Play ของเกม ถ้า preset ถูกลบหรือเปลี่ยนชื่อ กฎจะกลับเป็น None |

### Joiner เพิ่มเติม

- **Boss Bounties:** เข้า bounty ประจำวันที่เกมสุ่มให้ตราบที่ยังเหลือรอบ (Legend Stage ใช้ Nightmare, Story ใช้ Normal) ถ้าเปิด Auto Replay ของเกมไว้ รอบถัดไปจะเปลี่ยนไป bounty ใหม่ก่อน vote start ถ้าไม่เปิด จะกลับ lobby หลังจบแมตช์
- **Change Stage in Match:** เมื่อเป็น host และยังไม่ vote start ใน Story, Legend Stage, Raid, Dungeon จะเปลี่ยนเป็นด่านของ joiner ที่ priority สูงสุดที่เปิดอยู่ (โหมดที่เกมไม่อนุญาตให้เปลี่ยนในแมตช์ เช่น Challenge ไม่ถูกแตะ)
- **Worldline:** ข้าม worldline ที่เกมรายงานว่าจบแล้ว
- **Auto Join Equipper > Team Equipper:** เปิดสวิตช์ "Auto Join Team Equipper" แล้วเลือกทีม (เฉพาะทีมที่เป็นเจ้าของ) ต่อ joiner ระบบจะโหลดทีมให้ก่อนเข้าด่าน และในแมตช์ก่อน vote start (หลังสลับด่านถ้ามี) ถ้าโหลดไม่สำเร็จ ข้าม joiner นั้นใน lobby หรือเล่นต่อด้วยทีมที่ใส่อยู่ในแมตช์ ไม่ทำงานเมื่อเปิด "Disable Auto Joiners" ส่วน **Macro Equipper** เลือกไฟล์มาโครต่อ joiner (เปิดสวิตช์ "Auto Join Macro Equipper") ระบบจะถอด unit ทั้งหมดแล้วใส่ตัวที่ดีที่สุด (Level สูงสุด) ของแต่ละชื่อ unit ในมาโครก่อนเข้าด่านใน lobby ถ้า unit ที่ใส่อยู่ครบชื่อตามมาโครแล้วจะไม่เปลี่ยน ถ้าตั้งทีมใน Team Equipper ไว้ด้วย จะใช้ทีมแทนมาโคร และการใส่ unit ไม่บันทึกทับทีมที่เซฟไว้

### Diagnostics

แท็บแสดง status code ของ session ปัจจุบันหลัง startup; กด **Refresh** เพื่อดูเหตุการณ์ใหม่ ข้อมูลนี้เป็น code แบบจำกัดจำนวน
ไม่แสดง payload เครือข่าย, token หรือ stack trace หากต้องแจ้งปัญหา ให้ส่ง code และบริบทเกม/executor
โดยไม่ส่งไฟล์ส่วนตัวหรือข้อมูลบัญชี

## 5. ข้อความและปัญหาที่พบบ่อย

| สิ่งที่พบ | ความหมาย/สิ่งที่ควรทำ |
| --- | --- |
| `Unsupported game` | Place ID ปัจจุบันไม่อยู่ใน registry; ตรวจ Place ID ไม่ใช่แค่ชื่อ universe |
| `Game module unavailable; status could not be confirmed.` | เกมไม่ได้เป็น `ready` หรืออ่าน status ไม่สำเร็จ; ตอนนี้ทั้งสองเกมตั้ง `disabled` อยู่ เป็นผลที่คาดไว้ |
| `เกมนี้กำลังอัปเดต กรุณารอ` | ผู้ดูแลตั้งสถานะ `maintenance`; รอการอัปเดตและอย่าฝืนใช้ module เก่า |
| `Release metadata unavailable or invalid.` | อ่านหรือ validate manifest ไม่สำเร็จ; ตรวจเครือข่ายและสถานะ release ที่ประกาศ |
| `This environment cannot load modules.` | ไม่มี `loadstring` ที่เรียกได้ในสภาพแวดล้อมนั้น |
| `Module download failed.` | ดาวน์โหลด module ไม่สำเร็จ; ตรวจเครือข่าย/ปลายทาง แล้วลองใหม่ภายหลัง |
| `Game module version or interface mismatch.` | module ไม่ตรงกับ manifest; หยุดใช้ artifact ชุดนั้นและแจ้งผู้ดูแล |
| `Session only: filesystem APIs unavailable` | ปรับค่าได้ใน session แต่บันทึกข้าม session ไม่ได้ |

**อย่าแก้ `status.json` เป็น `ready` เพื่อแก้ข้อความ error** เพราะการเปิดเกมไม่แก้สาเหตุของ module ที่โหลดผิดหรือทำงานไม่สำเร็จ

## 6. แจ้งปัญหาอย่างไร

ระบุเกมและ Place ID, executor/เวอร์ชัน, OS/อุปกรณ์, เวอร์ชัน loader, ขั้นตอนที่ทำซ้ำได้,
ข้อความที่เห็น และ Diagnostics code (ถ้ามี) แยกผล **ทดสอบในเครื่อง** ออกจากผล **ใน Roblox จริง**
ไม่ส่ง token, cookie, ไฟล์ config ส่วนตัวหรือข้อมูลบัญชี ผู้ดูแลตรวจหลักฐานก่อนเปลี่ยนสถานะเกม

เอกสารเพิ่มเติม: [Testing](TESTING.md) · [Executors](EXECUTORS.md) · [Security](SECURITY.md)
- **Webhook (Discord):** วาง URL เว็บฮุคของช่อง Discord ในแท็บ Webhook (ระบบเก็บในเครื่องและไม่แสดง URL อีกหลังกรอก) เปิด "Send notifications" แล้วกด "Send test message" เพื่อลอง ระบบแจ้งเตือนผล match, unit ใหม่ (เลือกระดับขั้นต่ำได้ Secret ขึ้นไปสามารถ ping คุณ), joiner เข้าด่าน/มีปัญหา, ความคืบหน้า Boss Bounty, Rift เปิด, Equipper, Auto Play, คำเตือน และเริ่มเซสชัน เปิด/ปิดได้ทีละเหตุการณ์ ตั้งชื่อบอท รูปบอท และซ่อนชื่อ/รูป Roblox ได้ ถ้า Discord ปฏิเสธ URL ระบบจะหยุดส่งและบอกสถานะ
- **ลำดับ Priority (Joiner และ Odyssey Adventure):** กดค้างที่แถวแล้วลากไปวางบนอีกแถวเพื่อสลับกัน เลขมากทำก่อน ปุ่ม Reset คืนค่าเริ่มต้น
- **Odyssey Adventure (Anime Vanguards):** แท็บตั้งค่าโหมด Odyssey: Adventure (ตัวละคร, Slot 1/2, ลำดับห้องใน Route Atlas, การ์ด, Stitches Shop, Cash Out, Memorized, Failsafe) ตอนนี้ **ยังไม่มีระบบอัตโนมัติ จึงล็อกทุกปุ่มไว้ (Coming soon)**; ใน Auto Join Priority แถว Elemental Towers และ Portal ถูกล็อกเช่นกันเพราะ joiner ของสองโหมดนี้ยังไม่เสร็จ
- **Misc (Anime Vanguards):** Anti-AFK (เปิดเป็นค่าเริ่มต้น) กันโดนเตะเมื่อ idle; Auto Reconnect (ปิดเป็นค่าเริ่มต้น) กลับ lobby เองเมื่อหลุดการเชื่อมต่อจริง เช่น Error 256/277 สูงสุด 5 ครั้ง ไม่ทำเมื่อโดน kick แบน หรือล็อกอินซ้อน; Re-run After Teleport ส่งบรรทัด loadstring ของคุณให้ฮับโหลดเองทุกครั้งที่เทเลพอร์ต (ต้องเปิด runtime server หรือใส่ Loader URL ที่ใช้ได้)
- **Webhook ผลแมตช์:** มีช่อง Unit Contribution จากหน้า Summary ของเกม (สัดส่วนดาเมจ, ดาเมจ, DPS ขณะอยู่บนสนาม, takedowns, 👑 ยูนิตที่ทำดาเมจสูงสุด)

