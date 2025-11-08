const { test, expect } = require('@playwright/test');

/**
 * Backend API Tests for Challenge Goal App
 */
test.describe('Backend API', () => {
  const baseURL = 'http://localhost:3000';

  test('should connect to backend server', async ({ request }) => {
    const response = await request.get(`${baseURL}/`);
    expect(response.status()).toBeLessThan(500);
  });

  test('should handle login request', async ({ request }) => {
    const response = await request.post(`${baseURL}/login`, {
      data: {
        username: 'testuser@example.com',
        password: 'testpassword'
      }
    });
    
    // Should return 401 for invalid credentials or 200 for valid
    expect([200, 401]).toContain(response.status());
  });

  test('should fetch goals list', async ({ request }) => {
    // First login to get session
    const loginResponse = await request.post(`${baseURL}/login`, {
      data: {
        username: 'JohnDoe@gmail.com',
        password: 'Bento2025!'
      }
    });

    if (loginResponse.ok()) {
      // Fetch goals
      const goalsResponse = await request.get(`${baseURL}/goals`);
      expect(goalsResponse.ok()).toBeTruthy();
      
      const goals = await goalsResponse.json();
      console.log('Goals:', goals);
    }
  });
});
