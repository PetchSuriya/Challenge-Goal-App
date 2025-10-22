import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../controller/profile_controller.dart';
import '../model/user_model.dart';
import '../../../services/image_service.dart';
import '../../../core/constants/app_constants.dart';

/// ProfilePage - หน้าแสดงข้อมูลผู้ใช้และการจัดการโปรไฟล์
/// 
/// ฟีเจอร์หลัก:
/// - แสดงข้อมูลส่วนตัวของผู้ใช้
/// - แก้ไขข้อมูลส่วนตัว (ชื่อ, เพศ, วันเกิด, เบอร์โทร)
/// - การจัดการบัญชี (เปลี่ยนอีเมล, รีเซ็ตรหัสผ่าน)
/// - ล็อกเอาต์
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // === Controllers สำหรับจัดการ TextField ===
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // === ตัวแปรสำหรับเก็บข้อมูลที่แก้ไขแล้ว ===
  // เก็บข้อมูลที่ผู้ใช้แก้ไขจนกว่าจะ logout หรือ refresh หน้า
  String? _editedName;
  String? _editedGender;
  DateTime? _editedBirthday;
  String? _editedPhone;

  // === Lifecycle Methods ===
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _refreshProfileDataOnLoad();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // === Private Initialization Methods ===
  
  /// เริ่มต้น Controllers สำหรับ TextField
  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  /// รีเฟรชข้อมูลโปรไฟล์เมื่อเข้าหน้า
  void _refreshProfileDataOnLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).refreshProfile();
    });
  }

  /// ปิด Controllers เพื่อป้องกัน memory leaks
  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
  }

  // === Helper Methods ===
  
  /// เติมข้อมูลลงใน Controllers จากข้อมูล User
  void _populateControllers(UserModel user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber ?? '';
  }

  /// แปลง DateTime เป็น String แบบอ่านง่าย
  String? _formatBirthday(DateTime? date) {
    if (date == null) return null;
    
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // === Main Build Method ===
  
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    
    // ฟัง state changes สำหรับแสดง error หรือ success messages
    _listenToStateChanges();

    // เติมข้อมูลลง controllers เมื่อมีข้อมูล user และไม่ได้อยู่ในโหมดแก้ไข
    _populateControllersIfNeeded(profileState);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: _buildBody(profileState),
    );
  }

  // === State Management Methods ===
  
  /// ฟัง state changes และแสดง SnackBar เมื่อมี error หรือ success
  void _listenToStateChanges() {
    ref.listen<ProfileState>(profileControllerProvider, (previous, next) {
      if (next.error != null) {
        _showErrorSnackBar(next.error!);
        ref.read(profileControllerProvider.notifier).clearError();
      } else if (next.isSuccess) {
        _showSuccessSnackBar(AppConstants.profileUpdateSuccess);
        ref.read(profileControllerProvider.notifier).clearSuccess();
      }
    });
  }

  /// เติมข้อมูลลง controllers หากจำเป็น
  void _populateControllersIfNeeded(ProfileState state) {
    if (state.user != null && !state.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateControllers(state.user!);
      });
    }
  }

  // === UI Builder Methods ===
  
  /// แสดง SnackBar สำหรับ error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// แสดง SnackBar สำหรับ success
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// สร้าง AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Profile'),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.go(AppConstants.loginRoute),
      ),
    );
  }

  /// สร้าง body หลักของหน้า
  Widget _buildBody(ProfileState state) {
    // แสดง loading เมื่อกำลังโหลดและยังไม่มีข้อมูล
    if (state.isLoading && state.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // แสดงข้อความเมื่อไม่มีข้อมูล user
    if (state.user == null) {
      return const Center(child: Text('No user data available'));
    }

    // แสดงเนื้อหาหลักเมื่อมีข้อมูล
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSummary(state.user!),  // ข้อมูลสรุปโปรไฟล์
          const SizedBox(height: 30),
          _buildPersonalInfo(state.user!),     // ข้อมูลส่วนตัว
          const SizedBox(height: 30),
          _buildAccountSection(),              // การจัดการบัญชี
          const SizedBox(height: 30),
          _buildDangerZone(),                  // ส่วนอันตราย (logout)
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // === Profile Summary Section ===
  
  /// สร้างส่วนสรุปข้อมูลโปรไฟล์ (รูปโปรไฟล์, ชื่อ, อีเมล)
  Widget _buildProfileSummary(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Profile Summary',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Profile Picture & Change Button
          _buildProfileImageWidget(user),
          const SizedBox(height: 16),
          
          // Name & Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // เพิ่มสีดำเพื่อให้อ่านง่าย
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified,
                  size: 20,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Email
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87, // เปลี่ยนเป็นสีดำเพื่อให้อ่านง่าย
            ),
          ),
          const SizedBox(height: 16),
          
          // Member Since
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.black87, // เปลี่ยนเป็นสีดำเพื่อให้อ่านง่าย
                ),
                const SizedBox(width: 8),
                Text(
                  'Member since August 2023',
                  style: const TextStyle(
                    color: Colors.black87, // เปลี่ยนเป็นสีดำเพื่อให้อ่านง่าย
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === Personal Information Section ===
  
  /// สร้างส่วนข้อมูลส่วนตัว (ชื่อ, เพศ, วันเกิด, เบอร์โทร)
  /// ผู้ใช้สามารถแก้ไขข้อมูลเหล่านี้ได้โดยกดที่แต่ละรายการ
  Widget _buildPersonalInfo(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.black),
                const SizedBox(width: 12),
                const Text(
                  'Personal Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildEditableInfoItem(Icons.badge_outlined, 'Name', _editedName ?? user.fullName, () => _showEditNameDialog()),
          _buildEditableInfoItem(Icons.wc_outlined, 'Gender', _editedGender ?? 'Male', () => _showEditGenderDialog()),
          _buildEditableInfoItem(Icons.cake_outlined, 'Birthday', _formatBirthday(_editedBirthday) ?? 'August 15, 1990', () => _showEditBirthdayDialog()),
          _buildEditableInfoItem(Icons.phone_outlined, 'Phone', _editedPhone ?? user.phoneNumber ?? 'Not provided', () => _showEditPhoneDialog()),
        ],
      ),
    );
  }

  // === Account Management Section ===
  
  /// สร้างส่วนการจัดการบัญชี (เปลี่ยนอีเมล, รีเซ็ตรหัสผ่าน)
  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.security_outlined, color: Colors.black),
                const SizedBox(width: 12),
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildActionItem(
            Icons.email_outlined,
            'Change Email',
            'Update your email address',
            () => _showChangeEmailDialog(),
          ),
          _buildActionItem(
            Icons.lock_reset_outlined,
            'Reset Password',
            'Reset password via email',
            () => _showResetPasswordDialog(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // === Danger Zone Section ===
  
  /// สร้างส่วนอันตราย (ปุ่มล็อกเอาต์)
  /// ใช้สีแดงเพื่อเตือนว่าเป็นการกระทำที่อันตราย
  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.warning_outlined, color: Colors.red.shade600),
                const SizedBox(width: 12),
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign out of your account on this device',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Reusable UI Components ===
  
  /// สร้างรายการข้อมูลที่สามารถแก้ไขได้
  /// ใช้สำหรับแสดงข้อมูลส่วนตัวที่ผู้ใช้สามารถกดเพื่อแก้ไข
  Widget _buildEditableInfoItem(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700), // เปลี่ยนจาก shade500 เป็น shade700
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 0, 0, 0), // เปลี่ยนจาก shade600 เป็น shade800
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // เพิ่มสีดำเพื่อให้อ่านง่าย
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// สร้างรายการการกระทำ (Action Item)
  /// ใช้สำหรับปุ่มต่างๆ ในส่วน Account Management
  Widget _buildActionItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700), // เปลี่ยนจาก shade500 เป็น shade700 สำหรับ Account section
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // เพิ่มสีดำเพื่อให้อ่านง่าย
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87, // เปลี่ยนเป็นสีดำ subtitle
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade600, // เปลี่ยนจาก shade400 เป็น shade600 สำหรับ arrow icon
            ),
          ],
        ),
      ),
    );
  }

  // === Dialog Methods ===
  
  /// แสดง Dialog ยืนยันการล็อกเอาต์
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?\nYou will need to login again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(profileControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// แสดง Dialog สำหรับเปลี่ยนอีเมล
  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.email_outlined, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Change Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your new email address and current password to confirm the change.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Email change request sent to ${emailController.text}'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  // === Personal Info Edit Dialogs ===
  
  /// แสดง Dialog สำหรับแก้ไขชื่อ
  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _editedName ?? ref.read(profileControllerProvider).user?.fullName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.badge_outlined, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Edit Name'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your new name:'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _editedName = nameController.text;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Name updated to: ${nameController.text}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// แสดง Dialog สำหรับเลือกเพศ
  void _showEditGenderDialog() {
    String selectedGender = _editedGender ?? 'Male';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.wc_outlined, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              const Text('Edit Gender'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Male'),
                value: 'Male',
                groupValue: selectedGender,
                onChanged: (value) => setState(() => selectedGender = value!),
              ),
              RadioListTile<String>(
                title: const Text('Female'),
                value: 'Female',
                groupValue: selectedGender,
                onChanged: (value) => setState(() => selectedGender = value!),
              ),
              RadioListTile<String>(
                title: const Text('Other'),
                value: 'Other',
                groupValue: selectedGender,
                onChanged: (value) => setState(() => selectedGender = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _editedGender = selectedGender;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gender updated to: $selectedGender'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// แสดง Dialog สำหรับเลือกวันเกิด พร้อม Date Picker
  void _showEditBirthdayDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cake_outlined, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Edit Birthday'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your birthday:'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _editedBirthday != null 
                  ? _formatBirthday(_editedBirthday)! 
                  : 'August 15, 1990',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _editedBirthday ?? DateTime(1990, 8, 15),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _editedBirthday = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Select Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Birthday updated to: ${_editedBirthday != null ? _formatBirthday(_editedBirthday)! : "August 15, 1990"}'
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// แสดง Dialog สำหรับแก้ไขเบอร์โทรศัพท์
  void _showEditPhoneDialog() {
    final phoneController = TextEditingController(text: _editedPhone ?? ref.read(profileControllerProvider).user?.phoneNumber ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.phone_outlined, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Edit Phone'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your new phone number:'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '+66 XX XXX XXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isNotEmpty) {
                setState(() {
                  _editedPhone = phoneController.text;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Phone updated to: ${phoneController.text}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// แสดง Dialog สำหรับรีเซ็ตรหัสผ่าน
  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_reset_outlined, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Reset Password'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A password reset link will be sent to your email address.'),
            SizedBox(height: 8),
            Text(
              'Please check your email and follow the instructions to reset your password.',
              style: TextStyle(color: Colors.black87), // เปลี่ยนเป็น Colors.black87 เพื่อให้อ่านง่าย
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.email_outlined, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Password reset link sent to your email!'),
                    ],
                  ),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  // === Profile Image Widget ===
  
  /// สร้าง Widget สำหรับแสดงรูปโปรไฟล์พร้อมปุ่มเปลี่ยนรูป
  /// 
  /// ฟีเจอร์:
  /// - แสดงรูปโปรไฟล์จาก local path หรือ URL
  /// - แสดง placeholder ถ้าไม่มีรูป
  /// - ปุ่มกล้องสำหรับเปลี่ยนรูป
  /// - Loading indicator ระหว่างอัพโหลด
  Widget _buildProfileImageWidget(UserModel user) {
    final profileState = ref.watch(profileControllerProvider);
    
    return GestureDetector(
      onTap: () => _showImagePickerDialog(),
      child: Stack(
        children: [
          // รูปโปรไฟล์หลัก
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _buildProfileImageContent(user),
          ),
          
          // Loading Overlay ระหว่างอัพโหลด
          if (profileState.isLoading)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          
          // ปุ่มกล้อง
          if (!profileState.isLoading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// สร้างเนื้อหาของรูปโปรไฟล์ (รูปจริงหรือ placeholder)
  Widget _buildProfileImageContent(UserModel user) {
    // ใช้ effectiveProfileImage ที่จะเลือก local path ก่อน แล้วค่อย URL
    final imageSource = user.effectiveProfileImage;
    
    if (imageSource == null || imageSource.isEmpty) {
      // ไม่มีรูป - แสดง placeholder
      return const Icon(
        Icons.person,
        size: 50,
        color: Colors.white,
      );
    }

    // มีรูป - ตรวจสอบว่าเป็น local file หรือ network URL
    if (kIsWeb || imageSource.startsWith('http')) {
      // Web platform หรือ network URL
      return ClipOval(
        child: Image.network(
          imageSource,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            // ถ้าโหลดรูปไม่ได้ แสดง placeholder
            return const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            // แสดง loading ระหว่างโหลดรูป
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    } else {
      // Local file path (สำหรับ mobile)
      return ClipOval(
        child: Image.file(
          File(imageSource),
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            // ถ้าโหลดไฟล์ไม่ได้ แสดง placeholder
            return const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            );
          },
        ),
      );
    }
  }

  /// แสดง Dialog สำหรับเลือกแหล่งที่มาของรูปภาพ
  /// 
  /// ตัวเลือก:
  /// - เลือกจากแกลเลอรี่
  /// - ถ่ายรูปด้วยกล้อง
  /// - ลบรูปโปรไฟล์ (ถ้ามีรูปอยู่)
  Future<void> _showImagePickerDialog() async {
    final user = ref.read(profileControllerProvider).user;
    final hasImage = user?.hasProfileImage ?? false;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'เปลี่ยนรูปโปรไฟล์',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Gallery Option
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.blue,
                  ),
                  title: const Text('เลือกจากแกลเลอรี่'),
                  subtitle: const Text('เลือกรูปจากอัลบั้มของคุณ'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                
                // Camera Option
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Colors.green,
                  ),
                  title: const Text('ถ่ายรูปใหม่'),
                  subtitle: const Text('ถ่ายรูปใหม่ด้วยกล้อง'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                
                // Remove Image Option (แสดงเฉพาะเมื่อมีรูปอยู่)
                if (hasImage)
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'ลบรูปโปรไฟล์',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('ลบรูปโปรไฟล์ปัจจุบัน'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _removeProfileImage();
                    },
                  ),
                
                const SizedBox(height: 10),
                
                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// เลือกรูปจากแหล่งที่ระบุและอัพเดทโปรไฟล์
  /// 
  /// Parameters:
  /// - source: แหล่งที่มาของรูป (gallery หรือ camera)
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? selectedImage;
      
      if (source == ImageSource.gallery) {
        selectedImage = await ImageService.pickFromGallery();
      } else {
        selectedImage = await ImageService.pickFromCamera();
      }

      if (selectedImage != null) {
        // อัพเดทรูปโปรไฟล์ผ่าน ProfileController
        await ref.read(profileControllerProvider.notifier).updateProfileImage(selectedImage);
        
        // แสดงข้อความสำเร็จ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('อัพเดทรูปโปรไฟล์สำเร็จ!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      // แสดงข้อความผิดพลาด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  /// ลบรูปโปรไฟล์ปัจจุบัน
  Future<void> _removeProfileImage() async {
    try {
      // แสดง confirmation dialog
      final confirmed = await _showConfirmationDialog(
        title: 'ลบรูปโปรไฟล์',
        message: 'คุณต้องการลบรูปโปรไฟล์ปัจจุบันใช่หรือไม่?',
        confirmText: 'ลบ',
        confirmColor: Colors.red,
      );

      if (confirmed) {
        // ลบรูปโปรไฟล์ผ่าน ProfileController
        await ref.read(profileControllerProvider.notifier).removeProfileImage();
        
        // แสดงข้อความสำเร็จ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('ลบรูปโปรไฟล์สำเร็จ!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      // แสดงข้อความผิดพลาด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  /// แสดง Confirmation Dialog สำหรับการดำเนินการที่สำคัญ
  /// 
  /// Parameters:
  /// - title: หัวข้อของ dialog
  /// - message: ข้อความที่จะแสดง
  /// - confirmText: ข้อความปุ่มยืนยัน (default: 'ยืนยัน')
  /// - confirmColor: สีของปุ่มยืนยัน (default: Colors.red)
  /// 
  /// Return: true ถ้า user กดยืนยัน, false ถ้ายกเลิก
  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    Color confirmColor = Colors.red,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    ) ?? false; // ถ้ากด back หรือกดนอก dialog ให้ return false
  }
}