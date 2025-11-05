import 'dart:io';
import 'package:flutter/material.dart';

/// Goal Form State - เก็บ state ทั้งหมดของ Goal Form
class GoalFormState {
  final File? selectedImage;
  final String? selectedCategory;
  final String? selectedGoalType;
  final DateTimeRange? selectedDateRange;
  final List<String> selectedFriends;
  final bool showDateRangeError;
  final int durationDays;

  const GoalFormState({
    this.selectedImage,
    this.selectedCategory,
    this.selectedGoalType,
    this.selectedDateRange,
    this.selectedFriends = const [],
    this.showDateRangeError = false,
    this.durationDays = 0,
  });

  /// Create initial state
  factory GoalFormState.initial() {
    return const GoalFormState();
  }

  /// Copy with new values
  GoalFormState copyWith({
    File? selectedImage,
    String? selectedCategory,
    String? selectedGoalType,
    DateTimeRange? selectedDateRange,
    List<String>? selectedFriends,
    bool? showDateRangeError,
    int? durationDays,
  }) {
    return GoalFormState(
      selectedImage: selectedImage ?? this.selectedImage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedGoalType: selectedGoalType ?? this.selectedGoalType,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      selectedFriends: selectedFriends ?? this.selectedFriends,
      showDateRangeError: showDateRangeError ?? this.showDateRangeError,
      durationDays: durationDays ?? this.durationDays,
    );
  }

  /// Clear specific field
  GoalFormState clearCategory() {
    return copyWith(selectedCategory: null);
  }

  GoalFormState clearGoalType() {
    return copyWith(
      selectedGoalType: null,
      selectedFriends: [],
    );
  }

  /// Validation
  bool get isValid {
    return selectedCategory != null &&
        selectedGoalType != null &&
        durationDays > 0 &&
        !showDateRangeError;
  }

  bool get isMutualGoal => selectedGoalType == 'Mutual';

  bool get hasImage => selectedImage != null;

  String? get validationError {
    if (selectedCategory == null) return 'Please select a category';
    if (selectedGoalType == null) return 'Please select a goal type';
    if (durationDays == 0) return 'Please select date range';
    if (showDateRangeError) return 'Please select at least 7 days';
    return null;
  }
}

/// Goal Category Model
class GoalCategory {
  final String name;
  final IconData icon;

  const GoalCategory({
    required this.name,
    required this.icon,
  });

  static const List<GoalCategory> categories = [
    GoalCategory(name: 'Fitness', icon: Icons.fitness_center),
    GoalCategory(name: 'Learning', icon: Icons.school),
    GoalCategory(name: 'Health', icon: Icons.favorite),
    GoalCategory(name: 'Work', icon: Icons.work),
  ];
}
