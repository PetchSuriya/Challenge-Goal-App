import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/login/view/login_page.dart';
import '../features/register page/register_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/profile/view/reset_password_page.dart';
import '../features/home/view/home_page.dart';
import '../features/profile/view/costume_page.dart';
import '../features/friends/view/friends_home_page.dart';
import '../features/goal/view/goal_page.dart';
import '../features/goal/view/goal_detail_page.dart';
import '../features/friend/view/friend_page.dart';
import '../services/auth_service.dart';
import '../core/constants/app_constants.dart';

/// AppRoutes - จัดการ Routing และ Navigation ของแอป
///
/// ไฟล์นี้รับผิดชอบ:
/// 1. กำหนด Routes ทั้งหมดของแอป
/// 2. จัดการ Authentication Guards (ป้องกันการเข้าถึงหน้าที่ต้อง login)
/// 3. Redirect Logic (เปลี่ยนเส้นทางเมื่อจำเป็น)
/// 4. Error Handling สำหรับหน้าที่ไม่พบ
/// 5. Helper methods สำหรับ Navigation
class AppRoutes {
  // === Private Properties ===

  /// AuthService instance สำหรับเช็คสถานะการ login
  static final AuthService _authService = AuthService();

  // === Main Router Configuration ===

  /// GoRouter หลักของแอป - จัดการ routing ทั้งหมด
  static final GoRouter router = GoRouter(
    /// หน้าเริ่มต้นเมื่อเปิดแอป - เริ่มที่หน้า Login เสมอ
    initialLocation: AppConstants.loginRoute,

    /// Redirect Logic - ตรวจสอบสิทธิ์การเข้าถึงและเปลี่ยนเส้นทางเมื่อจำเป็น
    redirect: (context, state) async {
      // ตรวจสอบว่าผู้ใช้กำลังเข้าถึงหน้าไหน
      final isLoginRoute = state.matchedLocation == AppConstants.loginRoute;
<<<<<<< HEAD
      final isRegisterRoute = state.matchedLocation == AppConstants.registerRoute;
      final isResetPasswordRoute = state.matchedLocation == AppConstants.resetPasswordRoute;
=======
      final isResetPasswordRoute =
          state.matchedLocation == AppConstants.resetPasswordRoute;
>>>>>>> 3e10717bbec771133ae7f88aad415c34f871eb5a

      // อนุญาตให้เข้าถึงหน้า Login, Register และ Reset Password ได้เสมอ (Public Routes)
      if (isLoginRoute || isRegisterRoute || isResetPasswordRoute) return null;

      // สำหรับหน้าที่ต้อง login (Protected Routes) - ตรวจสอบสถานะการ login
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) return AppConstants.loginRoute;

      // ผู้ใช้ login แล้วและเข้าถึงหน้าที่อนุญาตได้
      return null; // ไม่ต้อง redirect
    },

    // === Route Definitions ===
    routes: [
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: AppConstants.profileRoute,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // Keep '/dashboard' path but point it to HomePage (dashboard replaced by Home)
      GoRoute(
        path: AppConstants.dashboardRoute,
        name: 'dashboard',
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: AppConstants.goalRoute,
        name: 'goals',
        builder: (context, state) => const GoalPage(),
      ),

      GoRoute(
        path: AppConstants.goalDetailRoute,
        name: 'goal-detail',
        builder: (context, state) {
          final extra = state.extra;
          return GoalDetailPage(args: extra is GoalDetailArgs ? extra : null);
        },
      ),

      GoRoute(
        path: AppConstants.resetPasswordRoute,
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),

      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: AppConstants.costumeRoute,
        name: 'costume',
        builder: (context, state) => const CostumePage(),
      ),

      GoRoute(
        path: AppConstants.friendRoute,
        name: 'friend',
        builder: (context, state) => const FriendPage(),
      ),

      GoRoute(
        path: '/friends/:friendName',
        name: 'friends-home',
        builder: (context, state) {
          final friendName = state.pathParameters['friendName'] ?? 'Friend';
          final friendAvatarUrl = state.uri.queryParameters['avatarUrl'];
          return FriendsHomePage(
            friendName: friendName,
            friendAvatarUrl: friendAvatarUrl,
          );
        },
      ),
    ],

    // === Error Handling ===
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.matchedLocation}" does not exist.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final isLoggedIn = await _authService.isLoggedIn();
                final destination = isLoggedIn
                    ? AppConstants.homeRoute
                    : AppConstants.loginRoute;
                if (context.mounted) context.go(destination);
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Extension for easier navigation
extension AppRouterExtension on GoRouter {
  void goToLogin() => go(AppConstants.loginRoute);
  void goToRegister() => go(AppConstants.registerRoute);
  void goToProfile() => go(AppConstants.profileRoute);
  void goToResetPassword() => go(AppConstants.resetPasswordRoute);
  void goToHome() => go(AppConstants.homeRoute);
  void goToGoals() => go(AppConstants.goalRoute);
  void goToFriends() => go(AppConstants.friendRoute);
}
