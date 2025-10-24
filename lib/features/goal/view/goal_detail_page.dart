import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class GoalDetailArgs {
  final String title;
  final String category;
  final int totalDays;
  final int completed;
  final int currentStreak;
  final bool isMutual;
  final String friendName;
  final int friendCompleted;

  const GoalDetailArgs({
    required this.title,
    required this.category,
    required this.totalDays,
    required this.completed,
    required this.currentStreak,
    this.isMutual = false,
    this.friendName = 'Friend',
    this.friendCompleted = 0,
  });
}

class GoalDetailPage extends StatefulWidget {
  final GoalDetailArgs? args;
  const GoalDetailPage({super.key, this.args});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  late String title;
  late String category;
  late int totalDays;
  late int completed;
  late int currentStreak;
  late List<bool> daysDone; // length = totalDays
  late bool isMutual;
  late String friendName;
  late int friendCompleted;

  double get progress => totalDays == 0 ? 0 : completed / totalDays;
  int get remaining => (totalDays - completed).clamp(0, totalDays);
  double get friendProgress => totalDays == 0 ? 0 : friendCompleted / totalDays;

  int get todayIndex {
    final day = DateTime.now().day - 1;
    return day.clamp(0, totalDays > 0 ? totalDays - 1 : 0);
  }

  @override
  void initState() {
    super.initState();
    final a = widget.args;
    title = a?.title ?? 'Daily Workout';
    category = a?.category ?? 'Fitness';
    totalDays = a?.totalDays ?? 30;
    completed = a?.completed ?? 22; // sample matches requirements
    currentStreak = a?.currentStreak ?? 12;
    isMutual = a?.isMutual ?? false;
    friendName = a?.friendName ?? 'Friend';
    friendCompleted = a?.friendCompleted ?? 18;
    daysDone = List<bool>.filled(totalDays, false);
    for (int i = 0; i < completed && i < totalDays; i++) {
      daysDone[i] = true;
    }
  }

  void _markTodayDone() {
    if (totalDays == 0) return;
    final idx = todayIndex;
    if (daysDone[idx]) {
      _showSnack('Today already completed');
      return;
    }
    setState(() {
      daysDone[idx] = true;
      completed = (completed + 1).clamp(0, totalDays);
      // update streak: if previous day done, +1 else reset to 1
      if (idx > 0 && daysDone[idx - 1]) {
        currentStreak += 1;
      } else {
        currentStreak = 1;
      }
    });
  }

  void _finishGoal() {
    setState(() {
      for (int i = 0; i < totalDays; i++) {
        daysDone[i] = true;
      }
      completed = totalDays;
      // set a long streak to reflect completion (optional)
      currentStreak = totalDays;
    });
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE), // light red without withOpacity
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Goal',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'This action cannot be undone. Are you sure you want to permanently delete this goal?',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple,
              side: const BorderSide(color: Colors.purple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // For demo, just pop back
      context.go(AppConstants.goalRoute);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Goal Details',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.goalRoute),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                elevation: 2.5,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Overall Progress Card
              Card(
                elevation: 2.5,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Overall Progress',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Your progress bar
                      Row(
                        children: [
                          const Text('You', style: TextStyle(color: Colors.black)),
                          const Spacer(),
                          Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, value, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        ),
                      ),
                      if (isMutual) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(friendName, style: const TextStyle(color: Colors.black)),
                            const Spacer(),
                            Text('${(friendProgress * 100).round()}%', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: friendProgress),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatChip(label: 'Completed', value: completed.toString()),
                          _StatChip(label: 'Current Streak', value: currentStreak.toString()),
                          _StatChip(label: 'Remaining', value: remaining.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Motivational message
              Card(
                elevation: 2.5,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.amber),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Keep going! You’re on Day 12! Outstanding progress!",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Streak Calendar
              const Text('Streak Calendar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              const SizedBox(height: 8),
              Card(
                elevation: 2.5,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalDays,
                        itemBuilder: (context, index) {
                          final isDone = daysDone[index];
                          final isToday = index == todayIndex;
                          late Color bg;
                          late Color fg;
                          if (isDone) {
                            bg = Colors.green.shade600;
                            fg = Colors.white;
                          } else if (isToday) {
                            bg = Colors.purple.shade600;
                            fg = Colors.white;
                          } else {
                            bg = Colors.grey.shade300;
                            fg = Colors.black;
                          }
                          return CircleAvatar(
                            backgroundColor: bg,
                            foregroundColor: fg,
                            child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendDot(color: Colors.green.shade600, label: 'Done'),
                          const SizedBox(width: 16),
                          _LegendDot(color: Colors.purple.shade600, label: 'Today'),
                          const SizedBox(width: 16),
                          _LegendDot(color: Colors.grey, label: 'Not done'),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom actions
              Row(
                children: [
                  Expanded(
                    child: _GradientPrimaryButton(
                      label: 'Mark as Done',
                      onPressed: _markTodayDone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _finishGoal,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Finish Goal'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _deleteGoal,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Goal'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.black)),
      ],
    );
  }
}

class _GradientPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientPrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.purple, Colors.pinkAccent]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
