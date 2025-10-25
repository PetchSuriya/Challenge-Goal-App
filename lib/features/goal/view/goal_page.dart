import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import 'goal_detail_page.dart';
import 'goal_form_page.dart';

/// GoalPage - Redesigned to match login style with custom header, streak card, and goal list
class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  bool _showMutual = false;

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
                onPressed: () => context.go(AppConstants.dashboardRoute),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(_showMutual ? Icons.person_outline : Icons.people_alt_outlined),
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
                  MaterialPageRoute(
                    builder: (context) => const GoalFormPage(),
                  ),
                );
                
                if (result != null) {
                  // TODO: เพิ่ม goal ใหม่ลงในรายการ
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goal added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
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
            const _CurrentStreakCard(
              days: 12,
              totalDays: 100,
              percent: 0.12,
            ),

            const SizedBox(height: 16),

            // Header: Your Goals
            Row(
              children: [
                Text(
                  _showMutual ? 'Mutual Goals' : 'Your Goals',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                ),
                const Spacer(),
                Text(
                  _showMutual ? '3 active' : '5 active',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (!_showMutual) ...[
              _GoalCard(
                title: 'Daily Workout',
                category: 'Health',
                icon: Icons.fitness_center,
                themeColor: Colors.pinkAccent,
                progress: 0.75,
                durationText: '30 days goal',
                streakText: '12 day streak',
                completed: false,
              ),
              const SizedBox(height: 12),
              _GoalCard(
                title: 'Read 30 Minutes',
                category: 'Learning',
                icon: Icons.book_outlined,
                themeColor: Colors.blueAccent,
                progress: 0.4,
                durationText: '30 days goal',
                streakText: '5 day streak',
                completed: false,
              ),
              const SizedBox(height: 12),
              _GoalCard(
                title: 'Meditation',
                category: 'Mindfulness',
                icon: Icons.favorite_outline,
                themeColor: Colors.green,
                progress: 0.9,
                durationText: '30 days goal',
                streakText: '20 day streak',
                completed: false,
              ),
            ] else ...[
              _GoalCard(
                title: 'Workout Buddies Challenge',
                category: 'Mutual • Health',
                icon: Icons.groups_2_outlined,
                themeColor: Colors.deepPurple,
                progress: 0.6,
                secondProgress: 0.55,
                secondLabel: 'Friend',
                durationText: '30 days goal',
                streakText: '8 day streak',
                completed: false,
              ),
              const SizedBox(height: 12),
              _GoalCard(
                title: 'Read Together',
                category: 'Mutual • Learning',
                icon: Icons.groups,
                themeColor: Colors.teal,
                progress: 0.35,
                secondProgress: 0.4,
                secondLabel: 'Friend',
                durationText: '21 days goal',
                streakText: '3 day streak',
                completed: false,
              ),
              const SizedBox(height: 12),
              _GoalCard(
                title: 'Morning Meditation Group',
                category: 'Mutual • Mindfulness',
                icon: Icons.group_work_outlined,
                themeColor: Colors.orange,
                progress: 0.8,
                secondProgress: 0.72,
                secondLabel: 'Friend',
                durationText: '14 days goal',
                streakText: '10 day streak',
                completed: false,
              ),
            ],
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
  final String secondLabel;
  final String durationText;
  final String streakText;
  final bool completed;

  const _GoalCard({
    required this.title,
    required this.category,
    required this.icon,
    required this.themeColor,
    required this.progress,
    this.secondProgress,
    this.secondLabel = 'Friend',
    required this.durationText,
    required this.streakText,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        final totalDays = _extractFirstInt(durationText) ?? 30;
        final completedApprox = (progress * totalDays).round();
        final streak = _extractFirstInt(streakText) ?? 0;
        final isMutual = secondProgress != null || category.toLowerCase().contains('mutual');
        final friendCompletedApprox = ((secondProgress ?? 0) * totalDays).round();
        final args = GoalDetailArgs(
          title: title,
          category: category,
          totalDays: totalDays,
          completed: completedApprox,
          currentStreak: streak,
          isMutual: isMutual,
          friendName: secondLabel,
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
                Container(
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
                        style: const TextStyle(fontSize: 12, color: Colors.black),
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
                    border: Border.all(color: completed ? themeColor : Colors.grey.shade400, width: 2),
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
                  Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.black)),
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
                  Text(secondLabel, style: const TextStyle(color: Colors.black)),
                  const Spacer(),
                  Text('${((secondProgress ?? 0) * 100).round()}%', style: const TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: secondProgress ?? 0,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
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
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      streakText,
                      style: const TextStyle(color: Colors.black, fontSize: 12),
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
  const _CurrentStreakCard({required this.days, required this.totalDays, required this.percent});

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
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Day $days',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black87),
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
  const _GradientActionButton({required this.icon, required this.label, required this.onPressed});

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
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
