import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/costume_repository.dart';
import '../../../services/goal_service.dart';
import '../../../services/friends_service.dart';
import '../../../services/auth_service.dart';

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
  int? _friendId;
  int? _currentUserId;
  List<_ParticipantProgress> _participants = [];

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Set<DateTime> _doneDays = <DateTime>{}; // normalized to Y-M-D
  int? goalId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _dirtyProgress = false; // track if user changed progress so list can refresh
  bool _finishPrompted = false; // avoid repeated popups when reaching 100%

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
        // Do NOT override overall completed here; keep backend progress_days value
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
        final t = (g['type'] ?? '').toString().toLowerCase();
        category = (t == 'group' || t == 'mutual') ? 'Mutual' : (g['category'] ?? category);
        isMutual = (t == 'group' || t == 'mutual') || isMutual;
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
        // capture friend id if present
        final fidDyn = g['friend_id'] ?? g['friendId'];
        if (fidDyn != null) {
          _friendId = (fidDyn is int) ? fidDyn : int.tryParse('$fidDyn');
        }
      });
      // After loading goal meta, attempt to load participants list if mutual
      if (mounted && isMutual) {
        await _loadParticipants();
      }
    } catch (e) {
      // ignore detail load errors
    }
  }

  int? _extractInt(String text) {
    final m = RegExp(r"(\d+)").firstMatch(text);
    if (m != null) return int.tryParse(m.group(1)!);
    return null;
  }

  Future<void> _loadParticipants() async {
    if (goalId == null) return;
    try {
      // current user id from cached profile
      final me = await AuthService().getUserData();
      _currentUserId = int.tryParse(me?.id ?? '');

      // Start with known ids: current + friendId if any
      final ids = <int>{};
      if (_currentUserId != null) ids.add(_currentUserId!);
      if (_friendId != null) ids.add(_friendId!);

      // Collect logs and compute per-user unique-day counts
      final logs = await _goalService.getLogsRaw(goalId!);
      final Map<int, Set<String>> perUserDates = {};
      for (final m in logs) {
        final uid = m['user_id'] as int;
        final date = (m['date'] as String);
        ids.add(uid);
        perUserDates.putIfAbsent(uid, () => <String>{}).add(date);
      }

      // Resolve usernames and build list
      final fs = FriendsService();
      final List<_ParticipantProgress> parts = [];
      for (final uid in ids) {
        try {
          final u = await fs.getUserById(uid);
          final days = (perUserDates[uid]?.length ?? 0);
          final frac = (totalDays == 0) ? 0.0 : (days / totalDays).clamp(0.0, 1.0);
          parts.add(_ParticipantProgress(
            userId: uid,
            name: (uid == _currentUserId) ? 'You' : u.username,
            days: days,
            progress: frac,
          ));
          // also set friendName/progress for legacy single-friend UI if this uid matches friend
          if (_friendId != null && uid == _friendId) {
            setState(() {
              friendName = u.username;
              friendCompleted = days;
            });
          }
        } catch (_) {
          // ignore resolution failures
        }
      }
      if (!mounted) return;
      setState(() {
        // sort: current user first, then others by name
        parts.sort((a, b) {
          if (_currentUserId != null) {
            if (a.userId == _currentUserId && b.userId != _currentUserId) return -1;
            if (b.userId == _currentUserId && a.userId != _currentUserId) return 1;
          }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        _participants = parts;
      });
    } catch (e) {
      // ignore participants load failures to keep page usable
    }
  }

  void _markTodayDone() async {
    if (totalDays == 0) return;
    final idx = todayIndex;
    // Toggle behavior: if already done, remove the log
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
  if (daysDone[idx]) {
      // attempt toggle off
      try {
        if (goalId != null) {
          await _goalService.deleteLog(goalId!, normalized);
        }
        setState(() {
          daysDone[idx] = false;
          _doneDays.removeWhere((d) => d.year == normalized.year && d.month == normalized.month && d.day == normalized.day);
          completed = (completed - 1).clamp(0, totalDays);
          currentStreak = 0; // simplistic reset; could recompute
        });
        _showSnack('Unmarked today');
        _dirtyProgress = true;
      } catch (e) {
        _showSnack('Failed to unmark today');
      }
      return;
    }
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
      _dirtyProgress = true;
      await _maybePromptFinish();
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
    _dirtyProgress = true; // ensure list refreshes on back
    // Try unlocking a random costume and show popup if any.
    _handleUnlockReward();
  }

  Future<void> _handleUnlockReward() async {
    final repo = CostumeRepository();
    final unlocked = await repo.unlockRandom();
    if (!mounted) return;
    if (unlocked == null) {
      return; // nothing to unlock
    }
    final name = _friendlyName(unlocked);
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFD4C7A), Color(0xFF9B5BFF)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_open, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New costume unlocked! ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "You've unlocked: $name",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // Simple preview using asset image
              FutureBuilder(
                future: precacheImage(AssetImage('assets/images/$unlocked'), context).then((_) => true).catchError((_) => false),
                builder: (ctx, snap) {
                  final ok = snap.connectionState == ConnectionState.done && (snap.data == true);
                  return Center(
                    child: ok
                        ? Image.asset(
                            'assets/images/$unlocked',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          )
                        : Container(
                            width: 120,
                            height: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('OK'),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyName(String file) {
    final base = file.split('/').last.split('.').first; // strip path + ext
    final words = base.replaceAll('_', ' ').split(' ');
    return words.map((w) => w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1))).join(' ');
  }

  Future<void> _maybePromptFinish() async {
    if (totalDays <= 0) return;
    if (completed < totalDays) return;
    if (_finishPrompted) return;
    _finishPrompted = true;
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFD4C7A), Color(0xFF9B5BFF)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Great job!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "You've reached 100% for this goal. Do you want to finish it now?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Not now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradientPrimaryButton(
                      label: 'Finish Goal',
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      _finishGoal();
      if (mounted) {
        _showSnack('Goal finished!');
      }
    }
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
    // New visual rules:
    // 1. Base purple stays visible for Today or in-range pill.
    // 2. If Done overlaps with Today or inRange, show a smaller green inner circle overlay (or semi-transparent circle) keeping purple edges.
    // 3. Non-today & out-of-range Done days: solid green circle.
    // 4. Not done default: light gray circle (or purple pill if in range).
    // 5. Selected (when not done) adds a purple border.

    // Helper: text style
    const dayStyleWhite = TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700);
    const dayStyleDark = TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w700);
    final dayNumberText = Text('$dayNumber', style: (isToday || isDone) ? dayStyleWhite : dayStyleDark);

    // Case: Today or inRange base
    if (isToday || inRange) {
      // Build base (circle for today, pill for range)
      final base = Container(
        width: isToday ? 36 : double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: isToday ? Colors.purple.shade600 : Colors.purple.shade100.withOpacity(0.6),
          shape: isToday ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isToday
              ? null
              : BorderRadius.horizontal(
                  left: isRangeStart ? const Radius.circular(18) : Radius.zero,
                  right: isRangeEnd ? const Radius.circular(18) : Radius.zero,
                ),
          border: (!isDone && isSelected)
              ? Border.all(color: Colors.purple, width: 1.5)
              : null,
        ),
      );

      if (isDone) {
        // Overlay small green circle keeping purple background visible
        final overlayCircle = Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.green.shade600.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade600.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text('$dayNumber', style: dayStyleWhite),
        );
        return Stack(
          alignment: Alignment.center,
          children: [base, overlayCircle],
        );
      }
      // Not done in today/range
      return Stack(
        alignment: Alignment.center,
        children: [base, dayNumberText],
      );
    }

    // Case: Done (not today, not in range)
    if (isDone) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text('$dayNumber', style: dayStyleWhite),
      );
    }

    // Case: Selected (not done, not today, not in range)
    if (isSelected) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.purple, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text('$dayNumber', style: TextStyle(color: Colors.purple.shade900, fontSize: 12, fontWeight: FontWeight.w700)),
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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop(_dirtyProgress ? 'updated' : null);
            } else {
              context.go(AppConstants.goalRoute);
            }
          },
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Intercept system back to propagate result to previous route
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(_dirtyProgress ? 'updated' : null);
            return false;
          }
          return true;
        },
        child: SafeArea(
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
                      if (isMutual && _participants.any((p) => p.userId != _currentUserId)) ...[
                        const SizedBox(height: 12),
                        // Render each participant (excluding current user)
                        for (final p in _participants.where((pp) => pp.userId != _currentUserId)) ...[
                          Row(
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(color: Colors.black),
                              ),
                              const Spacer(),
                              Text(
                                '${(p.progress * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: p.progress),
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
                          const SizedBox(height: 8),
                        ],
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
                          try {
                            if (!already) {
                              if (goalId != null) {
                                await _goalService.logDay(goalId!, d, description: 'Marked via calendar');
                              }
                              setState(() {
                                _doneDays.add(d);
                                completed += 1;
                              });
                              _showSnack('Marked ${d.year}-${d.month}-${d.day}');
                              _dirtyProgress = true;
                              await _maybePromptFinish();
                            } else {
                              if (goalId != null) {
                                await _goalService.deleteLog(goalId!, d);
                              }
                              setState(() {
                                _doneDays.removeWhere((x) => _isSameDay(x, d));
                                completed = (completed - 1).clamp(0, totalDays);
                              });
                              _showSnack('Unmarked ${d.year}-${d.month}-${d.day}');
                              _dirtyProgress = true;
                            }
                          } catch (e) {
                            _showSnack('Failed to toggle day');
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
                  if (completed >= totalDays) ...[
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

class _ParticipantProgress {
  final int userId;
  final String name;
  final int days;
  final double progress;
  _ParticipantProgress({
    required this.userId,
    required this.name,
    required this.days,
    required this.progress,
  });
}
