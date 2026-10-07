# ViperHub NextGen — แผนแก้ไข Phase 4: เก็บตกบั๊ก Keybind Reset, Window Cleanup Leak และ Notification ซ้อน (5 Items)

เอกสารนี้สำหรับสั่งให้ AI ดำเนินการแก้ไขบั๊กซ่อนเร้น 5 จุดที่พบจากการตรวจสอบโค้ดหลังจบ Phase 3

---

## รายการปัญหาทั้ง 5 ข้อที่ต้องแก้ไข (Phase 4 Tasks)

### 1. [บั๊ก Keybind ใน `Settings.luau` & `ConfigStore.luau`] กดปุ่มที่ไม่อนุญาต (หรือ `Alt+Tab`) แล้วค่าปุ่มลัดเดิมถูกรีเซ็ตเป็น `RightShift` แถมป้ายชื่อบน UI ค้างไม่ตรงกับค่าจริง
* **ไฟล์:** `src/ui/pages/Settings.luau` (บรรทัด 11–14, 74–80) และ `src/config/Schema.luau` / `src/config/ConfigStore.luau`
* **ปัญหาปัจจุบัน:**
  1. หากผู้ใช้ตั้งปุ่มลัดเป็น `F4` อยู่ แล้วเผลอกดปุ่มที่ไม่อยู่ใน `Schema.KEYS` (เช่น `LeftAlt` ตอนกด `Alt+Tab` หรือปุ่มตัวอักษรอื่น) ในขณะเปิด Picker ตัว `keyLabel:GetPropertyChangedSignal("Text")` จะส่งค่าที่ไม่ถูกต้องเข้า `store.update("toggleKey", value)`
  2. `ConfigStore.update` เรียก `Schema.decode(candidate)` ซึ่งเมื่อพบว่า `toggleKey` ไม่อยู่ใน `KEYS` จะไม่คงค่า `current.toggleKey` (`F4`) เดิมไว้ แต่จะรีเซ็ตกลับไปเป็น `Defaults.toggleKey` (`RightShift`) ทันที!
  3. นอกจากนี้ ใน `GetPropertyChangedSignal("Text")` (บรรทัด 77) ไม่ได้สั่ง `controls.toggleKey:Set(store.get().toggleKey)` เพื่อคืนค่าข้อความบนป้าย UI ทำให้บนหน้าจอแสดงชื่อปุ่มที่ผิด (เช่น `"LeftAlt"`) ในขณะที่ปุ่มจริงข้างหลังถูกเปลี่ยนเป็น `"RightShift"`
* **แนวทางแก้ไข:**
  1. ใน `src/config/ConfigStore.luau` ฟังก์ชัน `update(key, value)`: หากฟิลด์ที่อัปเดตไม่ผ่านการตรวจสอบของ `Schema.decode` (เช่น `toggleKey` ไม่อยู่ในรายการที่อนุญาต) ให้คงค่า `current[key]` เดิมไว้แทนที่จะรีเซ็ตกลับเป็น `Defaults`
  2. ใน `src/ui/pages/Settings.luau` ฟังก์ชัน `applyToggleKey`: หลังจากอัปเดต `store` และ `window:SetToggleKey` แล้ว ให้ซิงค์ `if controls.toggleKey and controls.toggleKey.Value ~= store.get().toggleKey then controls.toggleKey:Set(store.get().toggleKey) end` เสมอ เพื่อให้ป้ายชื่อบน UI ตรงกับค่าใน `store` 100%

---

### 2. [ช่องโหว่ UI / Memory Leak ใน `WindUIAdapter.luau`] ตอนรันสคริปต์ซ้ำหรือเรียก `session.destroy()` ไม่ได้เรียก `window:Destroy()`
* **ไฟล์:** `src/ui/WindUIAdapter.luau` (บรรทัด 18–60)
* **ปัญหาปัจจุบัน:**
  * ใน `WindUIAdapter.own()` ลงทะเบียน Cleanup เพื่อลบ `ScreenGui`, `NotificationGui`, `DropdownGui`, `TooltipGui` แต่ใน `WindUIAdapter.create()` หลังจากสร้าง `window` แล้ว ไม่ได้ลงทะเบียน `window:Destroy()` เข้ากับ `context.cleanup`
  * ทำให้เมื่อสั่ง `session.destroy()` หรือรันสคริปต์ซ้ำ ตัว `ScreenGui` ถูกลบจริง แต่ออบเจกต์ `window` ของ WindUI ไม่ได้รัน `window:Destroy()` (ค่า `window.Destroyed` ยังเป็น `false`)
* **แนวทางแก้ไข:**
  * ใน `WindUIAdapter.create(library, context, config)`: ลงทะเบียน `context.cleanup.add` เพื่อเรียก `if window and not window.Destroyed and type(window.Destroy) == "function" then pcall(window.Destroy, window) end` (พร้อมป้องกันการเรียกซ้ำกับ `window:OnDestroy`)

---

### 3. [ปัญหา UX ใน `Main.luau`] เข้าแมพที่ไม่รองรับ (`Unsupported game`) แล้วเด้ง Notification ซ้อนกัน 2 ครั้งติดๆ กัน
* **ไฟล์:** `src/bootstrap/Main.luau` (บรรทัด 62–84)
* **ปัญหาปัจจุบัน:**
  * เมื่อแมพไม่รองรับ บรรทัด 64 สั่ง `notify("Unsupported game (name unavailable). Place: ...")` ทันที แล้วบรรทัด 68 สั่ง `spawnTask` ไปดึงชื่อแมพจาก `marketplaceService:GetProductInfo()` ซึ่งพอได้ชื่อแมพในอีก ~0.1 วินาทีถัดมาก็สั่ง `notify("Unsupported: <Name>")` ซ้ำอีกอัน ทำให้เด้งแจ้งเตือน 2 อันซ้อนกันทุกครั้ง
* **แนวทางแก้ไข:**
  * ให้พยายามดึงชื่อแมพจาก `marketplaceService:GetProductInfo(gameObject.PlaceId)` ภายใน `spawnTask` ก่อน (หรือรอผลลัพธ์ภายในเวลาสั้นๆ) แล้วแจ้งเตือนเพียง **ครั้งเดียว** (หากดึงชื่อแมพสำเร็จให้แสดงชื่อแมพเลย หากดึงไม่สำเร็จจึงแสดง `"Unsupported game (name unavailable). Place: ..."`)

---

### 4. [ความสอดคล้องของ Registry ใน `Main.luau`] บรรทัด 170 เช็กแค่ `metadata.placeIds` โดยไม่เช็ก `manifest.games[id].placeIds`
* **ไฟล์:** `src/bootstrap/Main.luau` (บรรทัด 170–176)
* **ปัญหาปัจจุบัน:**
  * บรรทัด 170 เขียนว่า `if not table.find(metadata.placeIds, gameObject.PlaceId) then` โดยเช็กแต่ตารางที่ฝังใน `loader.lua` ไม่ได้เช็ก `manifest.games[metadata.id].placeIds`
* **แนวทางแก้ไข:**
  * ปรับให้เช็กทั้ง `table.find(metadata.placeIds, gameObject.PlaceId)` และ `table.find(manifest.games[metadata.id].placeIds, gameObject.PlaceId)` ก่อนตรวจ `releaseUniverses`

---

### 5. [ปัญหา `manifest.json.mode` ใน `scripts/pipeline.mjs`] รัน `./scripts/build.ps1` แล้ว `manifest.json` ถูกเปลี่ยนจาก `"release"` เป็น `"development"`
* **ไฟล์:** `scripts/pipeline.mjs` (บรรทัด 54, 68) และ `manifest.json`
* **ปัญหาปัจจุบัน:**
  * ตอนนี้เมื่อรัน `./scripts/build.ps1` (โดยไม่ใส่ `-Release`) ตัว `pipeline.mjs` จะเปลี่ยน `manifest.json.mode` เป็น `"development"` ทันที ทำให้ไฟล์ `manifest.json` ที่เตรียม Commit ขึ้น GitHub กลายเป็น `"development"` แทนที่จะเป็น `"release"`
* **แนวทางแก้ไข:**
  * ใน `scripts/pipeline.mjs` ให้คงค่า `"mode": "release"` เป็นค่ามาตรฐานใน `manifest.json` (หรือให้ `build()` ตั้ง `manifest.mode = "release"` เป็นค่าเริ่มต้น เว้นแต่ส่ง `--development`) เพื่อให้รัน `./scripts/build.ps1` แล้วพร้อม Commit ขึ้น GitHub ได้ทันที

---

## เกณฑ์การตรวจสอบความถูกต้อง (Verification Criteria)

เมื่อแก้ไขครบทั้ง 5 ข้อและอัปเดตชุดทดสอบใน `tests/unit/run.luau` กับ `tests/integration/Bootstrap.luau` เรียบร้อยแล้ว ให้รันคำสั่งต่อไปนี้ใน PowerShell จนผ่าน 100%:

```powershell
./scripts/build.ps1
./scripts/check.ps1
```
