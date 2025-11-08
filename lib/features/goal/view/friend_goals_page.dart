import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/friends_service.dart';
import '../../../services/goal_service.dart';

/// FriendGoalsPage shows mutual goals between current user and a specific friend.
class FriendGoalsPage extends ConsumerStatefulWidget {
  final User friend;
  const FriendGoalsPage({super.key, required this.friend});

  @override
  ConsumerState<FriendGoalsPage> createState() => _FriendGoalsPageState();
}

class _FriendGoalsPageState extends ConsumerState<FriendGoalsPage> {
  final _goalService = GoalService();
  bool _loading = true;
  List<Map<String, dynamic>> _mutualGoals = const [];

  @override
  void initState() {
    super.initState();
    _loadMutualGoals();
  }

  Future<void> _loadMutualGoals() async {
    setState(() => _loading = true);
    try {
      final list = await _goalService.getMutualGoalsForFriend(widget.friend.id);
      setState(() => _mutualGoals = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load mutual goals: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mutual Goals', style: TextStyle(color: Colors.black)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMutualGoals,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: CircularProgressIndicator(),
                ))
              else if (_mutualGoals.isEmpty)
                const _EmptyState()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final g in _mutualGoals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MutualGoalCard(
                          goalId: _asInt(g['goal_id']) ?? _asInt(g['id']),
                          title: g['title'] ?? 'Untitled',
                          progress: _progressFrom(g),
                          durationText: _durationTextFrom(g),
                          streakText: _streakTextFrom(g),
                          completed: (g['status'] == 'completed'),
                          goalPicture: g['goal_picture'] as String?,
                          onRefresh: _loadMutualGoals,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_outlined, size: 48, color: Colors.green.shade600),
          ),
          const SizedBox(height: 24),
          const Text(
            'No mutual goals yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
            const SizedBox(height: 12),
          Text(
            'Create a goal and add a friend to start together.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          // No creation on this page; it displays only mutual goals with this friend.
        ],
      ),
    );
  }
}

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

String _durationTextFrom(Map<String, dynamic> g) {
  final d = g['duration_days'] ?? g['durationDays'];
  if (d is int) return '$d days';
  final raw = (g['duration'] ?? '').toString();
  if (raw.isNotEmpty) return raw;
  return 'Unknown';
}

String _streakTextFrom(Map<String, dynamic> g) {
  final streak = g['streak'];
  if (streak is int) return '$streak day streak';
  return '0 day streak';
}

double _progressFrom(Map<String, dynamic> g) {
  final p = g['progress'] ?? g['progress_percent'] ?? g['progressPercent'];
  if (p is num) {
    if (p > 1) return (p / 100).clamp(0, 1).toDouble();
    return p.toDouble();
  }
  return 0.0;
}

// Helper to resolve image either from network URL or fallback asset
ImageProvider _getImageProvider(String imageData) {
  if (imageData.startsWith('http')) {
    return NetworkImage(imageData);
  }
  return const AssetImage('assets/images/placeholder.png');
}

/// Simplified mutual goal card replicating styling similar to main goal list.
class _MutualGoalCard extends StatelessWidget {
  final int? goalId;
  final String title;
  final double progress; // 0-1
  final String durationText;
  final String streakText;
  final bool completed;
  final String? goalPicture;
  final Future<void> Function()? onRefresh;

  const _MutualGoalCard({
    this.goalId,
    required this.title,
    required this.progress,
    required this.durationText,
    required this.streakText,
    required this.completed,
    this.goalPicture,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    const themeColor = Colors.deepPurple;
    return Card(
      elevation: 2.5,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                goalPicture != null && goalPicture!.isNotEmpty
                    ? Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: _getImageProvider(goalPicture!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.groups_2_outlined, color: themeColor),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                      const SizedBox(height: 4),
                      const Text('Mutual', style: TextStyle(fontSize: 12, color: Colors.black)),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: completed ? themeColor : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: completed ? themeColor : Colors.transparent,
                  ),
                  child: completed ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Progress', style: TextStyle(color: Colors.black)),
                const Spacer(),
                Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(themeColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(durationText, style: const TextStyle(color: Colors.black, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(streakText, style: const TextStyle(color: Colors.black, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Removed gradient initial & friend header widgets as per new simplified design.
