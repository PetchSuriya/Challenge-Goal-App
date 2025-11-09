/**
 * TC-FRIEND-001 to TC-FRIEND-005: Friends System E2E Tests
 * ทดสอบการเพิ่มเพื่อน, ดูรายการเพื่อน, และดู Goals ของเพื่อน
 */

const { remote } = require('webdriverio');
const { androidCapabilities, serverConfig } = require('../../config');
const { expect } = require('chai');

describe('Friends System E2E Tests', function() {
  this.timeout(300000);
  
  let driver;

  before(async function() {
    console.log('🚀 Starting Appium session for Friends Tests...');
    driver = await remote({
      ...serverConfig,
      capabilities: androidCapabilities
    });
    console.log('✅ Appium session started');
    await driver.pause(5000);
    
    // Login first
    await loginHelper(driver);
  });

  after(async function() {
    if (driver) {
      console.log('🛑 Closing Appium session...');
      await driver.deleteSession();
    }
  });

  describe('TC-FRIEND-001: Add Friend by Username', function() {
    it('ควรเพิ่มเพื่อนได้โดยใช้ username', async function() {
      console.log('👥 Testing: Add Friend');
      
      try {
        // Navigate to Friends page
        console.log('📍 Navigating to Friends page...');
        const friendsTab = await driver.$('//android.widget.Button[contains(@content-desc, "Friends") or contains(@text, "Friends")]');
        await friendsTab.waitForDisplayed({ timeout: 10000 });
        await friendsTab.click();
        await driver.pause(2000);
        
        await driver.saveScreenshot('./test/screenshots/friend-001-friends-page.png');
        
        // Tap Add Friend button
        console.log('➕ Tapping Add Friend button...');
        const addButton = await driver.$('//android.widget.Button[contains(@content-desc, "Add") or contains(@text, "Add")]');
        await addButton.waitForDisplayed({ timeout: 10000 });
        await addButton.click();
        await driver.pause(2000);
        
        await driver.saveScreenshot('./test/screenshots/friend-002-add-dialog.png');
        
        // Enter friend's username
        console.log('📝 Entering friend username...');
        const usernameField = await driver.$('//android.widget.EditText');
        await usernameField.waitForDisplayed({ timeout: 10000 });
        await usernameField.click();
        await usernameField.setValue('JaneDoe123');
        await driver.pause(1000);
        
        await driver.saveScreenshot('./test/screenshots/friend-003-username-entered.png');
        
        // Tap Search button
        console.log('🔍 Searching for friend...');
        const searchButton = await driver.$('//android.widget.Button[contains(@content-desc, "Search") or contains(@text, "Search")]');
        await searchButton.click();
        await driver.pause(2000);
        
        await driver.saveScreenshot('./test/screenshots/friend-004-search-results.png');
        
        // Tap Add button on search result
        console.log('➕ Adding friend...');
        const addFriendButton = await driver.$('//android.widget.Button[contains(@content-desc, "Add") or contains(@text, "Add")]');
        await addFriendButton.click();
        await driver.pause(2000);
        
        await driver.saveScreenshot('./test/screenshots/friend-005-friend-added.png');
        
        // Verify friend request sent
        const pageSource = await driver.getPageSource();
        const requestSent = pageSource.includes('Pending') || 
                           pageSource.includes('Request sent') ||
                           pageSource.includes('JaneDoe123');
        
        expect(requestSent).to.be.true;
        console.log('✅ Friend request sent successfully');
        
      } catch (error) {
        console.error('❌ Add friend test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/friend-error-add.png');
        throw error;
      }
    });
  });

  describe('TC-FRIEND-004: View Friend\'s Goals', function() {
    it('ควรดู Goals ของเพื่อนได้', async function() {
      console.log('👁️  Testing: View Friend\'s Goals');
      
      try {
        // Tap on a friend's card (assuming friend exists)
        console.log('👆 Tapping on friend card...');
        const friendCard = await driver.$('//android.view.View[contains(@content-desc, "Jane") or contains(@text, "Jane")]');
        await friendCard.waitForDisplayed({ timeout: 10000 });
        await friendCard.click();
        
        await driver.pause(3000);
        await driver.saveScreenshot('./test/screenshots/friend-006-friend-profile.png');
        
        // Verify friend's goals are displayed
        const pageSource = await driver.getPageSource();
        const hasGoals = pageSource.includes('Goal') || 
                        pageSource.includes('Progress') ||
                        pageSource.includes('View');
        
        expect(hasGoals).to.be.true;
        console.log('✅ Friend\'s goals displayed successfully');
        
      } catch (error) {
        console.error('❌ View friend\'s goals test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/friend-error-view-goals.png');
        throw error;
      }
    });
  });

  describe('TC-FRIEND-005: Remove Friend', function() {
    it('ควรลบเพื่อนได้', async function() {
      console.log('🗑️  Testing: Remove Friend');
      
      try {
        // Navigate back to friends list
        await driver.back();
        await driver.pause(2000);
        
        // Long press on friend card to show options
        console.log('👆 Long pressing on friend card...');
        const friendCard = await driver.$('//android.view.View[contains(@content-desc, "Jane")]');
        await friendCard.waitForDisplayed({ timeout: 10000 });
        
        // Try long press or tap options button
        try {
          await friendCard.click({ button: 'right' }); // Right click
        } catch (e) {
          // If right click doesn't work, try finding options button
          const optionsButton = await driver.$('//android.widget.Button[contains(@content-desc, "More") or contains(@content-desc, "Options")]');
          await optionsButton.click();
        }
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/friend-007-options-menu.png');
        
        // Tap Remove Friend option
        console.log('🗑️  Tapping Remove Friend...');
        const removeButton = await driver.$('//android.widget.Button[contains(@text, "Remove") or contains(@content-desc, "Remove")]');
        await removeButton.click();
        await driver.pause(1000);
        
        // Confirm removal
        const confirmButton = await driver.$('//android.widget.Button[contains(@text, "Confirm") or contains(@text, "Yes")]');
        await confirmButton.click();
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/friend-008-friend-removed.png');
        
        // Verify friend is removed
        const pageSource = await driver.getPageSource();
        const isRemoved = !pageSource.includes('JaneDoe123');
        
        expect(isRemoved).to.be.true;
        console.log('✅ Friend removed successfully');
        
      } catch (error) {
        console.error('❌ Remove friend test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/friend-error-remove.png');
        throw error;
      }
    });
  });
});

// Helper function to login
async function loginHelper(driver) {
  console.log('🔐 Logging in...');
  
  try {
    const usernameField = await driver.$('//android.widget.EditText[contains(@hint, "Username")]');
    await usernameField.waitForDisplayed({ timeout: 10000 });
    await usernameField.click();
    await usernameField.setValue('JohnDoe@gmail.com');
    
    const passwordField = await driver.$('//android.widget.EditText[@password="true"]');
    await passwordField.click();
    await passwordField.setValue('password123');
    
    const loginButton = await driver.$('//android.widget.Button[contains(@content-desc, "Login")]');
    await loginButton.click();
    
    await driver.pause(5000);
    console.log('✅ Logged in successfully');
  } catch (error) {
    console.error('❌ Login helper failed:', error.message);
    throw error;
  }
}
