# Bento - Flutter Authentication App

A complete Flutter application with clean architecture, featuring authentication and user profile management. Built with modern Flutter best practices and scalable folder structure.

## 🚀 Features

### Authentication
- **User Login** with email and password
- **JWT Token Management** with automatic storage and refresh
- **Password Reset** via email
- **Automatic Login State** persistence

### User Profile
- **Profile Display** with user information
- **Profile Editing** with form validation
- **Profile Picture** placeholder support
- **Logout** functionality

### Architecture
- **Feature-based folder structure** for scalability
- **Clean Architecture** with separation of concerns
- **State Management** using Riverpod
- **HTTP Client** using Dio for API communication
- **Local Storage** using SharedPreferences
- **Navigation** using go_router

## 📁 Project Structure

```
lib/
├── core/                          # Core app configurations
│   ├── config/
│   │   └── api_config.dart       # API endpoints and configurations
│   ├── constants/
│   │   └── app_constants.dart    # App-wide constants
│   └── theme/
│       └── app_theme.dart        # App theme configuration
├── features/                      # Feature-based modules
│   ├── login/                     # Login feature
│   │   ├── controller/
│   │   │   └── login_controller.dart
│   │   └── view/
│   │       └── login_page.dart
│   └── profile/                   # Profile feature
│       ├── controller/
│       │   └── profile_controller.dart
│       ├── model/
│       │   └── user_model.dart
│       └── view/
│           ├── profile_page.dart
│           └── reset_password_page.dart
├── routes/                        # App routing
│   └── app_routes.dart
├── services/                      # Business logic services
│   └── auth_service.dart         # Authentication service
├── widgets/                       # Reusable UI components
│   ├── custom_button.dart
│   └── custom_text_field.dart
└── main.dart                     # App entry point
```

## 🛠 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  dio: ^5.3.2                     # HTTP client
  flutter_riverpod: ^2.4.9       # State management
  shared_preferences: ^2.2.2     # Local storage
  go_router: ^12.1.1             # Navigation
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio or VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bento
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration
Update the API endpoints in `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-backend.com/api';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String profileEndpoint = '$baseUrl/user/profile';
  static const String updateProfileEndpoint = '$baseUrl/user/profile';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
}
```

### Backend API Requirements

The app expects the following API endpoints:

#### 1. Login API
- **Endpoint**: `POST /auth/login`
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response**:
  ```json
  {
    "access_token": "jwt_token_here",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone_number": "+1234567890",
      "profile_image_url": "https://example.com/avatar.jpg",
      "created_at": "2023-01-01T00:00:00Z",
      "updated_at": "2023-01-01T00:00:00Z"
    }
  }
  ```

#### 2. Profile API
- **Endpoint**: `GET /user/profile`
- **Headers**: `Authorization: Bearer {access_token}`
- **Response**: Same as login user object

#### 3. Update Profile API
- **Endpoint**: `PUT /user/profile`
- **Headers**: `Authorization: Bearer {access_token}`
- **Request Body**: User object with updated fields
- **Response**: Updated user object

#### 4. Reset Password API
- **Endpoint**: `POST /auth/reset-password`
- **Request Body**:
  ```json
  {
    "email": "user@example.com"
  }
  ```
- **Response**:
  ```json
  {
    "message": "Password reset link sent to your email"
  }
  ```

## 📱 App Flow

### Authentication Flow
1. **App Launch** → Check if user is logged in
2. **Not Logged In** → Show Login Page
3. **Login Success** → Save JWT token → Navigate to Profile
4. **Already Logged In** → Navigate directly to Profile

### Profile Management
1. **View Profile** → Display user information
2. **Edit Profile** → Enable form fields → Save changes
3. **Reset Password** → Enter email → Send reset link
4. **Logout** → Clear tokens → Navigate to Login

## 🎨 UI/UX Features

- **Material Design 3** with dynamic theming
- **Light/Dark Theme** support
- **Responsive Design** for different screen sizes
- **Custom Widgets** for consistent UI
- **Form Validation** with user-friendly error messages
- **Loading States** with progress indicators
- **Success/Error Feedback** with snackbars

## 🔐 Security Features

- **JWT Token Storage** with automatic management
- **Token Interceptor** for automatic API authorization
- **Auto Logout** on token expiration (401 errors)
- **Secure Local Storage** using SharedPreferences
- **Form Validation** to prevent invalid data submission

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 🛡 Error Handling

The app includes comprehensive error handling:

- **Network Errors** with retry mechanisms
- **Validation Errors** with user-friendly messages
- **API Errors** with proper error display
- **Navigation Guards** to prevent unauthorized access
- **Graceful Fallbacks** for missing data

## 📦 Build & Deploy

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Dio for robust HTTP client
- go_router for declarative routing

---

**Note**: This is a template project ready for backend integration. Update the API endpoints in the configuration files to connect with your actual backend service.
