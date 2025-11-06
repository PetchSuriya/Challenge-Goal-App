import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/goal_service.dart';

class GoalDetailArgs {
  final int? goalId; // backend goal id for fetching logs
  final String title;
  final String category;
  final int totalDays;
  final int completed;
  final int currentStreak;
  final bool isMutual;
  final String friendName;
  final int friendCompleted;

  const GoalDetailArgs({
    this.goalId,
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
  final _goalService = GoalService();
  late String title;
  late String category;
  late int totalDays;
  late int completed;
  late int currentStreak;
  late List<bool> daysDone; // length = totalDays
  late bool isMutual;
  late String friendName;
  late int friendCompleted;

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Set<DateTime> _doneDays = <DateTime>{}; // normalized to Y-M-D
  int? goalId;
  DateTime? _startDate;
  DateTime? _endDate;

  double get progress => totalDays == 0 ? 0 : completed / totalDays;
  int get remaining => (totalDays - completed).clamp(0, totalDays);
  double get friendProgress => totalDays == 0 ? 0 : friendCompleted / totalDays;

  int get todayIndex {
    final day = DateTime.now().day - 1;
    return day.clamp(0, totalDays > 0 ? totalDays - 1 : 0);
  }

  DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return _normalize(v);
    if (v is int) {
      try {
        // treat as millisecondsSinceEpoch if looks like epoch ms
        final dt = DateTime.fromMillisecondsSinceEpoch(v, isUtc: false);
        return _normalize(dt);
      } catch (_) {}
    }
    final s = v.toString();
    // handle numeric string epoch
    if (RegExp(r'^\d{10,13}$').hasMatch(s)) {
      try {
        final ms = s.length == 13 ? int.parse(s) : int.parse(s) * 1000;
        return _normalize(DateTime.fromMillisecondsSinceEpoch(ms));
      } catch (_) {}
    }
    // handle numeric string epoch (seconds or milliseconds)
    if (RegExp(r'^\d+$').hasMatch(s)) {
      try {
        final isMs = s.length >= 13;
        final ms = isMs ? int.parse(s) : int.parse(s) * 1000;
        return _normalize(DateTime.fromMillisecondsSinceEpoch(ms));
      } catch (_) {}
    }
    final dt = DateTime.tryParse(s);
    return dt != null ? _normalize(dt) : null;
  }

  bool _isInRange(DateTime d) {
    if (_startDate == null || _endDate == null) return false;
    final sd = _normalize(_startDate!);
    final ed = _normalize(_endDate!);
    if (ed.isBefore(sd)) return false;
    return (d.isAtSameMomentAs(sd) || d.isAfter(sd)) && (d.isAtSameMomentAs(ed) || d.isBefore(ed));
  }

  bool _isRangeStart(DateTime d) {
    if (_startDate == null) return false;
    return _isSameDay(_normalize(d), _normalize(_startDate!));
  }

  bool _isRangeEnd(DateTime d) {
    if (_endDate == null) return false;
    return _isSameDay(_normalize(d), _normalize(_endDate!));
  }

  @override
  void initState() {
    super.initState();
    final a = widget.args;
    goalId = a?.goalId;
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

    // Load logs from backend if goalId present
    if (goalId != null) {
      _loadGoalDetail(goalId!);
      _loadLogs(goalId!);
    } else {
      // fallback: mark first `completed` days of current month
      final now = DateTime.now();
      for (int i = 0; i < completed; i++) {
        final d = DateTime(now.year, now.month, (i + 1));
        _doneDays.add(DateTime(d.year, d.month, d.day));
      }
    }
  }

  Future<void> _loadLogs(int id) async {
    try {
      final logs = await _goalService.getLogs(id);
      setState(() {
        _doneDays
          ..clear()
          ..addAll(logs.map((d) => DateTime(d.year, d.month, d.day)));
        // Update summary counters based on count in current selection month
        final now = DateTime.now();
        completed = _doneDays.where((d) => d.year == now.year && d.month == now.month).length;
      });
    } catch (e) {
      // keep UI usable even if logs fail
    }
  }

  Future<void> _loadGoalDetail(int id) async {
    try {
      final g = await _goalService.getGoal(id);
      setState(() {
        title = (g['title'] ?? title) as String;
        category = (g['type'] == 'group') ? 'Mutual' : (g['category'] ?? category);
        // Parse start/end date from backend (accept snake_case or camelCase)
        final sdRaw = g['start_date'] ?? g['startDate'];
        final edRaw = g['end_date'] ?? g['endDate'];
        final parsedStart = _tryParseDate(sdRaw);
        final parsedEnd = _tryParseDate(edRaw);
        _startDate = parsedStart;
        final int? dur = g['duration_days'] is int
            ? g['duration_days'] as int
            : int.tryParse('${g['duration_days'] ?? ''}') ?? _extractInt('${g['duration'] ?? ''}');
        if (dur != null && dur > 0) {
          totalDays = dur;
          daysDone = List<bool>.filled(totalDays, false);
        }
        // If endDate missing, compute from startDate + duration
        if (_startDate != null) {
          _endDate = parsedEnd ?? _startDate!.add(Duration(days: (totalDays > 0 ? totalDays - 1 : 0)));
        } else {
          _endDate = parsedEnd;
        }
        final int prog = g['progress_days'] is int ? g['progress_days'] as int : int.tryParse('${g['progress_days'] ?? 0}') ?? 0;
        completed = prog.clamp(0, totalDays);
        currentStreak = prog; // simple approximation
      });
    } catch (e) {
      // ignore detail load errors
    }
  }

  int? _extractInt(String text) {
    final m = RegExp(r"(\d+)").firstMatch(text);
    if (m != null) return int.tryParse(m.group(1)!);
    return null;
  }

  void _markTodayDone() async {
    if (totalDays == 0) return;
    final idx = todayIndex;
    if (daysDone[idx]) {
      _showSnack('Today already completed');
      return;
    }
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    // Call backend if goalId available
    try {
      if (goalId != null) {
        await _goalService.logDay(goalId!, normalized, description: 'Marked done');
      }
      setState(() {
        daysDone[idx] = true;
        _doneDays.add(normalized);
        completed = (completed + 1).clamp(0, totalDays);
        // update streak: if previous day done, +1 else reset to 1
        if (idx > 0 && daysDone[idx - 1]) {
          currentStreak += 1;
        } else {
          currentStreak = 1;
        }
      });
      _showSnack('Marked today as done');
    } catch (e) {
      _showSnack('Failed to mark today');
    }
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
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        if (goalId != null) {
          await _goalService.deleteGoal(goalId!);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Prefer popping with a result so the list can refresh; fallback to go if not possible
        if (Navigator.of(context).canPop()) {
          context.pop('deleted');
        } else {
          context.go(AppConstants.goalRoute);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: ${e is Exception ? e.toString().replaceFirst("Exception: ", "") : e}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Helpers for calendar rendering
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDayCell(
    int dayNumber, {
    bool isDone = false,
    bool isToday = false,
    bool isSelected = false,
    bool inRange = false,
    bool isRangeStart = false,
    bool isRangeEnd = false,
  }) {
    // Priority: Done > Today > Selected > InRange > Default
    if (isDone || isToday || isSelected) {
      Color bg;
      Color fg;
      BoxBorder? border;
      if (isDone) {
        bg = Colors.green.shade600;
        fg = Colors.white;
      } else if (isToday) {
        bg = Colors.purple.shade600;
        fg = Colors.white;
      } else {
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        border = Border.all(color: Colors.purple, width: 1.5);
      }
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNumber',
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (inRange) {
      // Light purple background for in-range days, with rounded edges on boundaries
      final radius = BorderRadius.horizontal(
        left: isRangeStart ? const Radius.circular(18) : Radius.zero,
        right: isRangeEnd ? const Radius.circular(18) : Radius.zero,
      );
      return Container(
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.purple.shade100.withOpacity(0.6),
          borderRadius: radius,
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNumber',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    // Default style for out-of-range not-done days
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$dayNumber',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Overall Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Your progress bar
                      Row(
                        children: [
                          const Text(
                            'You',
                            style: TextStyle(color: Colors.black),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.purple,
                            ),
                          ),
                        ),
                      ),
                      if (isMutual) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              friendName,
                              style: const TextStyle(color: Colors.black),
                            ),
                            const Spacer(),
                            Text(
                              '${(friendProgress * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatChip(
                            label: 'Completed',
                            value: completed.toString(),
                          ),
                          _StatChip(
                            label: 'Current Streak',
                            value: currentStreak.toString(),
                          ),
                          _StatChip(
                            label: 'Remaining',
                            value: remaining.toString(),
                          ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Calendar
              const Text(
                'Calendar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2.5,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2100, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
                        onDaySelected: (selectedDay, focusedDay) async {
                          setState(() {
                            _selectedDay = _normalize(selectedDay);
                            _focusedDay = focusedDay;
                          });
                          // Mark done if not already
                          final d = _normalize(selectedDay);
                          final already = _doneDays.contains(d);
                          if (!already) {
                            try {
                              if (goalId != null) {
                                await _goalService.logDay(goalId!, d, description: 'Marked via calendar');
                              }
                              setState(() {
                                _doneDays.add(d);
                                completed += 1;
                              });
                              _showSnack('Marked ${d.year}-${d.month}-${d.day}');
                            } catch (e) {
                              _showSnack('Failed to mark day');
                            }
                          }
                        },
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final d = _normalize(day);
                            final isDone = _doneDays.contains(d);
                            final inRange = _isInRange(d);
                            final isStart = _isRangeStart(d);
                            final isEnd = _isRangeEnd(d);
                            return _buildDayCell(
                              day.day,
                              isDone: isDone,
                              isToday: _isSameDay(d, _normalize(DateTime.now())),
                              inRange: inRange,
                              isRangeStart: isStart,
                              isRangeEnd: isEnd,
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            final d = _normalize(day);
                            final isDone = _doneDays.contains(d);
                            final inRange = _isInRange(d);
                            final isStart = _isRangeStart(d);
                            final isEnd = _isRangeEnd(d);
                            return _buildDayCell(
                              day.day,
                              isDone: isDone,
                              isToday: true,
                              inRange: inRange,
                              isRangeStart: isStart,
                              isRangeEnd: isEnd,
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            final d = _normalize(day);
                            final isDone = _doneDays.contains(d);
                            final inRange = _isInRange(d);
                            final isStart = _isRangeStart(d);
                            final isEnd = _isRangeEnd(d);
                            return _buildDayCell(
                              day.day,
                              isDone: isDone,
                              isSelected: true,
                              inRange: inRange,
                              isRangeStart: isStart,
                              isRangeEnd: isEnd,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendDot(
                            color: Colors.green.shade600,
                            label: 'Done',
                          ),
                          const SizedBox(width: 16),
                          _LegendDot(
                            color: Colors.purple.shade600,
                            label: 'Today',
                          ),
                          const SizedBox(width: 16),
                          _LegendDot(color: Colors.grey, label: 'Not done'),
                        ],
                      ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.pinkAccent],
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
