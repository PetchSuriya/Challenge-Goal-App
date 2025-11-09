/**
 * TC-GOAL-001 to TC-GOAL-007: Goal Management E2E Tests
 * ทดสอบการสร้าง, แก้ไข, ลบ, และจัดการ Goals
 */

const { remote } = require('webdriverio');
const { androidCapabilities, serverConfig } = require('../../config');
const { expect } = require('chai');

describe('Goal Management E2E Tests', function() {
  this.timeout(300000); // 5 นาที
  
  let driver;

  before(async function() {
    console.log('🚀 Starting Appium session for Goal Tests...');
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

  describe('TC-GOAL-001: Create New Goal (Basic)', function() {
    it('ควรสร้าง Goal ใหม่ได้สำเร็จ', async function() {
      console.log('📝 Testing: Create New Goal');
      
      try {
        // Navigate to Goals page
        console.log('📍 Navigating to Goals page...');
        const goalsTab = await driver.$('//android.widget.Button[contains(@content-desc, "Goals") or contains(@text, "Goals")]');
        await goalsTab.waitForDisplayed({ timeout: 10000 });
        await goalsTab.click();
        await driver.pause(2000);
        
        await driver.saveScreenshot('./test/screenshots/goal-001-goals-page.png');
        
        // Tap Create Goal button (FAB or button)
        console.log('➕ Tapping Create Goal button...');
        const createButton = await driver.$('//android.widget.Button[contains(@content-desc, "Create") or contains(@content-desc, "Add")]');
        await createButton.waitForDisplayed({ timeout: 10000 });
        await createButton.click();
        await driver.pause(2000);
        
        await driver.saveScreenshot('./test/screenshots/goal-002-create-form.png');
        
        // Fill Goal Form
        console.log('📝 Filling goal form...');
        
        // Title
        const titleField = await driver.$('//android.widget.EditText[contains(@hint, "Title") or contains(@hint, "ชื่อ")]');
        await titleField.waitForDisplayed({ timeout: 10000 });
        await titleField.click();
        await titleField.setValue('ออกกำลังกายทุกวัน');
        await driver.pause(1000);
        
        // Description
        const descField = await driver.$('//android.widget.EditText[contains(@hint, "Description") or contains(@hint, "รายละเอียด")]');
        await descField.click();
        await descField.setValue('วิ่ง 5 กิโลเมตร ทุกเช้า');
        await driver.pause(1000);
        
        // Category (might need to tap dropdown)
        try {
          const categoryField = await driver.$('//android.widget.Spinner[contains(@content-desc, "Category")]');
          await categoryField.click();
          await driver.pause(1000);
          
          // Select "Health & Fitness"
          const healthOption = await driver.$('//android.widget.TextView[contains(@text, "Health")]');
          await healthOption.click();
          await driver.pause(1000);
        } catch (error) {
          console.log('⚠️  Category selection not available or different UI');
        }
        
        await driver.saveScreenshot('./test/screenshots/goal-003-form-filled.png');
        
        // Save Goal
        console.log('💾 Saving goal...');
        const saveButton = await driver.$('//android.widget.Button[contains(@content-desc, "Save") or contains(@text, "Save")]');
        await saveButton.waitForDisplayed({ timeout: 10000 });
        await saveButton.click();
        
        await driver.pause(3000);
        await driver.saveScreenshot('./test/screenshots/goal-004-goal-created.png');
        
        // Verify goal appears in list
        const pageSource = await driver.getPageSource();
        const goalCreated = pageSource.includes('ออกกำลังกายทุกวัน');
        
        expect(goalCreated).to.be.true;
        console.log('✅ Goal created successfully');
        
      } catch (error) {
        console.error('❌ Create goal test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/goal-error-create.png');
        throw error;
      }
    });
  });

  describe('TC-GOAL-003: View Goal Details', function() {
    it('ควรแสดงรายละเอียด Goal ได้ถูกต้อง', async function() {
      console.log('👁️  Testing: View Goal Details');
      
      try {
        // Tap on first goal card
        console.log('🎯 Tapping on goal card...');
        const goalCard = await driver.$('//android.view.View[contains(@content-desc, "ออกกำลังกาย")]');
        await goalCard.waitForDisplayed({ timeout: 10000 });
        await goalCard.click();
        
        await driver.pause(3000);
        await driver.saveScreenshot('./test/screenshots/goal-005-goal-details.png');
        
        // Verify goal details are displayed
        const pageSource = await driver.getPageSource();
        
        const hasTitle = pageSource.includes('ออกกำลังกายทุกวัน');
        const hasDescription = pageSource.includes('วิ่ง 5 กิโลเมตร');
        const hasActions = pageSource.includes('Update') || 
                          pageSource.includes('Edit') || 
                          pageSource.includes('Delete');
        
        expect(hasTitle).to.be.true;
        expect(hasDescription).to.be.true;
        expect(hasActions).to.be.true;
        
        console.log('✅ Goal details displayed correctly');
        
      } catch (error) {
        console.error('❌ View goal details test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/goal-error-details.png');
        throw error;
      }
    });
  });

  describe('TC-GOAL-004: Update Goal Progress', function() {
    it('ควรอัพเดท Progress ของ Goal ได้', async function() {
      console.log('📊 Testing: Update Goal Progress');
      
      try {
        // Find and tap Update Progress button
        console.log('🔼 Tapping Update Progress button...');
        const updateButton = await driver.$('//android.widget.Button[contains(@content-desc, "Update") or contains(@text, "Update")]');
        await updateButton.waitForDisplayed({ timeout: 10000 });
        await updateButton.click();
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/goal-006-update-progress-dialog.png');
        
        // Enter progress value
        console.log('📝 Entering progress...');
        const progressField = await driver.$('//android.widget.EditText');
        await progressField.waitForDisplayed({ timeout: 10000 });
        await progressField.click();
        await progressField.setValue('5 km completed today');
        await driver.pause(1000);
        
        // Submit progress
        const submitButton = await driver.$('//android.widget.Button[contains(@text, "Submit") or contains(@content-desc, "Submit")]');
        await submitButton.click();
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/goal-007-progress-updated.png');
        
        // Verify progress was updated
        const pageSource = await driver.getPageSource();
        const progressUpdated = pageSource.includes('5 km') || 
                               pageSource.includes('Success') ||
                               pageSource.includes('Updated');
        
        expect(progressUpdated).to.be.true;
        console.log('✅ Progress updated successfully');
        
      } catch (error) {
        console.error('❌ Update progress test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/goal-error-progress.png');
        throw error;
      }
    });
  });

  describe('TC-GOAL-005: Edit Existing Goal', function() {
    it('ควรแก้ไข Goal ที่มีอยู่ได้', async function() {
      console.log('✏️  Testing: Edit Goal');
      
      try {
        // Navigate back to goals list
        await driver.back();
        await driver.pause(2000);
        
        // Tap on goal card again
        const goalCard = await driver.$('//android.view.View[contains(@content-desc, "ออกกำลังกาย")]');
        await goalCard.click();
        await driver.pause(2000);
        
        // Tap Edit button
        console.log('✏️  Tapping Edit button...');
        const editButton = await driver.$('//android.widget.Button[contains(@content-desc, "Edit") or contains(@text, "Edit")]');
        await editButton.waitForDisplayed({ timeout: 10000 });
        await editButton.click();
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/goal-008-edit-form.png');
        
        // Modify title
        console.log('📝 Modifying goal title...');
        const titleField = await driver.$('//android.widget.EditText[contains(@text, "ออกกำลังกาย")]');
        await titleField.click();
        await titleField.clearValue();
        await titleField.setValue('ออกกำลังกายทุกวัน (แก้ไข)');
        await driver.pause(1000);
        
        // Modify description
        const descField = await driver.$('//android.widget.EditText[contains(@text, "วิ่ง")]');
        await descField.click();
        await descField.clearValue();
        await descField.setValue('วิ่ง 7 กิโลเมตร ทุกเช้า');
        await driver.pause(1000);
        
        await driver.saveScreenshot('./test/screenshots/goal-009-edited.png');
        
        // Save changes
        const saveButton = await driver.$('//android.widget.Button[contains(@content-desc, "Save")]');
        await saveButton.click();
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/goal-010-edit-saved.png');
        
        // Verify changes
        const pageSource = await driver.getPageSource();
        const isEdited = pageSource.includes('แก้ไข') && pageSource.includes('7 กิโลเมตร');
        
        expect(isEdited).to.be.true;
        console.log('✅ Goal edited successfully');
        
      } catch (error) {
        console.error('❌ Edit goal test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/goal-error-edit.png');
        throw error;
      }
    });
  });

  describe('TC-GOAL-006: Delete Goal', function() {
    it('ควรลบ Goal ได้', async function() {
      console.log('🗑️  Testing: Delete Goal');
      
      try {
        // Find Delete button
        console.log('🗑️  Tapping Delete button...');
        const deleteButton = await driver.$('//android.widget.Button[contains(@content-desc, "Delete") or contains(@text, "Delete")]');
        await deleteButton.waitForDisplayed({ timeout: 10000 });
        await deleteButton.click();
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/goal-011-delete-confirm.png');
        
        // Confirm deletion
        console.log('✅ Confirming deletion...');
        const confirmButton = await driver.$('//android.widget.Button[contains(@text, "Confirm") or contains(@text, "Yes") or contains(@text, "Delete")]');
        await confirmButton.click();
        
        await driver.pause(2000);
        await driver.saveScreenshot('./test/screenshots/goal-012-deleted.png');
        
        // Verify goal is removed
        const pageSource = await driver.getPageSource();
        const isDeleted = !pageSource.includes('ออกกำลังกายทุกวัน (แก้ไข)');
        
        expect(isDeleted).to.be.true;
        console.log('✅ Goal deleted successfully');
        
      } catch (error) {
        console.error('❌ Delete goal test failed:', error.message);
        await driver.saveScreenshot('./test/screenshots/goal-error-delete.png');
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
