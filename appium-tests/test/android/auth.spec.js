/**
 * TC-AUTH-002 to TC-AUTH-004: Authentication Tests
 * ทดสอบ Login, Invalid Login, และ Logout
 */

const { remote } = require('webdriverio');
const { androidCapabilities, serverConfig } = require('../../config');
const { expect } = require('chai');

describe('Authentication E2E Tests', function() {
  this.timeout(300000); // 5 นาที
  
  let driver;

  before(async function() {
    console.log('🚀 Starting Appium session for Authentication Tests...');
    driver = await remote({
      ...serverConfig,
      capabilities: androidCapabilities
    });
    console.log('✅ Appium session started');
    await driver.pause(5000);
  });

  after(async function() {
    if (driver) {
      console.log('🛑 Closing Appium session...');
      await driver.deleteSession();
    }
  });

  describe('TC-AUTH-002: User Login (Valid Credentials)', function() {
    it('ควร Login สำเร็จด้วย credentials ที่ถูกต้อง', async function() {
      console.log('🔐 Testing: Valid Login Flow');
      
      // Verify we're on Login page
      const currentActivity = await driver.getCurrentActivity();
      expect(currentActivity).to.include('MainActivity');
      
      await driver.saveScreenshot('./test/screenshots/auth-001-login-page.png');
      
      try {
        // Find and fill Username field
        console.log('📝 Filling username...');
        const usernameField = await driver.$('//android.widget.EditText[contains(@text, "Username") or contains(@hint, "Username")]');
        await usernameField.waitForDisplayed({ timeout: 10000 });
        await usernameField.click();
        await usernameField.setValue('JohnDoe@gmail.com');
        await driver.pause(1000);
        
        // Find and fill Password field
        console.log('🔑 Filling password...');
        const passwordField = await driver.$('//android.widget.EditText[@password="true" or contains(@hint, "Password")]');
        await passwordField.waitForDisplayed({ timeout: 10000 });
        await passwordField.click();
        await passwordField.setValue('password123');
        await driver.pause(1000);
        
        await driver.saveScreenshot('./test/screenshots/auth-002-credentials-filled.png');
        
        // Tap Login button
        console.log('👆 Tapping Login button...');
        const loginButton = await driver.$('//android.widget.Button[contains(@content-desc, "Login")]');
        await loginButton.waitForDisplayed({ timeout: 10000 });
        await loginButton.click();
        
        // Wait for navigation
        console.log('⏳ Waiting for navigation...');
        await driver.pause(5000);
        
        await driver.saveScreenshot('./test/screenshots/auth-003-after-login.png');
        
        // Verify login success (should navigate away from Login page)
        const afterLoginActivity = await driver.getCurrentActivity();
        console.log('✅ After login activity:', afterLoginActivity);
        
        // Check if we can find Home page elements
        const pageSource = await driver.getPageSource();
        const isLoggedIn = pageSource.includes('Home') || 
                          pageSource.includes('Dashboard') || 
                          pageSource.includes('Goals') ||
                          !pageSource.includes('Login');
        
        expect(isLoggedIn).to.be.true;
        console.log('✅ Login successful - navigated to Home page');
        
      } catch (error) {
        console.error('❌ Login test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/auth-error-login.png');
        throw error;
      }
    });
  });

  describe('TC-AUTH-003: User Login (Invalid Credentials)', function() {
    it('ควรแสดง error เมื่อ Login ด้วย credentials ผิด', async function() {
      console.log('🚫 Testing: Invalid Login Flow');
      
      // Navigate back to Login page (if not already there)
      await driver.back();
      await driver.pause(2000);
      
      try {
        // Fill invalid credentials
        console.log('📝 Filling invalid credentials...');
        
        const usernameField = await driver.$('//android.widget.EditText[contains(@hint, "Username")]');
        await usernameField.waitForDisplayed({ timeout: 10000 });
        await usernameField.click();
        await usernameField.clearValue();
        await usernameField.setValue('invalid@test.com');
        await driver.pause(1000);
        
        const passwordField = await driver.$('//android.widget.EditText[@password="true"]');
        await passwordField.click();
        await passwordField.clearValue();
        await passwordField.setValue('wrongpassword');
        await driver.pause(1000);
        
        await driver.saveScreenshot('./test/screenshots/auth-004-invalid-credentials.png');
        
        // Tap Login button
        const loginButton = await driver.$('//android.widget.Button[contains(@content-desc, "Login")]');
        await loginButton.click();
        
        await driver.pause(3000);
        await driver.saveScreenshot('./test/screenshots/auth-005-error-message.png');
        
        // Verify error message or still on Login page
        const pageSource = await driver.getPageSource();
        const hasError = pageSource.includes('Invalid') || 
                        pageSource.includes('Error') ||
                        pageSource.includes('incorrect') ||
                        pageSource.includes('Username or Email');
        
        expect(hasError).to.be.true;
        console.log('✅ Error displayed correctly for invalid credentials');
        
      } catch (error) {
        console.error('❌ Invalid login test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/auth-error-invalid.png');
        throw error;
      }
    });
  });

  describe('TC-AUTH-004: Logout Flow', function() {
    it('ควร Logout สำเร็จและกลับไปหน้า Login', async function() {
      console.log('🚪 Testing: Logout Flow');
      
      // First login with valid credentials
      console.log('📝 Logging in first...');
      // Reuse login logic from TC-AUTH-002
      try {
        const usernameField = await driver.$('//android.widget.EditText[contains(@hint, "Username")]');
        await usernameField.click();
        await usernameField.clearValue();
        await usernameField.setValue('JohnDoe@gmail.com');
        
        const passwordField = await driver.$('//android.widget.EditText[@password="true"]');
        await passwordField.click();
        await passwordField.clearValue();
        await passwordField.setValue('password123');
        
        const loginButton = await driver.$('//android.widget.Button[contains(@content-desc, "Login")]');
        await loginButton.click();
        await driver.pause(5000);
        
        // Navigate to Profile page
        console.log('👤 Navigating to Profile page...');
        const profileTab = await driver.$('//android.widget.Button[contains(@content-desc, "Profile")]');
        await profileTab.waitForDisplayed({ timeout: 10000 });
        await profileTab.click();
        await driver.pause(2000);
        
        await driver.saveScreenshot('./test/screenshots/auth-006-profile-page.png');
        
        // Scroll to find Logout button
        console.log('🔍 Looking for Logout button...');
        await driver.execute('mobile: scroll', { direction: 'down' });
        await driver.pause(1000);
        
        // Tap Logout button
        const logoutButton = await driver.$('//android.widget.Button[contains(@content-desc, "Logout") or contains(@text, "Logout")]');
        await logoutButton.waitForDisplayed({ timeout: 10000 });
        await logoutButton.click();
        
        console.log('⏳ Waiting for logout...');
        await driver.pause(3000);
        
        await driver.saveScreenshot('./test/screenshots/auth-007-after-logout.png');
        
        // Verify back to Login page
        const pageSource = await driver.getPageSource();
        const isLoginPage = pageSource.includes('Login') || 
                           pageSource.includes('Username or Email') ||
                           pageSource.includes('Password');
        
        expect(isLoginPage).to.be.true;
        console.log('✅ Logout successful - back to Login page');
        
      } catch (error) {
        console.error('❌ Logout test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/auth-error-logout.png');
        throw error;
      }
    });
  });
});
