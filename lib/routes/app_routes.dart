import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/login/view/login_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/profile/view/reset_password_page.dart';
import '../features/dashboard/view/dashboard_page.dart';
import '../features/goal/view/goal_page.dart';
import '../features/goal/view/goal_detail_page.dart';
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
      final isResetPasswordRoute = state.matchedLocation == AppConstants.resetPasswordRoute;

      // อนุญาตให้เข้าถึงหน้า Login และ Reset Password ได้เสมอ (Public Routes)
      if (isLoginRoute || isResetPasswordRoute) {
        return null; // ไม่ต้อง redirect
      }

      // สำหรับหน้าที่ต้อง login (Protected Routes) - ตรวจสอบสถานะการ login
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        // ถ้ายังไม่ได้ login ให้กลับไปหน้า Login
        return AppConstants.loginRoute;
      }

      // ผู้ใช้ login แล้วและเข้าถึงหน้าที่อนุญาตได้
      return null; // ไม่ต้อง redirect
    },
    // === Route Definitions ===
    
    routes: [
      /// หน้า Login - จุดเริ่มต้นของแอป
      /// Path: '/login'
      /// Access: Public (ทุกคนเข้าได้)
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      /// หน้า Profile - แสดงข้อมูลผู้ใช้และการจัดการโปรไฟล์
      /// Path: '/profile' 
      /// Access: Protected (ต้อง login ก่อน)
      GoRoute(
        path: AppConstants.profileRoute,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      /// หน้า Dashboard - หน้าแรกหลังจากล็อกอินสำเร็จ
      /// Path: '/dashboard'
      /// Access: Protected (ต้อง login ก่อน)
      GoRoute(
        path: AppConstants.dashboardRoute,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      /// หน้า Goals - จัดการเป้าหมาย
      /// Path: '/goals'
      /// Access: Protected (ต้อง login ก่อน)
      GoRoute(
        path: AppConstants.goalRoute,
        name: 'goals',
        builder: (context, state) => const GoalPage(),
      ),

      /// หน้า Goal Detail - รายละเอียดของเป้าหมาย
      /// Path: '/goals/detail'
      /// Access: Protected (ต้อง login ก่อน)
      GoRoute(
        path: AppConstants.goalDetailRoute,
        name: 'goal-detail',
        builder: (context, state) {
          final extra = state.extra;
          return GoalDetailPage(args: extra is GoalDetailArgs ? extra : null);
        },
      ),

      /// หน้า Reset Password - รีเซ็ตรหัสผ่าน
      /// Path: '/reset-password'
      /// Access: Public (ทุกคนเข้าได้)
      GoRoute(
        path: AppConstants.resetPasswordRoute,
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
    ],
    // === Error Handling ===
    
    /// Error Builder - สร้างหน้าแสดงเมื่อเข้า URL ที่ไม่มีอยู่ (404)
    /// จะแสดงหน้า Error พร้อมปุ่มกลับไปหน้าที่เหมาะสม
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ไอคอน Error
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            
            // ข้อความหลัก
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // ข้อความรายละเอียด - แสดง URL ที่ไม่พบ
            Text(
              'The page "${state.matchedLocation}" does not exist.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // ปุ่มกลับไปหน้าที่เหมาะสม
            ElevatedButton(
              onPressed: () async {
                // ตรวจสอบสถานะการ login และนำไปหน้าที่เหมาะสม
                final isLoggedIn = await _authService.isLoggedIn();
                final destination = isLoggedIn 
                    ? AppConstants.dashboardRoute  // ถ้า login แล้วไป Dashboard
                    : AppConstants.loginRoute;   // ถ้ายังไม่ได้ login ไป Login
                if (context.mounted) {
                  context.go(destination);
                }
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
  void goToProfile() => go(AppConstants.profileRoute);
  void goToResetPassword() => go(AppConstants.resetPasswordRoute);
  void goToDashboard() => go(AppConstants.dashboardRoute);
  void goToGoals() => go(AppConstants.goalRoute);
}