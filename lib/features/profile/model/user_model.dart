import 'dart:convert';

/// User model representing a user in the application
/// 
/// This model handles user data serialization/deserialization and provides
/// convenient methods for working with user information.
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  
  /// URL ของรูปโปรไฟล์ (สำหรับรูปจาก server/API)
  final String? profileImageUrl;
  
  /// Path ของรูปโปรไฟล์ที่เก็บใน local storage
  /// ใช้สำหรับรูปที่ user เลือกจากแกลเลอรี่หรือถ่ายด้วยกล้อง
  final String? profileImagePath;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.profileImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the full name by combining first and last name
  String get fullName => '$firstName $lastName';

  /// Get initials from first and last name
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Check if user has a profile image (either URL or local path)
  bool get hasProfileImage => 
    (profileImageUrl != null && profileImageUrl!.isNotEmpty) ||
    (profileImagePath != null && profileImagePath!.isNotEmpty);

  /// Get the effective profile image source (prefer local path over URL)
  String? get effectiveProfileImage => profileImagePath ?? profileImageUrl;

  /// Check if user has a phone number
  bool get hasPhoneNumber => phoneNumber != null && phoneNumber!.isNotEmpty;

  /// Convert UserModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'profile_image_path': profileImagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      profileImagePath: json['profile_image_path']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  /// Convert to JSON string for storage
  String toJsonString() => jsonEncode(toJson());

  /// Create UserModel from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserModel.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a mock user for testing purposes
  factory UserModel.mock({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id ?? 'mock_user_001',
      email: email ?? 'user@example.com',
      firstName: firstName ?? 'John',
      lastName: lastName ?? 'Doe',
      phoneNumber: phoneNumber,
      profileImageUrl: null,
      profileImagePath: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Private helper methods

  /// Safely parse DateTime from JSON value
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    }
    
    return DateTime.now();
  }

  // Object overrides

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, hasPhone: $hasPhoneNumber, hasImage: $hasProfileImage, imagePath: $profileImagePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.profileImageUrl == profileImageUrl &&
        other.profileImagePath == profileImagePath &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      firstName,
      lastName,
      phoneNumber,
      profileImageUrl,
      profileImagePath,
      createdAt,
      updatedAt,
    );
  }
}