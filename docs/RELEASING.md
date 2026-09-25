# Releasing (single-commit workflow)

อัปเดต source และ tests ที่เกี่ยวข้อง แล้วรันคำสั่งใน PowerShell:

```powershell
./scripts/build.ps1 -Release
./scripts/check.ps1
./scripts/verify-release.ps1
```

`build.ps1 -Release` สแกน `src/games/*/Metadata.luau`, สร้าง bundle ใน `dist/`, sync `manifest.games` และ `manifest.artifacts` พร้อม hashes และเขียน `manifest.txt` ในครั้งเดียว `check.ps1` เรียก build ซ้ำโดยคง release mode ก่อนทดสอบ; `verify-release.ps1` จะปฏิเสธ development mode. ถ้ารัน `build.ps1` โดยไม่ใส่ `-Release` จะกลับเป็น development และ production loader จะไม่โหลด manifest นั้น. การเพิ่มเกมยังต้องเพิ่ม module ใน `src/games/Registry.luau` และสถานะใน `status.json` เพื่อให้ loader ตรวจ Place ID หรือ GameId ได้จริง

เมื่อผล local ผ่านและได้รับอนุญาตให้เผยแพร่ ให้ review diff แล้ว commit source, tests, docs, `dist/`, `manifest.json` และ `manifest.txt` **ใน commit เดียว** จากนั้น push และตรวจ GitHub Raw; tag/version ใช้เมื่อมีการตัดสินใจปล่อยเวอร์ชัน ไม่ต้องสร้าง source/artifact/metadata commits แยกกัน

`sourceCommit` และ `artifactRevision` เป็นข้อมูลเสริม ไม่ใช่ gate. Build ปัจจุบันตั้งทั้งคู่เป็น `null` เพื่อไม่อ้าง SHA เก่าหลังแก้ source. เมื่อ `artifactRevision` ไม่มีค่า loader อ่าน `main/dist/...`; ถ้าเป็น SHA 40 ตัวอักษรจะอ่าน revision นั้นแทน การใช้ `main` ช่วยให้อัปเดตเร็ว แต่ manifest, status และ dist อาจถูก CDN cache คนละเวลา จึงต้องตรวจ loader จริงหลัง push และปิดเกมเป็น `disabled` ใน `status.json` หากมีปัญหา

**Migration warning:** loader ที่เคยเผยแพร่ใน tag `v0.1.0` เป็นไฟล์ immutable และยังบังคับ SHA ทั้งสองฟิลด์; ทดสอบกับ `main` ปัจจุบันแล้วได้ `MANIFEST_INVALID` จริง ต้องใช้ URL ใหม่จาก `main/dist/loader.lua` (ซึ่งอ่านกลับ `ready` ในสองเกม) ห้ามอ้างว่า loader เก่ายังใช้ได้

Runtime test ผ่าน Roblox client และบันทึก observation ตาม `TESTING.md` ยัง **แนะนำอย่างยิ่ง** ก่อนเปิด `ready` แต่ไม่ใช่ JSON evidence gate ของ build/check. อย่าอ้างว่า executor, device, rejoin หรือ gameplay ทำงานจริงจาก mock tests หรือผล local เพียงอย่างเดียว

`verify-release.ps1` ตรวจ manifest/artifact hashes, path, size ในเครื่อง และ deterministic rebuild; ไม่ตรวจ Git history หรือยืนยันว่า GitHub Raw เผยแพร่แล้ว การทดสอบ production URL จึงเป็นขั้นแยก
คำสั่งนี้ตรวจ `manifest.txt` ให้ตรงกับ manifest ที่สร้างด้วย แต่ candidate `0.2.2` ยังไม่ใช่ release ที่ประกาศจนกว่าจะยืนยัน GitHub Raw และ runtime หลัง push
