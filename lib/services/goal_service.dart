import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import 'api_client.dart';

class GoalService {
  final Dio _http = ApiClient().dio;

  Future<List<Map<String, dynamic>>> getGoals() async {
    final res = await _http.get(ApiConfig.goalsEndpoint());
    if (res.statusCode == 200 && res.data is List) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load goals');
  }

  Future<Map<String, dynamic>> getGoal(int goalId) async {
    final res = await _http.get('${ApiConfig.goalsEndpoint()}/$goalId');
    if (res.statusCode == 200 && res.data is Map) {
      return (res.data as Map).cast<String, dynamic>();
    }
    throw Exception('Failed to load goal');
  }

  Future<Map<String, dynamic>> createGoal({
    required String title,
    String? description,
    int? durationDays,
    String? durationText,
    String? category,
    String type = 'single',
    int? friendId,
    DateTime? startDate,
    String? goalPicture,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      if (description != null) 'description': description,
      if (durationText != null) 'duration': durationText,
      if (durationDays != null) 'duration_days': durationDays,
      if (category != null) 'category': category,
      'type': type,
      if (friendId != null) 'friend_id': friendId,
      if (startDate != null)
        'start_date': '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      if (goalPicture != null) 'goal_picture': goalPicture,
    };
    final res = await _http.post(ApiConfig.goalsEndpoint(), data: data);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return (res.data as Map).cast<String, dynamic>();
    }
    throw Exception('Failed to create goal');
  }

  Future<List<DateTime>> getLogs(int goalId) async {
    final res = await _http.get(ApiConfig.goalLogsEndpoint(goalId));
    if (res.statusCode == 200 && res.data is List) {
      final List list = res.data as List;
      return list.map((e) {
        final s = (e['date']?.toString() ?? '').trim();
        // Expect YYYY-MM-DD
        final dt = DateTime.tryParse(s);
        if (dt != null) return DateTime(dt.year, dt.month, dt.day);
        return null;
      }).whereType<DateTime>().toList();
    }
    throw Exception('Failed to load logs');
  }

  Future<void> logDay(int goalId, DateTime day, {String? description}) async {
    final dateStr = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final res = await _http.post(
      ApiConfig.goalLogsEndpoint(goalId),
      data: {
        'date': dateStr,
        if (description != null) 'description': description,
      },
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final data = res.data;
      final msg = (data is Map && data['error'] is String)
          ? data['error'] as String
          : 'Failed to add log';
      throw Exception(msg);
    }
  }

  Future<void> deleteLog(int goalId, DateTime day) async {
    final dateStr = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final res = await _http.delete(
      ApiConfig.goalLogsEndpoint(goalId),
      data: {'date': dateStr},
    );
    if (res.statusCode != 200) {
      final data = res.data;
      final msg = (data is Map && data['error'] is String)
          ? data['error'] as String
          : 'Failed to delete log';
      throw Exception(msg);
    }
  }

  Future<void> deleteGoal(int goalId) async {
    final res = await _http.delete('${ApiConfig.goalsEndpoint()}/$goalId');
    if (res.statusCode != 200) {
      final data = res.data;
      final msg = (data is Map && data['error'] is String)
          ? data['error'] as String
          : 'Failed to delete goal';
      throw Exception(msg);
    }
  }

  /// Convenience helper: fetch mutual goals for a given friend id.
  /// This filters the full goals list client-side until backend provides
  /// a dedicated endpoint.
  Future<List<Map<String, dynamic>>> getMutualGoalsForFriend(int friendId) async {
    final all = await getGoals();
    return all.where((g) {
      final type = (g['type'] ?? g['goal_type'] ?? '').toString().toLowerCase();
      if (type != 'mutual') return false;
      final fid = g['friend_id'] ?? g['friendId'] ?? g['friend_id_id'];
      if (fid == friendId) return true;
      if (fid == null && g['friend'] is Map && g['friend']['id'] == friendId) return true;
      return false;
    }).toList();
  }
}
