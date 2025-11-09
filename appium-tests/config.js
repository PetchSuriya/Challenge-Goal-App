/**
 * Appium Configuration
 * สำหรับ Android Testing ของ Challenge Goal App
 */

const path = require('path');

// Android Capabilities
const androidCapabilities = {
  platformName: 'Android',
  'appium:platformVersion': '16.0', // Android version ของ emulator
  'appium:deviceName': 'sdk gphone16k x86 64', // Device name จาก flutter devices
  'appium:automationName': 'UiAutomator2',
  
  // ใช้ APK ที่ build แล้ว
  'appium:app': path.join(__dirname, '../build/app/outputs/flutter-apk/app-debug.apk'),
  
  // หรือใช้ package name ถ้า app ติดตั้งอยู่แล้ว
  'appium:appPackage': 'com.example.bento',
  'appium:appActivity': 'com.example.bento.MainActivity',
  
  // ไม่ต้อง reset app ทุกครั้ง (เร็วกว่า)
  'appium:noReset': true,
  'appium:fullReset': false,
  
  // Timeouts
  'appium:newCommandTimeout': 300,
  'appium:androidInstallTimeout': 90000,
};

// Appium Server URL
const serverConfig = {
  protocol: 'http',
  hostname: 'localhost',
  port: 4723, // Default Appium port
  path: '/',
};

module.exports = {
  androidCapabilities,
  serverConfig,
};
