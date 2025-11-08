import '../core/config/api_config.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';

// Helper to safely parse ints from dynamic values (int, String, or Map with id)
int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  if (v is Map) {
    final id = v['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
  }
  return null;
}

/// Service for managing friends functionality
class FriendsService {
  final ApiClient _apiClient = ApiClient();

  /// Search for users by username
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.baseUrl}/api/friends/search',
        queryParameters: {'username': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search users: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Send friend request
  Future<bool> sendFriendRequest(int friendId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.baseUrl}/api/friends/request',
        data: {'friend_id': friendId},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to send friend request: ${e.message}');
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(int friendId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.baseUrl}/api/friends/accept',
        data: {'friend_id': friendId},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to accept friend request: ${e.message}');
    }
  }

  /// Get friends list and pending requests
  Future<FriendsData> getFriends() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.baseUrl}/api/friends',
      );

      if (response.statusCode == 200) {
        return FriendsData.fromJson(response.data);
      } else {
        throw Exception('Failed to get friends: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Unfriend a user
  Future<bool> unfriend(int friendId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.baseUrl}/api/friends/unfriend',
        data: {'friend_id': friendId},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to unfriend: ${e.message}');
    }
  }

  /// Get user details by ID
  Future<User> getUserById(int userId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.baseUrl}/api/user/$userId',
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to get user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}

/// User model
class User {
  final int id;
  final String username;
  final String? email;
  final String? profilePicture;
  final String? gender;
  final String? birthday;
  final int? avatarId;
  final String? createdAt;
  final String? status; // for search results (pending, accepted, etc.)
  final Avatar? avatar;

  User({
    required this.id,
    required this.username,
    this.email,
    this.profilePicture,
    this.gender,
    this.birthday,
    this.avatarId,
    this.createdAt,
    this.status,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _asInt(json['id']) ?? 0,
      username: json['username'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      gender: json['gender'],
      birthday: json['birthday'],
      avatarId: _asInt(json['avatar_id']),
      createdAt: json['created_at'],
      status: json['status'],
      avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_picture': profilePicture,
      'gender': gender,
      'birthday': birthday,
      'avatar_id': avatarId,
      'created_at': createdAt,
      'status': status,
      'avatar': avatar?.toJson(),
    };
  }
}

/// Avatar model
class Avatar {
  final int id;
  final int userId;
  final String name;
  final String? appearance;
  final String? equipment;
  final int? head;
  final int? body;
  final int? hand;
  final int? accessory;
  final Equipped? equipped; // parsed from backend (joined item objects)

  Avatar({
    required this.id,
    required this.userId,
    required this.name,
    this.appearance,
    this.equipment,
    this.head,
    this.body,
    this.hand,
    this.accessory,
    this.equipped,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['user_id']) ?? 0,
      name: json['name'],
      appearance: json['appearance'],
      equipment: json['equipment'],
      head: _asInt(json['head']),
      body: _asInt(json['body']),
      hand: _asInt(json['hand']),
      // 'accessory' may be an id or an object { id, ... } per backend response
      accessory: _asInt(json['accessory']),
      equipped: (json['equipped'] is Map<String, dynamic>)
          ? Equipped.fromJson(json['equipped'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'appearance': appearance,
      'equipment': equipment,
      'head': head,
      'body': body,
      'hand': hand,
      'accessory': accessory,
      'equipped': equipped?.toJson(),
    };
  }
}

/// Per-slot equipped items container
class Equipped {
  final EquippedItem? head;
  final EquippedItem? body;
  final EquippedItem? hand;
  final EquippedItem? accessory;

  Equipped({this.head, this.body, this.hand, this.accessory});

  factory Equipped.fromJson(Map<String, dynamic> json) {
    EquippedItem? parse(String key) {
      final v = json[key];
      if (v is Map<String, dynamic> && v['id'] != null) {
        return EquippedItem.fromJson(v);
      }
      return null;
    }
    return Equipped(
      head: parse('head'),
      body: parse('body'),
      hand: parse('hand'),
      accessory: parse('accessory'),
    );
  }

  Map<String, dynamic> toJson() => {
        'head': head?.toJson(),
        'body': body?.toJson(),
        'hand': hand?.toJson(),
        'accessory': accessory?.toJson(),
      };
}

class EquippedItem {
  final int id;
  final String name;
  final String slot;
  final String? picture;
  final String? type;

  EquippedItem({
    required this.id,
    required this.name,
    required this.slot,
    this.picture,
    this.type,
  });

  factory EquippedItem.fromJson(Map<String, dynamic> json) {
    return EquippedItem(
      id: _asInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slot: json['slot']?.toString() ?? '',
      picture: json['picture']?.toString(),
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slot': slot,
        'picture': picture,
        'type': type,
      };
}

/// Friends data container
class FriendsData {
  final List<User> friends;
  final List<User> pending;

  FriendsData({required this.friends, required this.pending});

  factory FriendsData.fromJson(Map<String, dynamic> json) {
    return FriendsData(
      friends: (json['friends'] as List)
          .map((friend) => User.fromJson(friend))
          .toList(),
      pending: (json['pending'] as List)
          .map((request) => User.fromJson(request))
          .toList(),
    );
  }
}
