<div align="center">

# 🐍 ViperHub NextGen

**ฮับ Luau แบบ multi-game บน WindUI — โค้ดเปิดสาธารณะ ไม่ obfuscate ไม่ใช้ API เฉพาะ Synapse**

![Version](https://img.shields.io/badge/version-0.3.0-6c5ce7)
![State](https://img.shields.io/badge/state-beta-blue)
![Luau](https://img.shields.io/badge/Luau-strict-00a2ff)
![UI](https://img.shields.io/badge/UI-WindUI-8e44ad)
![Runtime](https://img.shields.io/badge/runtime-Potassium_(Windows)-yellow)

</div>

---

## ✨ โปรเจ็คนี้คืออะไร

ViperHub NextGen คือสคริปต์ (hub) สำหรับ Roblox ที่โหลดผ่าน executor แล้วเปิดหน้าต่าง UI เดียวที่ใช้ร่วมกันทุกเกม
โดยแต่ละเกมเป็น **game module** แยกกัน (ตรวจเกมจาก Place ID / Universe) ส่วนแกนกลาง (UI, ธีม, การเก็บการตั้งค่า, lifecycle)
ไม่รู้จักเกมใดเป็นพิเศษ ทำให้เพิ่มเกมใหม่ได้โดยไม่แตะระบบเดิม

หลักการสำคัญ

- **เปิดซอร์สทั้งหมด** — อ่านโค้ดใน `src/` ได้ ไม่มี obfuscation
- **Luau `--!strict`** พร้อมชุดทดสอบ unit/integration และ build ที่ตรวจ hash ซ้ำได้
- **แต่ละฟีเจอร์แยกกัน** — ฟีเจอร์หนึ่งพังไม่ทำให้แท็บอื่นล้ม และหยุดได้สะอาดผ่าน lifecycle กลาง
- **ปลอดภัยไว้ก่อน** — ตรวจ `status.json` (`ready` / `maintenance` / `disabled`) และตรวจ SHA-256 ของทุก module ก่อนรัน

## 🎮 เกมที่รองรับ

| เกม | Place ID | สถานะ |
| --- | --- | --- |
| **Anime Vanguards** | `16146832113` (lobby) / `16277809958` (match) | ✅ ใช้งานได้ — เกมหลักที่พัฒนาอยู่ |
| Anime Expeditions | `84515722934860` | 🧱 placeholder (โครงพร้อม ยังไม่มีฟีเจอร์เล่นเกม) |

> การรองรับหมายถึงตรวจเกมและโหลด module ถูกต้อง ไม่ได้รับรองทุกแมพหรือทุก executor

## 🚀 วิธีใช้งาน

### 1. เตรียมตัว

- Executor ที่มี `loadstring` และ HTTP (ทดสอบหลักบน **Potassium / Windows**)
- ถ้าต้องการให้จำการตั้งค่าข้ามรอบ ต้องมี `readfile` `writefile` `isfile` `isfolder` `makefolder` ครบ (ถ้าไม่มี UI ยังใช้ได้แต่ไม่บันทึก)

### 2. รันสคริปต์

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/phiraphatdev/ViperHub-NextGen/main/dist/loader.lua"))()
```

ฮับจะตรวจเกม ตรวจสถานะ ดาวน์โหลด module แล้วเปิดหน้าต่าง เมื่อโหลดครบทุกหน้าและทุกฟีเจอร์จะมีแจ้งเตือน **"Loaded: every page and feature is ready."**

### 3. ใช้งานหน้าต่าง

- **ซ่อน/แสดง** — ปุ่ม Open ที่ด้านบนจอ หรือกดปุ่มลัด (ตั้งได้ใน Settings) ผู้ใช้ PC ปิดปุ่ม Open ได้ด้วย *Show Open Button*
- **ธีม** — 14 ธีมของ ViperHub (ค่าเริ่มต้น Viper) สลับสดได้ใน Settings
- **แจ้งเตือน** — ฮับแจ้งผลสำคัญด้วย toast ของ WindUI (ปิดได้ใน Settings)
- **การตั้งค่า** — บันทึกอัตโนมัติ ไฟล์เดียวต่อเกมต่อผู้เล่น:

  ```
  workspace/ViperHubNextGen/<Game>_<Player>.json     เช่น AnimeVanguards_iMZulie.json
  ```

## 🧭 ฟีเจอร์ของ Anime Vanguards

| แท็บ | ทำอะไร |
| --- | --- |
| **Dashboard** | การ์ดผู้เล่น สถานะฟีเจอร์แบบสด ยอดเงิน/ทรัพยากร |
| **Joiner** | Join ตามลำดับความสำคัญ: Stage, Legend Stage, Raid, Dungeon, Boss Event, Worldline, Boss Bounties, Challenge (Regular/Daily/Weekly), Rift · Team/Macro Equipper · Change Stage in Match · **Join status แสดงสิ่งที่กำลังทำอยู่แบบสด** · Joiner Report |
| **Odyssey: Adventure** | Auto Route Atlas (ตาม Priority) · Auto Basic Card · Character Card Priority รายตัว (สลับเมื่อมือเต็ม) · Auto Choose Unit Reward · Open Treasure Chests · Auto Boss Reward · **Auto Stitches Shop** (ซื้อของที่ต้องการ, reroll ตามจำนวน/ส่วน, Leave Shop) · Auto Buy Itches · Auto End Run ที่ชั้นที่เลือก · Auto Start New Run · Stage Failsafe — ทุก floor รอจนงานของ floor นั้นเสร็จก่อนไปต่อ |
| **Auto Play** | Auto Play ของเกม พร้อม Stage Preset Rules แยกตามโหมด |
| **Macro** | อัด/เล่น Macro · **Equip Macro's Units** (ถอดทั้งทีมแล้วใส่ใหม่ตามลำดับ Macro) · **Check Macro's Unit** (รายงานเป็นแจ้งเตือน) · Auto Equip |
| **Game** | ตั้งค่าเกมให้ตรงกัน และ Auto Back to Lobby |
| **Discord Webhook** | สรุปผลแมตช์ (Unit Contribution, รางวัล, ยอดเงิน), แจ้งยูนิตดรอป (Secret+ ping ได้), แจ้ง joiner / bounty / rift |
| **Misc** | Anti-AFK · Auto Reconnect (เมื่อหลุดจริง) · Re-run after teleport |
| **Settings / Diagnostics** | ธีม ปุ่มลัด ปุ่ม Open การแจ้งเตือน และข้อมูลวินิจฉัยแบบจำกัดขนาด |

รายละเอียดการยืนยันบนเกมจริงของแต่ละฟีเจอร์อยู่ใน [`docs/games/AnimeVanguards/UPDATES.md`](docs/games/AnimeVanguards/UPDATES.md)
(ฟีเจอร์ที่ยังไม่ผ่านการทดสอบบนเกมจริงจะระบุว่า *runtime pending*)

## 🛠️ สำหรับนักพัฒนา

ต้องมี Git, Node.js 22+ และ PowerShell — เครื่องมือ Luau / darklua / StyLua ดาวน์โหลดแบบ pin เวอร์ชันและตรวจ SHA-256 ให้เอง
(ไม่ต้องติดตั้ง npm package)

```powershell
./scripts/check.ps1            # format + type check + tests + build + ตรวจ hash
./scripts/build.ps1 -Release   # build สำหรับ release
./scripts/verify-release.ps1
./scripts/run-runtime.ps1      # เปิด local server สำหรับทดสอบบน executor
```

หรือเปิด `ViperHub.cmd` เพื่อใช้เมนูรวม (Build / Check / Runtime server / Release / Verify)

ทดสอบ local build บน executor:

```lua
loadstring(game:HttpGet("http://127.0.0.1:8766/runtime-smoke.lua"))()
```

โครงสร้างโดยย่อ

```
src/
  bootstrap/   โหลดเกม ตรวจสถานะ lifecycle
  platform/    ความสามารถ executor, FileStorage, task API
  ui/          WindUI adapter, ธีม, เอฟเฟกต์ (hover, dither, ambient)
  games/       AnimeVanguards/ · AnimeExpeditions/   (game module แยกกัน)
dist/          artifact ที่ build แล้ว (ห้ามแก้ด้วยมือ)
vendor/WindUI  WindUI ที่ pin checksum
tests/         unit / integration / runtime evidence
```

กติกา: แก้เฉพาะ `src/` แล้ว build ใหม่ · commit source + dist + manifest พร้อมกัน · logic ของเกมอยู่หลัง adapter ของเกมนั้นเท่านั้น

## 📚 เอกสาร

- [คู่มือผู้ใช้](docs/USER_MANUAL.md) · [Architecture](docs/ARCHITECTURE.md) · [เพิ่ม game module](docs/CONTRIBUTING.md)
- [Executor compatibility](docs/EXECUTORS.md) · [Testing](docs/TESTING.md) · [Release](docs/RELEASING.md) · [Security](docs/SECURITY.md)
- [Changelog](CHANGELOG.md) · [Third-party notices](THIRD_PARTY_NOTICES.md)

## ⚠️ ข้อควรทราบ

- ใช้เฉพาะ client/สภาพแวดล้อมที่คุณได้รับอนุญาตให้ทดสอบ
- ไม่มีระบบหลบ anti-cheat หรือ stealth hook
- ตรวจ `status.json` ก่อนใช้งาน: `ready` จึงโหลด ส่วน `disabled` / `maintenance` จะหยุดอย่างปลอดภัย
- UI ใช้ [WindUI](https://github.com/Footagesus/WindUI) (vendored) — ดูสิทธิ์การใช้งานใน THIRD_PARTY_NOTICES.md
