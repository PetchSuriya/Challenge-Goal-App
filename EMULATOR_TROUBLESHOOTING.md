# วิธีแก้ปัญหา Android Emulator จอดำ

## ขั้นตอนที่ 1: ตั้งค่า Environment Variables ถาวร
1. กด Windows + R, พิมพ์ sysdm.cpl
2. Advanced > Environment Variables
3. เพิ่ม System Variables:
   - ANDROID_HOME = C:\Users\user\AppData\Local\Android\sdk
   - ANDROID_SDK_ROOT = C:\Users\user\AppData\Local\Android\sdk

## ขั้นตอนที่ 2: ปิด Hyper-V (ใน PowerShell Admin)
```powershell
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

## ขั้นตอนที่ 3: เปิด Windows Hypervisor Platform
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform
```

## ขั้นตอนที่ 4: รีสตาร์ทเครื่อง

## ขั้นตอนที่ 5: สร้าง AVD ใหม่ใน Android Studio
1. เปิด Android Studio
2. AVD Manager > Create Virtual Device
3. เลือก Pixel 9 API 35
4. ตั้งค่า Graphics: Hardware - GLES 2.0

## คำสั่งรัน Emulator
```bash
# แบบปกติ
flutter emulators --launch Pixel_9_API_35

# แบบ Debug
& "C:\Users\user\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu host -no-audio

# แบบ Software Rendering (ถ้า GPU มีปัญหา)
& "C:\Users\user\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_9_API_35 -gpu swiftshader_indirect -no-audio
```

## หมายเหตุ
- จอดำมักเกิดจาก GPU Driver ไม่เข้ากัน
- Chrome web development เป็นทางเลือกที่ดีที่สุดขณะนี้
- สำหรับการ deploy จริง ใช้ physical device จะดีกว่า