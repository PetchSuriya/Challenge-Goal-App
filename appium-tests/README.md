# 📱 Appium Testing สำหรับ Challenge Goal App

## 🎯 ภาพรวม

โฟลเดอร์นี้ใช้สำหรับการทดสอบ Mobile App (Android) ด้วย **Appium** 

### เครื่องมือที่ใช้:
- **Appium** - Mobile testing framework
- **WebdriverIO** - Client library สำหรับควบคุม Appium
- **Mocha** - Test framework
- **Chai** - Assertion library

---

## 🚀 วิธีใช้งาน

### 1. ติดตั้ง Dependencies (ครั้งแรก)

```bash
cd appium-tests
npm install
```

### 2. Build Flutter APK

```bash
cd ..
flutter build apk --debug
```

APK จะอยู่ที่: `build/app/outputs/flutter-apk/app-debug.apk`

### 3. เปิด Android Emulator

```bash
flutter emulators --launch Pixel_9_Pro
# หรือ
flutter emulators --launch Medium_Phone_API_36.1
```

### 4. เปิด Appium Server (Terminal ใหม่)

```bash
appium
```

ต้องเห็นข้อความ: `Appium REST http interface listener started on http://0.0.0.0:4723`

### 5. รัน Tests (Terminal ใหม่)

**รันทุก tests:**
```bash
cd appium-tests
npm test
```

**รัน Android tests เท่านั้น:**
```bash
npm run test:android
```

**รันเฉพาะ Login test:**
```bash
npm run test:login
```

---

## 📁 โครงสร้างไฟล์

```
appium-tests/
├── package.json          # Dependencies และ scripts
├── config.js             # Appium configuration
├── test/
│   ├── android/
│   │   └── login.spec.js # Login test cases
│   └── screenshots/      # Screenshots จากการรัน tests
└── README.md            # คู่มือนี้
```

---

## 📝 การเขียน Test

### ตัวอย่าง Test Structure:

```javascript
const { remote } = require('webdriverio');
const { androidCapabilities, serverConfig } = require('../../config');

describe('Feature Name Tests', function() {
  this.timeout(300000);
  let driver;

  before(async function() {
    driver = await remote({
      ...serverConfig,
      capabilities: androidCapabilities
    });
  });

  after(async function() {
    if (driver) {
      await driver.deleteSession();
    }
  });

  it('should do something', async function() {
    // Test code here
  });
});
```

---

## 🎯 การหา Elements ใน Flutter

Flutter ใช้ **Canvas rendering** ทำให้ยากต่อการหา elements

### วิธีแก้:

#### 1. **ใช้ Coordinates (Tap ตำแหน่ง)**
```javascript
await driver.touchAction([
  { action: 'tap', x: 200, y: 400 }
]);
```

#### 2. **ใช้ Text Content**
```javascript
const element = await driver.$('//*[contains(@text, "Login")]');
await element.click();
```

#### 3. **ใช้ Semantic Labels (แนะนำ)**

ใน Flutter ใช้ `Semantics` widget:
```dart
Semantics(
  label: 'login_button',
  child: ElevatedButton(...),
)
```

ใน Test:
```javascript
const button = await driver.$('//android.view.View[@content-desc="login_button"]');
await button.click();
```

#### 4. **ใช้ Resource ID**
```javascript
const element = await driver.$('android=new UiSelector().resourceId("com.example.bento:id/username")');
```

---

## 📸 Screenshots

Screenshots จะถูกบันทึกใน `test/screenshots/`:
- `login-page.png` - หน้า Login
- `credentials-filled.png` - หลังกรอก username/password
- `after-login.png` - หลัง login สำเร็จ
- `login-error.png` - ถ้าเกิด error

---

## 🔧 Configuration

แก้ไขใน `config.js`:

```javascript
const androidCapabilities = {
  platformName: 'Android',
  'appium:deviceName': 'YOUR_DEVICE_NAME',  // จาก flutter devices
  'appium:platformVersion': '16.0',         // Android version
  'appium:app': path.join(__dirname, '../build/app/outputs/flutter-apk/app-debug.apk'),
};
```

---

## 🐛 Debugging

### ดู Page Source:
```javascript
const pageSource = await driver.getPageSource();
console.log(pageSource);
```

### ดู Current Activity:
```javascript
const activity = await driver.getCurrentActivity();
console.log(activity);
```

### ถ่าย Screenshot:
```javascript
await driver.saveScreenshot('./debug.png');
```

### Pause เพื่อ inspect:
```javascript
await driver.pause(10000); // หยุด 10 วินาที
```

---

## ⚠️ ปัญหาที่พบบ่อย

### 1. **Appium ไม่เจอ app**
- ตรวจสอบว่า build APK แล้ว
- ตรวจสอบ path ใน `config.js`

### 2. **Element ไม่เจอ**
- Flutter ใช้ Canvas → ยากต่อการหา elements
- แนะนำใช้ Semantics labels หรือ coordinates

### 3. **Test timeout**
- เพิ่ม timeout: `this.timeout(600000)` (10 นาที)

### 4. **Emulator ช้า**
- ใช้ emulator ที่มี RAM เยอะกว่า
- ปิดโปรแกรมอื่นๆ

---

## 📚 Resources

- [Appium Documentation](http://appium.io/docs/en/latest/)
- [WebdriverIO Documentation](https://webdriver.io/)
- [Flutter Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [Appium Inspector](https://github.com/appium/appium-inspector) - ใช้ inspect elements

---

## 🎓 Tips

1. **ใช้ screenshots เยอะๆ** - ช่วยในการ debug
2. **ใช้ descriptive test names** - เข้าใจง่าย
3. **เพิ่ม console.log** - ติดตามว่า test ทำอะไรอยู่
4. **Test ทีละอันก่อน** - ง่ายกว่า
5. **ใช้ Appium Inspector** - เห็น element tree
