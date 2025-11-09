# 🚀 Quick Reference - E2E Tests

## 📁 ไฟล์ที่สร้าง

```
appium-tests/
├── E2E_TEST_CASES.md          ✅ Test Cases Design (27 cases)
├── E2E_TESTS_README.md        ✅ คู่มือใช้งานแบบเต็ม
├── QUICK_REFERENCE.md         ✅ ไฟล์นี้
│
├── test/android/
│   ├── login.spec.js          ✅ Basic Login (4 tests)
│   ├── auth.spec.js           ✅ Authentication (3 tests)
│   ├── goals.spec.js          ✅ Goal Management (5 tests)
│   ├── friends.spec.js        ✅ Friends System (3 tests)
│   └── journey.spec.js        ✅ Complete Journey (1 test, 9 steps) ⭐
│
└── test/screenshots/          📸 Screenshots จะถูกสร้างที่นี่
```

---

## ⚡ รันเทสแบบเร็ว

### 1. เตรียม Environment (รันครั้งเดียว)

```bash
# Terminal 1: Backend
cd Server && node index.js

# Terminal 2: Emulator
flutter emulators --launch Pixel_9_Pro

# Terminal 3: Appium
appium
```

### 2. Build APK

```bash
# Terminal 4
flutter build apk --debug
```

### 3. รันเทส

```bash
cd appium-tests

# เทสแต่ละชุด
npm run test:auth        # 3 tests, ~3 min
npm run test:goals       # 5 tests, ~5 min
npm run test:friends     # 3 tests, ~3 min
npm run test:journey     # 1 test (9 steps), ~7 min ⭐

# เทสทั้งหมด
npm run test:all         # 16 tests, ~20 min
```

---

## 📋 Test Suites สรุป

| File | Tests | Duration | Priority |
|------|-------|----------|----------|
| auth.spec.js | 3 | 3 min | High |
| goals.spec.js | 5 | 5 min | High |
| friends.spec.js | 3 | 3 min | Medium |
| journey.spec.js | 1 (9 steps) | 7 min | **Critical** ⭐ |

---

## 🎯 Test Cases แต่ละไฟล์

### auth.spec.js
- ✅ Login with valid credentials
- ✅ Login with invalid credentials
- ✅ Logout flow

### goals.spec.js
- ✅ Create new goal
- ✅ View goal details
- ✅ Update goal progress
- ✅ Edit goal
- ✅ Delete goal

### friends.spec.js
- ✅ Add friend by username
- ✅ View friend's goals
- ✅ Remove friend

### journey.spec.js ⭐
- ✅ Complete 9-step user journey:
  1. Register
  2. Login
  3. Create goal
  4. Update progress
  5. Add friend
  6. View dashboard
  7. Update profile
  8. Complete goal
  9. Logout

---

## 🎨 สิ่งที่ทำใน Test

### E2E Testing แบบเต็มรูปแบบ:

✅ **UI Testing** - ทดสอบหน้าจอและ navigation  
✅ **User Flow** - ทดสอบ user journey จริง  
✅ **Backend Integration** - เรียก API จริง  
✅ **Database** - บันทึกข้อมูลจริง  
✅ **State Management** - ทดสอบ state changes  
✅ **Screenshots** - จับภาพทุกขั้นตอน

---

## 📸 Screenshots ตัวอย่าง

```
test/screenshots/
├── auth-001-login-page.png
├── auth-002-credentials-filled.png
├── auth-003-after-login.png
├── goal-001-goals-page.png
├── goal-002-create-form.png
├── goal-003-form-filled.png
├── friend-001-friends-page.png
├── journey-001-register-page.png
├── journey-015-logged-out.png
└── *-error-*.png
```

---

## 🔧 Test Data ที่ต้องมี

### Users ใน Database:
```
JohnDoe@gmail.com / password123
JaneDoe123@gmail.com / password123
```

### Journey Test:
- สร้าง user ใหม่อัตโนมัติ (timestamp-based)
- ไม่ต้องเตรียมข้อมูล

---

## ⚠️ Troubleshooting เร็ว

### Tests ล้มเหลว?

```bash
# 1. เช็ค Backend
curl http://localhost:3000/api/health

# 2. เช็ค Emulator
flutter devices

# 3. เช็ค Appium
curl http://localhost:4723/status

# 4. ดู Screenshots
ls -lh test/screenshots/
```

### Element Not Found?
- ดู screenshots
- อัพเดท XPath selectors
- เพิ่ม wait time

### Tests ช้า?
- ปกติ (Appium + Flutter ช้าตามธรรมชาติ)
- รอ ~20 วินาทีต่อ test case

---

## 💡 Tips

### รัน 1 test เดียว:
```bash
npm run test:auth -- --grep "Valid Login"
```

### Debug mode:
```javascript
await driver.pause(60000); // หยุด 1 นาทีเพื่อดู app
```

### ดู Page Source:
```javascript
const source = await driver.getPageSource();
console.log(source);
```

---

## 📚 อ่านเพิ่มเติม

- **E2E_TEST_CASES.md** - Test cases ละเอียด
- **E2E_TESTS_README.md** - คู่มือเต็ม
- **README.md** - Appium setup guide

---

## ✅ Checklist

ก่อนรันเทส ต้องมี:
- [x] Backend running (port 3000)
- [x] Emulator running
- [x] Appium running (port 4723)
- [x] APK built
- [x] npm install done

---

## 🎯 แนะนำการใช้งาน

### วันแรก:
```bash
npm run test:journey  # ดู complete flow
```

### ประจำวัน:
```bash
npm run test:auth     # เทส login/logout
npm run test:goals    # เทส features หลัก
```

### ก่อน Deploy:
```bash
npm run test:all      # เทสทั้งหมด
```

---

**สร้างโดย:** GitHub Copilot  
**วันที่:** November 9, 2025  
**เวอร์ชัน:** 1.0.0

🚀 Happy Testing!
