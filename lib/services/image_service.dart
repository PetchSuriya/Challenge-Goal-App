import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// ImageService - บริการจัดการรูปภาพโปรไฟล์
/// 
/// หน้าที่หลัก:
/// - เลือกรูปภาพจากแกลเลอรี่หรือกล้อง
/// - บันทึกรูปภาพไปยัง local storage
/// - จัดการ file path ของรูปภาพ
/// - รองรับทั้ง mobile และ web platform
class ImageService {
  /// Instance ของ ImagePicker สำหรับเลือกรูปภาพ
  static final ImagePicker _picker = ImagePicker();

  /// === การเลือกรูปภาพ ===
  
  /// เลือกรูปภาพจากแกลเลอรี่
  /// Return: XFile? - file ที่เลือก หรือ null ถ้าไม่ได้เลือก
  /// 
  /// ตัวอย่างการใช้งาน:
  /// ```dart
  /// final XFile? image = await ImageService.pickFromGallery();
  /// if (image != null) {
  ///   // ทำอะไรกับรูปที่เลือก
  /// }
  /// ```
  static Future<XFile?> pickFromGallery() async {
    try {
      // เลือกรูปจากแกลเลอรี่ด้วย quality 80% เพื่อลดขนาดไฟล์
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // ลดคุณภาพเป็น 80% เพื่อประหยัด storage
        maxWidth: 1024,   // กำหนดขนาดสูงสุด 1024px
        maxHeight: 1024,  // กำหนดขนาดสูงสุด 1024px
      );
      return image;
    } catch (e) {
      // Handle error การเลือกรูป
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// เลือกรูปภาพจากกล้อง
  /// Return: XFile? - file ที่ถ่าย หรือ null ถ้าไม่ได้ถ่าย
  /// 
  /// ตัวอย่างการใช้งาน:
  /// ```dart
  /// final XFile? image = await ImageService.pickFromCamera();
  /// if (image != null) {
  ///   // ทำอะไรกับรูปที่ถ่าย
  /// }
  /// ```
  static Future<XFile?> pickFromCamera() async {
    try {
      // ถ่ายรูปด้วยกล้องด้วย quality 80%
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // ลดคุณภาพเป็น 80%
        maxWidth: 1024,   // กำหนดขนาดสูงสุด 1024px
        maxHeight: 1024,  // กำหนดขนาดสูงสุด 1024px
      );
      return image;
    } catch (e) {
      // Handle error การถ่ายรูป
      debugPrint('Error taking photo from camera: $e');
      return null;
    }
  }

  /// === การบันทึกรูปภาพ ===
  
  /// บันทึกรูปภาพไปยัง local storage ของแอป
  /// 
  /// Parameters:
  /// - imageFile: XFile ที่จะบันทึก
  /// - userId: ID ของผู้ใช้ (ใช้สำหรับตั้งชื่อไฟล์)
  /// 
  /// Return: String? - path ของไฟล์ที่บันทึก หรือ null ถ้าเกิดข้อผิดพลาด
  /// 
  /// ตัวอย่างการใช้งาน:
  /// ```dart
  /// final String? savedPath = await ImageService.saveProfileImage(
  ///   imageFile: selectedImage,
  ///   userId: 'user123',
  /// );
  /// if (savedPath != null) {
  ///   // อัพเดท path ใน database หรือ state
  /// }
  /// ```
  static Future<String?> saveProfileImage({
    required XFile imageFile,
    required String userId,
  }) async {
    try {
      // สำหรับ Web platform - ไม่สามารถบันทึกไฟล์ถาวรได้
      if (kIsWeb) {
        // บน Web ใช้ path ของ XFile โดยตรง (จะเป็น blob URL)
        return imageFile.path;
      }

      // สำหรับ Mobile platforms (Android, iOS)
      
      // 1. หา directory ที่จะเก็บไฟล์
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profileImagesDir = path.join(appDir.path, 'profile_images');
      
      // 2. สร้าง directory ถ้ายังไม่มี
      final Directory profileDir = Directory(profileImagesDir);
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // 3. สร้างชื่อไฟล์ใหม่ตาม pattern: profile_{userId}_{timestamp}.jpg
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = path.join(profileImagesDir, fileName);

      // 4. Copy ไฟล์จาก temporary path ไปยัง permanent path
      final File sourceFile = File(imageFile.path);
      final File savedFile = await sourceFile.copy(newPath);

      // 5. ลบไฟล์โปรไฟล์เก่า (ถ้ามี) เพื่อประหยัด storage
      await _deleteOldProfileImages(userId, profileImagesDir);

      return savedFile.path;
    } catch (e) {
      // Handle error การบันทึกไฟล์
      debugPrint('Error saving profile image: $e');
      return null;
    }
  }

  /// === Helper Methods ===
  
  /// ลบไฟล์โปรไฟล์เก่าของผู้ใช้เพื่อประหยัด storage
  /// 
  /// Parameters:
  /// - userId: ID ของผู้ใช้
  /// - profileImagesDir: path ของ directory ที่เก็บรูปโปรไฟล์
  static Future<void> _deleteOldProfileImages(
    String userId, 
    String profileImagesDir,
  ) async {
    try {
      final Directory dir = Directory(profileImagesDir);
      if (!await dir.exists()) return;

      // หาไฟล์ทั้งหมดในโฟลเดอร์
      final List<FileSystemEntity> files = await dir.list().toList();
      
      // กรองเฉพาะไฟล์ที่เป็นของ user นี้
      final List<File> userProfileFiles = files
          .whereType<File>()
          .where((file) => path.basename(file.path).startsWith('profile_$userId'))
          .toList();

      // เรียงตามเวลา (ใหม่สุดก่อน)
      userProfileFiles.sort((a, b) => 
        File(b.path).lastModifiedSync().compareTo(
          File(a.path).lastModifiedSync()
        )
      );

      // เก็บไฟล์ใหม่สุด 1 ไฟล์ ลบที่เหลือ
      if (userProfileFiles.length > 1) {
        for (int i = 1; i < userProfileFiles.length; i++) {
          await userProfileFiles[i].delete();
          debugPrint('Deleted old profile image: ${userProfileFiles[i].path}');
        }
      }
    } catch (e) {
      debugPrint('Error deleting old profile images: $e');
    }
  }

  /// ตรวจสอบว่าไฟล์รูปภาพมีอยู่จริงหรือไม่
  /// 
  /// Parameters:
  /// - imagePath: path ของรูปภาพที่จะตรวจสอบ
  /// 
  /// Return: bool - true ถ้าไฟล์มีอยู่, false ถ้าไม่มี
  static Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    
    // สำหรับ Web - เช็คว่าเป็น valid URL หรือไม่
    if (kIsWeb) {
      return imagePath.startsWith('blob:') || imagePath.startsWith('http');
    }
    
    // สำหรับ Mobile - เช็คว่าไฟล์มีอยู่จริง
    return await File(imagePath).exists();
  }

  /// แสดง bottom sheet ให้เลือกว่าจะเลือกรูปจากแหล่งไหน
  /// 
  /// Parameters:
  /// - context: BuildContext สำหรับแสดง bottom sheet
  /// 
  /// Return: XFile? - ไฟล์รูปที่เลือก หรือ null ถ้าไม่ได้เลือก
  /// 
  /// ตัวอย่างการใช้งาน:
  /// ```dart
  /// final XFile? selectedImage = await ImageService.showImageSourceDialog(context);
  /// if (selectedImage != null) {
  ///   // ทำอะไรกับรูปที่เลือก
  /// }
  /// ```
  static Future<XFile?> showImageSourceDialog(context) async {
    return await showModalBottomSheet<XFile?>(
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
                  'เลือกรูปภาพจาก',
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
                  title: const Text('แกลเลอรี่'),
                  subtitle: const Text('เลือกรูปจากอัลบั้มของคุณ'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image = await pickFromGallery();
                    if (context.mounted) {
                      Navigator.of(context).pop(image);
                    }
                  },
                ),
                
                // Camera Option
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Colors.green,
                  ),
                  title: const Text('กล้อง'),
                  subtitle: const Text('ถ่ายรูปใหม่ด้วยกล้อง'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image = await pickFromCamera();
                    if (context.mounted) {
                      Navigator.of(context).pop(image);
                    }
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
}