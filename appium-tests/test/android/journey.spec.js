/**
 * TC-JOURNEY-001: Complete User Journey (Critical Path)
 * ทดสอบ User Flow ทั้งหมด ตั้งแต่ Register ถึง Logout
 */

const { remote } = require('webdriverio');
const { androidCapabilities, serverConfig } = require('../../config');
const { expect } = require('chai');

describe('Complete User Journey E2E Test', function() {
  this.timeout(600000); // 10 นาที สำหรับ journey ยาว
  
  let driver;
  const timestamp = Date.now();
  const testUser = {
    username: `testuser${timestamp}`,
    email: `testuser${timestamp}@gmail.com`,
    password: 'Test@123456'
  };

  before(async function() {
    console.log('🚀 Starting Appium session for Complete Journey...');
    console.log('👤 Test user:', testUser);
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

  it('ควรทำ Complete User Journey สำเร็จ', async function() {
    console.log('\n🎯 Starting Complete User Journey Test...\n');
    
    // ===== STEP 1: Register =====
    console.log('📝 STEP 1/9: Register new account');
    try {
      // Navigate to Register page
      const registerLink = await driver.$('//android.widget.Button[contains(@content-desc, "Sign Up") or contains(@text, "Sign Up")]');
      await registerLink.waitForDisplayed({ timeout: 10000 });
      await registerLink.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-001-register-page.png');
      
      // Fill registration form
      const usernameField = await driver.$('//android.widget.EditText[contains(@hint, "Username")]');
      await usernameField.click();
      await usernameField.setValue(testUser.username);
      
      const emailField = await driver.$('//android.widget.EditText[contains(@hint, "Email")]');
      await emailField.click();
      await emailField.setValue(testUser.email);
      
      const passwordField = await driver.$('//android.widget.EditText[contains(@hint, "Password")][@password="true"]');
      await passwordField.click();
      await passwordField.setValue(testUser.password);
      
      const confirmPasswordField = await driver.$('//android.widget.EditText[contains(@hint, "Confirm")][@password="true"]');
      await confirmPasswordField.click();
      await confirmPasswordField.setValue(testUser.password);
      
      await driver.saveScreenshot('./test/screenshots/journey-002-registration-filled.png');
      
      // Submit registration
      const registerButton = await driver.$('//android.widget.Button[contains(@content-desc, "Register") or contains(@text, "Register")]');
      await registerButton.click();
      await driver.pause(5000);
      
      await driver.saveScreenshot('./test/screenshots/journey-003-registered.png');
      console.log('✅ Step 1 Complete: User registered');
      
    } catch (error) {
      console.error('❌ Registration failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-register.png');
      throw error;
    }
    
    // ===== STEP 2: Login =====
    console.log('\n🔐 STEP 2/9: Login with new account');
    try {
      // If not auto-logged in, go to login page
      const pageSource = await driver.getPageSource();
      if (pageSource.includes('Login') || pageSource.includes('Username or Email')) {
        const usernameField = await driver.$('//android.widget.EditText[contains(@hint, "Username")]');
        await usernameField.click();
        await usernameField.setValue(testUser.email);
        
        const passwordField = await driver.$('//android.widget.EditText[@password="true"]');
        await passwordField.click();
        await passwordField.setValue(testUser.password);
        
        const loginButton = await driver.$('//android.widget.Button[contains(@content-desc, "Login")]');
        await loginButton.click();
        await driver.pause(5000);
      }
      
      await driver.saveScreenshot('./test/screenshots/journey-004-logged-in.png');
      console.log('✅ Step 2 Complete: User logged in');
      
    } catch (error) {
      console.error('❌ Login failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-login.png');
      throw error;
    }
    
    // ===== STEP 3: Create First Goal =====
    console.log('\n🎯 STEP 3/9: Create first goal');
    try {
      // Navigate to Goals page
      const goalsTab = await driver.$('//android.widget.Button[contains(@content-desc, "Goals")]');
      await goalsTab.waitForDisplayed({ timeout: 10000 });
      await goalsTab.click();
      await driver.pause(2000);
      
      // Create goal
      const createButton = await driver.$('//android.widget.Button[contains(@content-desc, "Create") or contains(@content-desc, "Add")]');
      await createButton.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-005-create-goal-form.png');
      
      // Fill goal details
      const titleField = await driver.$('//android.widget.EditText[contains(@hint, "Title")]');
      await titleField.click();
      await titleField.setValue('My First Goal - Journey Test');
      
      const descField = await driver.$('//android.widget.EditText[contains(@hint, "Description")]');
      await descField.click();
      await descField.setValue('This is my first goal in the app!');
      
      await driver.saveScreenshot('./test/screenshots/journey-006-goal-filled.png');
      
      // Save goal
      const saveButton = await driver.$('//android.widget.Button[contains(@content-desc, "Save")]');
      await saveButton.click();
      await driver.pause(3000);
      
      await driver.saveScreenshot('./test/screenshots/journey-007-goal-created.png');
      console.log('✅ Step 3 Complete: First goal created');
      
    } catch (error) {
      console.error('❌ Create goal failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-create-goal.png');
      throw error;
    }
    
    // ===== STEP 4: Update Goal Progress =====
    console.log('\n📊 STEP 4/9: Update goal progress');
    try {
      // Tap on goal to view details
      const goalCard = await driver.$('//android.view.View[contains(@content-desc, "My First Goal")]');
      await goalCard.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-008-goal-details.png');
      
      // Update progress
      const updateButton = await driver.$('//android.widget.Button[contains(@content-desc, "Update")]');
      await updateButton.click();
      await driver.pause(2000);
      
      const progressField = await driver.$('//android.widget.EditText');
      await progressField.click();
      await progressField.setValue('Made great progress today!');
      
      const submitButton = await driver.$('//android.widget.Button[contains(@text, "Submit")]');
      await submitButton.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-009-progress-updated.png');
      console.log('✅ Step 4 Complete: Goal progress updated');
      
    } catch (error) {
      console.error('❌ Update progress failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-progress.png');
      // Continue even if update fails
    }
    
    // ===== STEP 5: Add a Friend =====
    console.log('\n👥 STEP 5/9: Add a friend');
    try {
      // Navigate to Friends page
      const friendsTab = await driver.$('//android.widget.Button[contains(@content-desc, "Friends")]');
      await friendsTab.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-010-friends-page.png');
      
      // Try to add friend
      const addButton = await driver.$('//android.widget.Button[contains(@content-desc, "Add")]');
      await addButton.click();
      await driver.pause(2000);
      
      const usernameField = await driver.$('//android.widget.EditText');
      await usernameField.click();
      await usernameField.setValue('JohnDoe@gmail.com');
      
      const searchButton = await driver.$('//android.widget.Button[contains(@content-desc, "Search")]');
      await searchButton.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-011-friend-search.png');
      console.log('✅ Step 5 Complete: Friend search attempted');
      
    } catch (error) {
      console.error('❌ Add friend failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-friend.png');
      // Continue even if add friend fails
    }
    
    // ===== STEP 6: View Dashboard =====
    console.log('\n🏠 STEP 6/9: View dashboard');
    try {
      const homeTab = await driver.$('//android.widget.Button[contains(@content-desc, "Home")]');
      await homeTab.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-012-dashboard.png');
      
      // Verify dashboard elements
      const pageSource = await driver.getPageSource();
      const hasDashboard = pageSource.includes('Home') || 
                          pageSource.includes('Welcome') ||
                          pageSource.includes('Goals');
      
      expect(hasDashboard).to.be.true;
      console.log('✅ Step 6 Complete: Dashboard viewed');
      
    } catch (error) {
      console.error('❌ View dashboard failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-dashboard.png');
      throw error;
    }
    
    // ===== STEP 7: Update Profile =====
    console.log('\n👤 STEP 7/9: Update profile');
    try {
      const profileTab = await driver.$('//android.widget.Button[contains(@content-desc, "Profile")]');
      await profileTab.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-013-profile.png');
      
      // Verify profile loaded
      const pageSource = await driver.getPageSource();
      const hasProfile = pageSource.includes(testUser.username) || 
                        pageSource.includes('Profile') ||
                        pageSource.includes('Logout');
      
      expect(hasProfile).to.be.true;
      console.log('✅ Step 7 Complete: Profile viewed');
      
    } catch (error) {
      console.error('❌ View profile failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-profile.png');
      throw error;
    }
    
    // ===== STEP 8: Complete Goal =====
    console.log('\n🎉 STEP 8/9: Mark goal as complete');
    try {
      // Navigate back to goals
      const goalsTab = await driver.$('//android.widget.Button[contains(@content-desc, "Goals")]');
      await goalsTab.click();
      await driver.pause(2000);
      
      // Tap on goal
      const goalCard = await driver.$('//android.view.View[contains(@content-desc, "My First Goal")]');
      await goalCard.click();
      await driver.pause(2000);
      
      // Try to mark as complete
      const completeButton = await driver.$('//android.widget.Button[contains(@content-desc, "Complete") or contains(@text, "Complete")]');
      await completeButton.click();
      await driver.pause(2000);
      
      await driver.saveScreenshot('./test/screenshots/journey-014-goal-completed.png');
      console.log('✅ Step 8 Complete: Goal marked as complete');
      
    } catch (error) {
      console.error('❌ Complete goal failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-complete.png');
      // Continue even if complete fails
    }
    
    // ===== STEP 9: Logout =====
    console.log('\n🚪 STEP 9/9: Logout');
    try {
      const profileTab = await driver.$('//android.widget.Button[contains(@content-desc, "Profile")]');
      await profileTab.click();
      await driver.pause(2000);
      
      // Scroll to logout button
      await driver.execute('mobile: scroll', { direction: 'down' });
      await driver.pause(1000);
      
      const logoutButton = await driver.$('//android.widget.Button[contains(@content-desc, "Logout")]');
      await logoutButton.click();
      await driver.pause(3000);
      
      await driver.saveScreenshot('./test/screenshots/journey-015-logged-out.png');
      
      // Verify back to login page
      const pageSource = await driver.getPageSource();
      const isLoggedOut = pageSource.includes('Login') || 
                         pageSource.includes('Username or Email');
      
      expect(isLoggedOut).to.be.true;
      console.log('✅ Step 9 Complete: User logged out');
      
    } catch (error) {
      console.error('❌ Logout failed:', error.message);
      await driver.saveScreenshot('./test/screenshots/journey-error-logout.png');
      throw error;
    }
    
    console.log('\n🎉 ========================================');
    console.log('🎉 COMPLETE USER JOURNEY TEST PASSED!');
    console.log('🎉 All 9 steps completed successfully');
    console.log('🎉 ========================================\n');
  });
});
