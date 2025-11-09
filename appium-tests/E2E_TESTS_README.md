# 🧪 E2E Testing Suite - Challenge Goal App

**สร้างเมื่อ:** November 9, 2025  
**Testing Framework:** Appium + WebdriverIO + Mocha  
**Platform:** Android

---

## 📋 Test Suites Overview

### ✅ ไฟล์ที่สร้างแล้ว:

1. **E2E_TEST_CASES.md** - Test Cases Design (27 test cases)
2. **login.spec.js** - Basic Login Tests (เดิม)
3. **auth.spec.js** - Authentication Tests (TC-AUTH-002 to TC-AUTH-004)
4. **goals.spec.js** - Goal Management Tests (TC-GOAL-001 to TC-GOAL-006)
5. **friends.spec.js** - Friends System Tests (TC-FRIEND-001 to TC-FRIEND-005)
6. **journey.spec.js** - Complete User Journey (TC-JOURNEY-001) ⭐ Critical Path

---

## 🎯 Test Coverage Summary

| Test Suite | Test Cases | Priority | Status |
|-----------|-----------|----------|--------|
| **Authentication** | 4 tests | High | ✅ Ready |
| **Goal Management** | 6 tests | High | ✅ Ready |
| **Friends System** | 3 tests | Medium | ✅ Ready |
| **Complete Journey** | 1 test (9 steps) | Critical | ✅ Ready |

**Total:** 14 automated test scenarios covering 27 test cases

---

## 🚀 Quick Start

### 1. Prerequisites

```bash
# ตรวจสอบว่าติดตั้งครบแล้ว
flutter --version
appium --version
npm --version

# ตรวจสอบ Android SDK
echo $ANDROID_HOME
```

### 2. เตรียม Environment

```bash
# Start Backend Server (Terminal 1)
cd Server
node index.js
# Server should be running on http://localhost:3000

# Start Android Emulator (Terminal 2)
flutter emulators --launch Pixel_9_Pro
# Wait for emulator to boot

# Start Appium Server (Terminal 3)
appium
# Server should be running on http://0.0.0.0:4723
```

### 3. Build APK

```bash
# Terminal 4
cd /path/to/Challenge-Goal-App
flutter build apk --debug
```

### 4. Run Tests

```bash
cd appium-tests

# รัน test suite เดียว
npm run test:auth        # Authentication tests
npm run test:goals       # Goal management tests
npm run test:friends     # Friends system tests
npm run test:journey     # Complete user journey ⭐

# รัน critical path tests
npm run test:critical

# รัน all tests
npm run test:all
```

---

## 📝 Test Scripts คำอธิบาย

### 🔐 auth.spec.js (Authentication E2E Tests)

**Test Cases:**
- ✅ TC-AUTH-002: Valid Login
- ✅ TC-AUTH-003: Invalid Login
- ✅ TC-AUTH-004: Logout Flow

**Duration:** ~3-4 minutes

**Run:**
```bash
npm run test:auth
```

**Expected Output:**
```
Authentication E2E Tests
  TC-AUTH-002: User Login (Valid Credentials)
    ✓ ควร Login สำเร็จด้วย credentials ที่ถูกต้อง
  TC-AUTH-003: User Login (Invalid Credentials)
    ✓ ควรแสดง error เมื่อ Login ด้วย credentials ผิด
  TC-AUTH-004: Logout Flow
    ✓ ควร Logout สำเร็จและกลับไปหน้า Login

3 passing (3m 45s)
```

---

### 🎯 goals.spec.js (Goal Management E2E Tests)

**Test Cases:**
- ✅ TC-GOAL-001: Create New Goal
- ✅ TC-GOAL-003: View Goal Details
- ✅ TC-GOAL-004: Update Goal Progress
- ✅ TC-GOAL-005: Edit Existing Goal
- ✅ TC-GOAL-006: Delete Goal

**Duration:** ~5-6 minutes

**Run:**
```bash
npm run test:goals
```

**Flow:**
1. Login
2. Navigate to Goals page
3. Create new goal
4. View goal details
5. Update progress
6. Edit goal
7. Delete goal

---

### 👥 friends.spec.js (Friends System E2E Tests)

**Test Cases:**
- ✅ TC-FRIEND-001: Add Friend by Username
- ✅ TC-FRIEND-004: View Friend's Goals
- ✅ TC-FRIEND-005: Remove Friend

**Duration:** ~3-4 minutes

**Run:**
```bash
npm run test:friends
```

**Flow:**
1. Login
2. Navigate to Friends page
3. Add friend
4. View friend's goals
5. Remove friend

---

### 🌟 journey.spec.js (Complete User Journey) ⭐ CRITICAL

**Test Case:** TC-JOURNEY-001

**9-Step Journey:**
1. ✅ Register new account
2. ✅ Login successfully
3. ✅ Create first goal
4. ✅ Update goal progress
5. ✅ Add a friend
6. ✅ View dashboard
7. ✅ Update profile
8. ✅ Complete goal
9. ✅ Logout

**Duration:** ~6-8 minutes

**Run:**
```bash
npm run test:journey
```

**Special Features:**
- Creates unique test user with timestamp
- Tests complete user flow from start to finish
- Captures 15+ screenshots throughout journey
- Most comprehensive E2E test

---

## 📸 Screenshots

All test screenshots are saved to:
```
appium-tests/test/screenshots/
```

**Naming Convention:**
- `auth-XXX-description.png` - Authentication tests
- `goal-XXX-description.png` - Goal tests
- `friend-XXX-description.png` - Friend tests
- `journey-XXX-description.png` - Journey tests
- `*-error-*.png` - Error screenshots

---

## 📊 Test Reports

### Running Tests with Detailed Output

```bash
# Run with verbose logging
npm run test:journey -- --reporter spec

# Run specific test
npm run test:auth -- --grep "Valid Login"

# Save output to file
npm run test:all > test-results.txt 2>&1
```

---

## 🔧 Configuration

### config.js

```javascript
{
  platformName: 'Android',
  platformVersion: '16.0',
  deviceName: 'sdk gphone16k x86 64',
  automationName: 'UiAutomator2',
  app: 'path/to/app-debug.apk',
  appPackage: 'com.example.bento',
  appActivity: 'com.example.bento.MainActivity',
  noReset: true  // Keep app data between tests
}
```

---

## ⚠️ Known Issues & Solutions

### Issue 1: touchAction API Deprecated
**Problem:** HTTP 404 errors for touchAction commands

**Solution:** 
- Tests use fallback methods
- Future: Migrate to W3C Actions API

### Issue 2: Element Not Found
**Problem:** Flutter Canvas rendering makes elements hard to detect

**Solution:**
- Use content-desc attributes
- Use XPath with text/hint matching
- Add proper Semantic labels in Flutter code

### Issue 3: Timing Issues
**Problem:** Tests fail due to slow loading

**Solution:**
- Added `waitForDisplayed()` with timeouts
- Added `driver.pause()` for animations
- Increased test timeout to 300-600 seconds

---

## 🎯 Test Execution Strategy

### Phase 1: Daily (Critical Path)
```bash
npm run test:critical
```
- Complete User Journey
- Authentication Tests

**Duration:** ~10 minutes

### Phase 2: Before PR/Merge
```bash
npm run test:all
```
- All test suites
- Full coverage

**Duration:** ~20 minutes

### Phase 3: Weekly (Full Regression)
```bash
npm run test:all -- --reporter mochawesome
```
- All tests with HTML reports
- Performance metrics
- Screenshot review

---

## 📦 Test Data

### Test Users (Required in Database)

```json
{
  "JohnDoe@gmail.com": {
    "password": "password123",
    "role": "Main test user"
  },
  "JaneDoe123@gmail.com": {
    "password": "password123",
    "role": "Friend test user"
  }
}
```

### Dynamic Test Data

Journey test creates unique users:
```javascript
testuser1699999999@gmail.com
testuser1699999998@gmail.com
// timestamp-based usernames
```

---

## 🐛 Debugging

### View Page Source
```javascript
const pageSource = await driver.getPageSource();
console.log(pageSource);
```

### Check Current Activity
```javascript
const activity = await driver.getCurrentActivity();
console.log('Current activity:', activity);
```

### Interactive Debug
```javascript
it('debug test', async function() {
  await driver.pause(60000); // Pause for 1 minute
  // Manually inspect the app
});
```

### Appium Inspector
```bash
# Install Appium Inspector
# Download from: https://github.com/appium/appium-inspector

# Connect to: http://localhost:4723
# Use same capabilities as config.js
```

---

## 📚 Test Case Reference

See **E2E_TEST_CASES.md** for:
- Complete test case descriptions
- Test data
- Expected results
- Step-by-step procedures
- Priority levels

---

## 🔄 CI/CD Integration (Future)

### GitHub Actions Example
```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
      - name: Build APK
        run: flutter build apk --debug
      - name: Run E2E Tests
        run: |
          cd appium-tests
          npm install
          npm run test:critical
```

---

## 📞 Support

**Issues?**
- Check screenshots in `test/screenshots/`
- Review Appium logs
- Check Backend server is running
- Verify APK is built
- Ensure emulator is running

**Tips:**
- Run tests one at a time first
- Check element selectors match your UI
- Update XPath if UI changes
- Add more wait times if tests fail randomly

---

## ✅ Checklist Before Running Tests

- [ ] Backend server running (port 3000)
- [ ] Android emulator running
- [ ] Appium server running (port 4723)
- [ ] APK built (app-debug.apk)
- [ ] Test users exist in database
- [ ] npm dependencies installed
- [ ] ANDROID_HOME set correctly

---

**Happy Testing! 🚀**
