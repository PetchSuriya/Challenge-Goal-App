// Example usage and testing guide for the Bento Flutter App

/*
================================================================================
                          TESTING THE APPLICATION
================================================================================

Since this app is designed to work with a backend API, here are ways to test 
the application during development:

1. MOCK TESTING CREDENTIALS:
   - Email: test@example.com
   - Password: 123456

2. BACKEND MOCK RESPONSES:
   The AuthService expects these API responses. You can modify the service
   to return mock data during development.

3. TESTING FLOW:
   a) Launch app → Should show Login page
   b) Enter test credentials → Should navigate to Profile
   c) Edit profile → Should save and update
   d) Reset password → Should show success message
   e) Logout → Should return to Login page

================================================================================
                          MOCK DATA EXAMPLES
================================================================================
*/

// Example API Response for Login
const mockLoginResponse = {
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "123456",
    "email": "test@example.com",
    "first_name": "John",
    "last_name": "Doe", 
    "phone_number": "+1234567890",
    "profile_image_url": "https://via.placeholder.com/150",
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z"
  }
};

// Example API Response for Profile
const mockProfileResponse = {
  "id": "123456",
  "email": "test@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "+1234567890",
  "profile_image_url": "https://via.placeholder.com/150",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
};

// Example API Response for Password Reset
const mockResetPasswordResponse = {
  "message": "Password reset link sent to your email"
};

/*
================================================================================
                          DEVELOPMENT TIPS
================================================================================

1. TO ENABLE MOCK MODE:
   - In auth_service.dart, you can temporarily replace API calls with mock data
   - Use the mock responses above for testing

2. TO TEST WITHOUT BACKEND:
   - Modify AuthService.login() to return LoginResult.success(mockUser)
   - Modify AuthService.getProfile() to return ProfileResult.success(mockUser)
   - Modify AuthService.resetPassword() to return ResetPasswordResult.success()

3. TO TEST API INTEGRATION:
   - Update api_config.dart with your backend URLs
   - Ensure your backend follows the expected request/response format
   - Test with tools like Postman first

4. TO DEBUG:
   - Use Flutter Inspector for UI debugging
   - Use print statements in controllers for state debugging
   - Use Dio interceptors for API request/response debugging

================================================================================
                          FOLDER STRUCTURE GUIDE
================================================================================

lib/
├── core/                   # Shared app-wide configurations
│   ├── config/            # API endpoints, app settings
│   ├── constants/         # Static values, strings
│   └── theme/             # App themes and styling
│
├── features/              # Feature-based modules
│   ├── login/             # Everything related to login
│   │   ├── controller/    # Business logic for login
│   │   └── view/          # UI pages for login
│   └── profile/           # Everything related to profile
│       ├── controller/    # Business logic for profile
│       ├── model/         # Data models for profile
│       └── view/          # UI pages for profile
│
├── routes/                # Navigation configuration
├── services/              # Business logic services (API calls)
├── widgets/               # Reusable UI components
└── main.dart             # App entry point

================================================================================
                          NEXT STEPS FOR DEVELOPMENT
================================================================================

1. CUSTOMIZE THEME:
   - Modify app_theme.dart to match your brand colors
   - Add custom fonts in pubspec.yaml and update theme

2. ADD MORE FEATURES:
   - Create new feature folders (e.g., features/settings/)
   - Follow the same controller/view/model pattern

3. ENHANCE UI:
   - Add more custom widgets
   - Implement animations and transitions
   - Add proper error handling UI

4. BACKEND INTEGRATION:
   - Set up your backend APIs
   - Update API endpoints in api_config.dart
   - Test thoroughly with real data

5. PRODUCTION READY:
   - Add proper error logging
   - Implement crash reporting
   - Add analytics
   - Set up CI/CD pipeline

================================================================================
*/