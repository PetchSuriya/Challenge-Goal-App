import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import 'goal_detail_page.dart';
import 'goal_form_page.dart';
import '../../../services/goal_service.dart';
import 'dart:convert';

/// GoalPage - Redesigned to match login style with custom header, streak card, and goal list
class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  bool _showMutual = false;
  final _goalService = GoalService();
  bool _loading = true;
  List<Map<String, dynamic>> _goals = const [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _loading = true);
    try {
      final list = await _goalService.getGoals();
      setState(() {
        _goals = list;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load goals: $e')),
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
        leadingWidth: 220,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppConstants.homeRoute),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showMutual = !_showMutual;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _showMutual
                      ? Icons.person_outline
                      : Icons.people_alt_outlined,
                ),
                label: Text(_showMutual ? 'Personal' : 'Friends'),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _GradientActionButton(
              icon: Icons.add,
              label: 'Add Goal',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalFormPage()),
                );
                if (result != null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goal added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  await _loadGoals();
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Streak Card
            const _CurrentStreakCard(days: 12, totalDays: 100, percent: 0.12),

            const SizedBox(height: 16),

            // Header: Your Goals
            Row(
              children: [
                Text(
                  _showMutual ? 'Mutual Goals' : 'Your Goals',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                if (_loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${_goals.length} active',
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            if (_loading)
              const SizedBox.shrink()
            else if (_goals.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No goals yet. Tap "Add Goal" to create one.', style: TextStyle(color: Colors.black)),
              )
            else
              Column(
                children: [
                  for (final g in _goals)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(
                        title: g['title'] ?? 'Untitled',
                        category: g['type'] == 'group' ? 'Mutual' : (g['category'] ?? 'Personal'),
                        icon: (g['type'] == 'group') ? Icons.groups_2_outlined : Icons.flag,
                        themeColor: (g['type'] == 'group') ? Colors.deepPurple : Colors.purple,
                        progress: _progressFrom(g),
                        secondProgress: null,
                        durationText: _durationTextFrom(g),
                        streakText: _streakTextFrom(g),
                        completed: (g['status'] == 'completed'),
                        goalPicture: g['goal_picture'] as String?, // เพิ่มรูปภาพ
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Removed previous mutual participants demo to focus on specified single-card goal UI

class _GoalCard extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final Color themeColor;
  final double progress; // 0.0 - 1.0
  final double? secondProgress; // friend/other progress for mutual goals
  final String durationText;
  final String streakText;
  final bool completed;
  final String? goalPicture; // เพิ่ม parameter สำหรับรูปภาพ

  const _GoalCard({
    required this.title,
    required this.category,
    required this.icon,
    required this.themeColor,
    required this.progress,
    this.secondProgress,
    required this.durationText,
    required this.streakText,
    required this.completed,
    this.goalPicture, // เพิ่ม parameter
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        final totalDays = _extractFirstInt(durationText) ?? 30;
        final completedApprox = (progress * totalDays).round();
        final streak = _extractFirstInt(streakText) ?? 0;
        final isMutual =
            secondProgress != null || category.toLowerCase().contains('mutual');
        final friendCompletedApprox = ((secondProgress ?? 0) * totalDays).round();
        final args = GoalDetailArgs(
          title: title,
          category: category,
          totalDays: totalDays,
          completed: completedApprox,
          currentStreak: streak,
          isMutual: isMutual,
          friendName: 'Friend',
          friendCompleted: friendCompletedApprox,
        );
        if (context.mounted) {
          context.push(AppConstants.goalDetailRoute, extra: args);
        }
      },
      child: Card(
        elevation: 2.5,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // แสดงรูปภาพถ้ามี ไม่งั้นแสดง icon
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
                          child: Icon(icon, color: themeColor),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Completion indicator
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
                    child: completed
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress section (single or dual bar)
              if (secondProgress == null) ...[
                Row(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(color: Colors.black),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                ),
              ] else ...[
                Row(
                  children: const [
                    Text('Progress', style: TextStyle(color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                // You
                Row(
                  children: [
                    const Text('You', style: TextStyle(color: Colors.black)),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                ),
                const SizedBox(height: 10),
                // Friend/Other
                Row(
                  children: [
                    Text(
                      'Friend',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const Spacer(),
                    Text(
                      '${((secondProgress ?? 0) * 100).round()}%',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: secondProgress ?? 0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Bottom row
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        durationText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        streakText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

int? _extractFirstInt(String text) {
  final match = RegExp(r"(\d+)").firstMatch(text);
  if (match != null) {
    return int.tryParse(match.group(1)!);
  }
  return null;
}

class _CurrentStreakCard extends StatelessWidget {
  final int days;
  final int totalDays;
  final double percent;
  const _CurrentStreakCard({
    required this.days,
    required this.totalDays,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.local_fire_department, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Current Streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Day $days',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: ' /$totalDays',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percent * 100).round()}% Complete',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _GradientActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple, Colors.pinkAccent]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// Helper function to get image provider (รองรับทั้ง base64 และ URL)
ImageProvider _getImageProvider(String imageData) {
  if (imageData.startsWith('data:image')) {
    // Base64 encoded image
    final base64String = imageData.split(',').last;
    return MemoryImage(base64Decode(base64String));
  } else if (imageData.startsWith('http')) {
    // URL image
    return NetworkImage(imageData);
  } else {
    // Fallback to asset
    return const AssetImage('assets/images/placeholder.png');
  }
}

double _progressFrom(Map<String, dynamic> g) {
  final int prog = (g['progress_days'] is int) ? g['progress_days'] as int : int.tryParse('${g['progress_days'] ?? 0}') ?? 0;
  int? dur = g['duration_days'] is int ? g['duration_days'] as int : int.tryParse('${g['duration_days'] ?? ''}');
  dur ??= _extractFirstInt('${g['duration'] ?? ''}');
  if (dur == null || dur == 0) return 0;
  final v = prog / dur;
  if (v < 0) return 0; if (v > 1) return 1; return v;
}

String _durationTextFrom(Map<String, dynamic> g) {
  if (g['duration'] is String && (g['duration'] as String).isNotEmpty) return g['duration'];
  final d = g['duration_days'];
  if (d is int && d > 0) return '$d days goal';
  return 'Goal';
}

String _streakTextFrom(Map<String, dynamic> g) {
  final int prog = (g['progress_days'] is int) ? g['progress_days'] as int : int.tryParse('${g['progress_days'] ?? 0}') ?? 0;
  return '$prog day streak';
}
