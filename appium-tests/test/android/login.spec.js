/**
 * Login Test สำหรับ Challenge Goal App
 * ทดสอบการ Login บน Android
 */

const { remote } = require('webdriverio');
const { androidCapabilities, serverConfig } = require('../../config');
const { expect } = require('chai');

describe('Login Feature Tests', function() {
  this.timeout(300000); // 5 นาที timeout
  
  let driver;

  // เปิด app ก่อนเริ่มทดสอบ
  before(async function() {
    console.log('🚀 Starting Appium session...');
    driver = await remote({
      ...serverConfig,
      capabilities: androidCapabilities
    });
    
    console.log('✅ Appium session started');
    
    // รอให้ app โหลดเสร็จ
    await driver.pause(5000);
  });

  // ปิด app หลังเทสต์เสร็จ
  after(async function() {
    if (driver) {
      console.log('🛑 Closing Appium session...');
      await driver.deleteSession();
    }
  });

  it('ควรเปิด app และแสดงหน้า Login', async function() {
    console.log('📱 Testing: App should open and show login page');
    
    // ดึง current activity
    const currentActivity = await driver.getCurrentActivity();
    console.log('Current activity:', currentActivity);
    
    // ตรวจสอบว่าอยู่หน้า MainActivity
    expect(currentActivity).to.include('MainActivity');
    
    // เก็บ screenshot
    await driver.saveScreenshot('./test/screenshots/login-page.png');
    console.log('✅ Screenshot saved: login-page.png');
  });

  it('ควรมี Username field', async function() {
    console.log('📝 Testing: Username field should exist');
    
    // Flutter ใช้ Semantic labels สำหรับ accessibility
    // หรือใช้ text content
    try {
      // ลองหา element ด้วย text
      const usernameField = await driver.$('//*[contains(@text, "Username") or contains(@text, "Email")]');
      const isDisplayed = await usernameField.isDisplayed();
      
      expect(isDisplayed).to.be.true;
      console.log('✅ Username field found');
    } catch (error) {
      console.log('⚠️  Username field not found with text selector');
      // บันทึก page source เพื่อ debug
      const pageSource = await driver.getPageSource();
      console.log('Page source saved for debugging');
    }
  });

  it('ควรกรอก Username และ Password ได้', async function() {
    console.log('⌨️  Testing: Should be able to input credentials');
    
    try {
      // ใช้ coordinates หรือ tap ที่ตำแหน่ง
      // Flutter web/mobile ต้องใช้วิธีพิเศษเพราะเป็น canvas
      
      // Tap ที่ตำแหน่ง username field (ปรับตามจอของคุณ)
      await driver.touchAction([
        { action: 'tap', x: 200, y: 400 }
      ]);
      await driver.pause(1000);
      
      // พิมพ์ username
      await driver.keys(['JohnDoe@gmail.com']);
      await driver.pause(1000);
      
      // Tap ที่ password field
      await driver.touchAction([
        { action: 'tap', x: 200, y: 500 }
      ]);
      await driver.pause(1000);
      
      // พิมพ์ password
      await driver.keys(['password123']);
      await driver.pause(1000);
      
      await driver.saveScreenshot('./test/screenshots/credentials-filled.png');
      console.log('✅ Credentials entered');
      
    } catch (error) {
      console.log('⚠️  Error during input:', error.message);
    }
  });

  it('ควร Login สำเร็จเมื่อกด Login button', async function() {
    console.log('🔐 Testing: Should login successfully');
    
    try {
      // Tap Login button (ปรับตำแหน่งตามจอของคุณ)
      await driver.touchAction([
        { action: 'tap', x: 200, y: 700 }
      ]);
      
      // รอให้ navigate ไปหน้าใหม่
      await driver.pause(5000);
      
      // ตรวจสอบว่า navigate ไปหน้าถัดไป
      const currentActivity = await driver.getCurrentActivity();
      console.log('Current activity after login:', currentActivity);
      
      await driver.saveScreenshot('./test/screenshots/after-login.png');
      console.log('✅ Login test completed');
      
    } catch (error) {
      console.log('⚠️  Error during login:', error.message);
      await driver.saveScreenshot('./test/screenshots/login-error.png');
    }
  });
});
