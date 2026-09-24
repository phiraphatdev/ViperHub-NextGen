# คู่มือผู้ใช้ ViperHub NextGen

> **สถานะ source ในเครื่อง 0.2.0 candidate; release ที่ประกาศเดิม 0.1.0** — ตรวจ `status.json` ล่าสุดก่อนใช้งาน
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

**อย่าคัดลอก loader URL แบบเดาเอง:** ใช้ URL ที่ประกาศใน GitHub Release. ถ้า `manifest.json.artifactRevision` เป็น SHA จะ pin module ที่ revision นั้น; ถ้าเป็น `null` จะโหลดจาก `main/dist/`
ตรวจ `status.json` ว่าเกมที่เข้าอยู่เป็น `ready`; foundation นี้ยังไม่มีฟีเจอร์ gameplay

## 4. เมื่อเปิด UI ได้แล้ว

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

หลังเลือก keybind ปุ่มใหม่ควรมีผลทันทีเมื่อ WindUI ส่งสัญญาณเปลี่ยนค่า; กด **Save settings** เพื่อบันทึกข้าม session และเป็น fallback หาก WindUI รุ่นที่ใช้ไม่มีสัญญาณดังกล่าว
ถ้าเปิด Notifications จะเห็น `Saved and read back` เมื่อเขียนและอ่านกลับสำเร็จ
ถ้าปิด Notifications อาจไม่มีข้อความสำเร็จ ให้ตรวจค่าภายหลังแทน
ข้อผิดพลาดที่ทำให้เริ่มระบบไม่ได้ยังแสดงแม้ปิด Notifications เพื่อไม่ให้หน้า UI หายโดยไม่มีคำอธิบาย
ข้อความ `Not saved; inspect Diagnostics` หมายถึงการบันทึกไม่สำเร็จ ไม่ควรถือว่าค่าคงอยู่หลัง rejoin

ไฟล์ config ใช้ path คงที่ `ViperHubNextGen/<GameId>.json` ในพื้นที่ไฟล์ของ executor
เช่น `ViperHubNextGen/AnimeVanguards.json` แต่ตำแหน่งจริงบนอุปกรณ์ขึ้นกับ executor
มีเฉพาะฟิลด์ config ที่รู้จักเท่านั้นที่โหลดกลับ; ค่าผิดชนิดหรือเกินช่วงจะถูกปรับเป็นค่าที่ปลอดภัย
การอ่านกลับหลัง Save ไม่เท่ากับยืนยัน persistence หลังปิดเกมหรือ rejoin

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
