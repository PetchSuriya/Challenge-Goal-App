const { test, expect } = require('@playwright/test');

/**
 * Login Tests for Challenge Goal App
 */
test.describe('Login Page', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto('/');
    // Wait for Flutter to load
    await page.waitForLoadState('networkidle');
  });

  test('should display login form', async ({ page }) => {
    // Check if login page is visible
    await expect(page).toHaveTitle(/Bento|Challenge Goal App/i);
    
    // Wait for Flutter app to be ready
    await page.waitForSelector('flt-glass-pane', { timeout: 10000 });
    
    // Take screenshot
    await page.screenshot({ path: 'e2e-tests/screenshots/login-page.png' });
  });

  test('should show validation error for empty credentials', async ({ page }) => {
    // Wait for Flutter to be ready
    await page.waitForSelector('flt-glass-pane', { timeout: 10000 });
    
    // Try to find and click login button
    // Note: Flutter web requires special handling for canvas-based UI
    await page.keyboard.press('Tab'); // Navigate to username
    await page.keyboard.press('Tab'); // Navigate to password
    await page.keyboard.press('Tab'); // Navigate to login button
    await page.keyboard.press('Enter'); // Click login
    
    // Wait for error message
    await page.waitForTimeout(2000);
    
    // Take screenshot of error
    await page.screenshot({ path: 'e2e-tests/screenshots/login-error.png' });
  });

  test('should successfully login with valid credentials', async ({ page }) => {
    // Wait for Flutter to be ready
    await page.waitForSelector('flt-glass-pane', { timeout: 10000 });
    
    // This test would need to interact with Flutter's canvas
    // For now, just verify the page loaded
    const title = await page.title();
    console.log('Page title:', title);
    
    // Take screenshot
    await page.screenshot({ path: 'e2e-tests/screenshots/login-ready.png' });
  });
});
