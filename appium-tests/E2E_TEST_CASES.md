# 📋 E2E Test Cases Design - Challenge Goal App

**Project:** Challenge Goal App (Bento)  
**Testing Tool:** Appium + WebdriverIO  
**Test Type:** End-to-End Testing  
**Platform:** Android  
**Created:** November 9, 2025

---

## 🎯 Test Objectives

ทดสอบ User Journey ทั้งหมดของแอพ ตั้งแต่ Register, Login, การจัดการ Goals, ระบบเพื่อน, Profile และ Costume/Avatar

---

## 📱 Features to Test

1. **Authentication** (Login, Register, Reset Password)
2. **Home/Dashboard** (Overview, Navigation)
3. **Goal Management** (Create, Edit, Delete, Complete)
4. **Friends System** (Add, Remove, View Friends' Goals)
5. **Profile** (View, Edit Profile)
6. **Costume/Avatar** (View, Select Avatar)

---

## 🧪 Test Suite 1: Authentication Flow

### TC-AUTH-001: User Registration
**Priority:** High  
**Precondition:** App installed, no existing user session

**Steps:**
1. Launch app
2. Navigate to Register page
3. Enter username: "testuser001"
4. Enter email: "testuser001@gmail.com"
5. Enter password: "Test@123456"
6. Enter confirm password: "Test@123456"
7. Tap Register button

**Expected Result:**
- Registration successful
- Navigate to Home page
- User session created in database
- Welcome message displayed

**Test Data:**
```json
{
  "username": "testuser001",
  "email": "testuser001@gmail.com",
  "password": "Test@123456"
}
```

---

### TC-AUTH-002: User Login (Valid Credentials)
**Priority:** High  
**Precondition:** User registered with credentials below

**Steps:**
1. Launch app
2. Enter username: "JohnDoe@gmail.com"
3. Enter password: "password123"
4. Tap Login button
5. Wait for navigation

**Expected Result:**
- Login successful
- Navigate to Home page
- Session token stored
- User data loaded

**Test Data:**
```json
{
  "username": "JohnDoe@gmail.com",
  "password": "password123"
}
```

---

### TC-AUTH-003: User Login (Invalid Credentials)
**Priority:** High  
**Precondition:** App launched

**Steps:**
1. Launch app
2. Enter username: "invalid@test.com"
3. Enter password: "wrongpassword"
4. Tap Login button

**Expected Result:**
- Login failed
- Error message displayed: "Invalid username or password"
- Stay on Login page
- No session created

---

### TC-AUTH-004: Logout Flow
**Priority:** Medium  
**Precondition:** User logged in

**Steps:**
1. Navigate to Profile page
2. Scroll to bottom
3. Tap Logout button
4. Confirm logout (if confirmation dialog appears)

**Expected Result:**
- Logout successful
- Navigate to Login page
- Session cleared
- Cannot access protected pages

---

## 🧪 Test Suite 2: Goal Management

### TC-GOAL-001: Create New Goal (Basic)
**Priority:** High  
**Precondition:** User logged in

**Steps:**
1. Navigate to Goals page
2. Tap "Create Goal" button
3. Enter title: "ออกกำลังกายทุกวัน"
4. Enter description: "วิ่ง 5 กิโลเมตร ทุกเช้า"
5. Select category: "Health & Fitness"
6. Set target: "30 วัน"
7. Set end date: "2025-12-31"
8. Tap Save button

**Expected Result:**
- Goal created successfully
- Goal appears in Goals list
- Goal stored in database
- Success message displayed
- Navigate back to Goals page

**Test Data:**
```json
{
  "title": "ออกกำลังกายทุกวัน",
  "description": "วิ่ง 5 กิโลเมตร ทุกเช้า",
  "category": "Health & Fitness",
  "target": 30,
  "endDate": "2025-12-31"
}
```

---

### TC-GOAL-002: Create Goal with Image
**Priority:** Medium  
**Precondition:** User logged in

**Steps:**
1. Navigate to Goals page
2. Tap "Create Goal" button
3. Fill goal details (same as TC-GOAL-001)
4. Tap "Add Image" button
5. Select image from gallery/camera
6. Tap Save button

**Expected Result:**
- Goal created with image
- Image displayed in goal card
- Image uploaded to server
- Image path stored in database

---

### TC-GOAL-003: View Goal Details
**Priority:** High  
**Precondition:** At least one goal exists

**Steps:**
1. Navigate to Goals page
2. Tap on a goal card
3. View goal details page

**Expected Result:**
- Goal details displayed correctly:
  - Title
  - Description
  - Category
  - Progress percentage
  - Start date
  - End date
  - Image (if exists)
- Update Progress button visible
- Edit button visible
- Delete button visible

---

### TC-GOAL-004: Update Goal Progress
**Priority:** High  
**Precondition:** User has an active goal

**Steps:**
1. Navigate to Goal Details page
2. Tap "Update Progress" button
3. Enter progress: "5 km completed"
4. Tap Submit button

**Expected Result:**
- Progress updated successfully
- Progress bar updated
- Progress history recorded
- Timestamp stored
- Success notification shown

---

### TC-GOAL-005: Edit Existing Goal
**Priority:** Medium  
**Precondition:** User has at least one goal

**Steps:**
1. Navigate to Goal Details page
2. Tap Edit button
3. Modify title: "ออกกำลังกายทุกวัน (แก้ไข)"
4. Modify description: "วิ่ง 7 กิโลเมตร ทุกเช้า"
5. Tap Save button

**Expected Result:**
- Goal updated successfully
- Changes reflected in Goals list
- Database updated
- Edit history recorded

---

### TC-GOAL-006: Delete Goal
**Priority:** Medium  
**Precondition:** User has at least one goal

**Steps:**
1. Navigate to Goal Details page
2. Tap Delete button
3. Confirm deletion in dialog

**Expected Result:**
- Goal deleted successfully
- Goal removed from list
- Database record removed
- Navigate back to Goals page
- Confirmation message shown

---

### TC-GOAL-007: Complete Goal
**Priority:** High  
**Precondition:** User has a goal with 100% progress

**Steps:**
1. Navigate to Goal Details page
2. Tap "Mark as Complete" button
3. Confirm completion

**Expected Result:**
- Goal marked as completed
- Goal status changed to "Completed"
- Completion date recorded
- Achievement notification shown
- Goal moved to "Completed" section

---

## 🧪 Test Suite 3: Friends System

### TC-FRIEND-001: Add Friend by Username
**Priority:** High  
**Precondition:** User logged in, target user exists

**Steps:**
1. Navigate to Friends page
2. Tap "Add Friend" button
3. Enter username: "JaneDoe123"
4. Tap Search button
5. Tap Add button on search result
6. Confirm friend request

**Expected Result:**
- Friend request sent
- Request stored in database
- Notification sent to target user
- Success message shown
- User appears in "Pending" list

**Test Data:**
```json
{
  "targetUsername": "JaneDoe123"
}
```

---

### TC-FRIEND-002: Accept Friend Request
**Priority:** High  
**Precondition:** User has pending friend request

**Steps:**
1. Navigate to Friends page
2. Switch to "Requests" tab
3. Find pending request
4. Tap Accept button

**Expected Result:**
- Friend request accepted
- Users become friends
- Both users can see each other's goals
- Friend appears in "Friends" list
- Request removed from "Pending"

---

### TC-FRIEND-003: Reject Friend Request
**Priority:** Medium  
**Precondition:** User has pending friend request

**Steps:**
1. Navigate to Friends page
2. Switch to "Requests" tab
3. Find pending request
4. Tap Reject button
5. Confirm rejection

**Expected Result:**
- Friend request rejected
- Request removed from list
- Database updated
- No friendship created

---

### TC-FRIEND-004: View Friend's Goals
**Priority:** High  
**Precondition:** User has at least one friend with goals

**Steps:**
1. Navigate to Friends page
2. Tap on a friend's card
3. View friend's goals page

**Expected Result:**
- Friend's goals displayed
- Can view goal details
- Can support/cheer friend's goals
- Cannot edit friend's goals
- Friendship status shown

---

### TC-FRIEND-005: Remove Friend
**Priority:** Medium  
**Precondition:** User has at least one friend

**Steps:**
1. Navigate to Friends page
2. Long press on friend's card (or tap options)
3. Select "Remove Friend"
4. Confirm removal

**Expected Result:**
- Friend removed successfully
- Friendship deleted from database
- Friend removed from list
- Can no longer view friend's goals
- Confirmation message shown

---

## 🧪 Test Suite 4: Profile & Settings

### TC-PROFILE-001: View Profile
**Priority:** Medium  
**Precondition:** User logged in

**Steps:**
1. Navigate to Profile page
2. View profile information

**Expected Result:**
- Profile displayed correctly:
  - Avatar/Profile picture
  - Username
  - Email
  - Bio (if exists)
  - Goals count
  - Friends count
  - Join date

---

### TC-PROFILE-002: Edit Profile Information
**Priority:** Medium  
**Precondition:** User logged in

**Steps:**
1. Navigate to Profile page
2. Tap Edit button
3. Modify bio: "นักวิ่งมาราธอน ชอบท้าทายตัวเอง"
4. Modify display name: "John Runner"
5. Tap Save button

**Expected Result:**
- Profile updated successfully
- Changes reflected immediately
- Database updated
- Success message shown

**Test Data:**
```json
{
  "bio": "นักวิ่งมาราธอน ชอบท้าทายตัวเอง",
  "displayName": "John Runner"
}
```

---

### TC-PROFILE-003: Change Profile Picture
**Priority:** Low  
**Precondition:** User logged in

**Steps:**
1. Navigate to Profile page
2. Tap on profile picture
3. Select "Change Photo"
4. Select image from gallery
5. Crop/adjust image (if applicable)
6. Confirm selection

**Expected Result:**
- Profile picture updated
- Image uploaded to server
- New image displayed
- Old image replaced

---

### TC-PROFILE-004: Change Password
**Priority:** High  
**Precondition:** User logged in

**Steps:**
1. Navigate to Profile page
2. Tap "Change Password"
3. Enter current password: "password123"
4. Enter new password: "NewPass@456"
5. Confirm new password: "NewPass@456"
6. Tap Save button

**Expected Result:**
- Password changed successfully
- New password saved (hashed)
- Can login with new password
- Session maintained
- Success message shown

---

## 🧪 Test Suite 5: Costume/Avatar System

### TC-AVATAR-001: View Available Avatars
**Priority:** Low  
**Precondition:** User logged in

**Steps:**
1. Navigate to Profile page
2. Tap "Customize Avatar"
3. View avatar selection page

**Expected Result:**
- Avatar gallery displayed
- Shows locked/unlocked avatars
- Shows avatar requirements
- Shows current avatar highlighted

---

### TC-AVATAR-002: Select New Avatar
**Priority:** Low  
**Precondition:** User has unlocked avatars

**Steps:**
1. Navigate to Avatar page
2. Tap on unlocked avatar
3. Preview avatar
4. Tap "Use This Avatar"

**Expected Result:**
- Avatar selected successfully
- Profile picture updated
- Avatar stored in database
- Preview updated

---

## 🧪 Test Suite 6: Home/Dashboard Integration

### TC-HOME-001: View Dashboard Overview
**Priority:** High  
**Precondition:** User logged in with existing data

**Steps:**
1. Login to app
2. Land on Home page
3. View dashboard content

**Expected Result:**
- Dashboard displays:
  - Welcome message with username
  - Active goals count
  - Completed goals count
  - Friends count
  - Recent activities
  - Quick actions (Create Goal, Add Friend)

---

### TC-HOME-002: Navigate Between Tabs
**Priority:** High  
**Precondition:** User logged in

**Steps:**
1. Start at Home tab
2. Tap Goals tab
3. Tap Friends tab
4. Tap Profile tab
5. Tap Home tab again

**Expected Result:**
- Smooth navigation between tabs
- Each page loads correctly
- State preserved when returning
- Bottom navigation highlights active tab

---

## 🧪 Test Suite 7: Complete User Journey (Critical Path)

### TC-JOURNEY-001: Complete New User Flow
**Priority:** Critical  
**Precondition:** Fresh app install

**Full Journey:**
1. ✅ Register new account
2. ✅ Login successfully
3. ✅ Create first goal
4. ✅ Update goal progress
5. ✅ Add a friend
6. ✅ View friend's goals
7. ✅ Complete goal
8. ✅ Update profile
9. ✅ Logout

**Expected Result:**
- All steps complete successfully
- Data persists across sessions
- No crashes or errors
- Smooth user experience

**Duration:** ~5-7 minutes

---

## 📊 Test Metrics

### Coverage Goals:
- **Critical Paths:** 100%
- **High Priority:** 90%
- **Medium Priority:** 70%
- **Low Priority:** 50%

### Test Summary:
- **Total Test Cases:** 27
- **Authentication:** 4 cases
- **Goal Management:** 7 cases
- **Friends System:** 5 cases
- **Profile:** 4 cases
- **Avatar:** 2 cases
- **Home/Dashboard:** 2 cases
- **User Journey:** 1 case (critical path)
- **Integration:** 2 cases

### Test Distribution:
- **Critical:** 1 (4%)
- **High:** 13 (48%)
- **Medium:** 10 (37%)
- **Low:** 3 (11%)

---

## 🔧 Test Environment

**Required:**
- Android Emulator (API 30+) or Physical Device
- Appium Server running
- Backend Server running (http://localhost:3000)
- Test Database with sample data

**Test Users:**
```json
{
  "testuser001": {
    "email": "testuser001@gmail.com",
    "password": "Test@123456"
  },
  "JohnDoe": {
    "email": "JohnDoe@gmail.com",
    "password": "password123"
  },
  "JaneDoe123": {
    "email": "JaneDoe123@gmail.com",
    "password": "password123"
  }
}
```

---

## 📝 Notes

1. **Screenshots:** Capture screenshots at key steps for debugging
2. **Timing:** Add proper waits for async operations
3. **Data Cleanup:** Reset test data after each test suite
4. **Error Handling:** Catch and log all errors with context
5. **Reporting:** Generate HTML reports with pass/fail status

---

## 🚀 Execution Priority

**Phase 1 (Critical - Run Always):**
- TC-JOURNEY-001 (Complete User Journey)
- TC-AUTH-002 (Login)
- TC-GOAL-001 (Create Goal)
- TC-HOME-002 (Navigation)

**Phase 2 (High Priority - Daily):**
- All High priority test cases

**Phase 3 (Medium Priority - Weekly):**
- All Medium priority test cases

**Phase 4 (Low Priority - Monthly):**
- All Low priority test cases

---

**End of Test Cases Design**
