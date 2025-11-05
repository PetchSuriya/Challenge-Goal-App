import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/goal_form_state.dart';
import '../../../services/goal_service.dart';

/// Goal Form Controller - จัดการ Business Logic ของ Goal Form
class GoalFormController extends ChangeNotifier {
  GoalFormState _state = GoalFormState.initial();
  
  GoalFormState get state => _state;

  // Text controllers
  final titleController = TextEditingController();
  final durationController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    super.dispose();
  }

  /// Update state and notify listeners
  void _updateState(GoalFormState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image != null) {
      _updateState(_state.copyWith(selectedImage: File(image.path)));
    }
  }

  /// Select category
  void selectCategory(String? category) {
    if (_state.selectedCategory == category) {
      // Toggle off
      _updateState(_state.clearCategory());
    } else {
      // Select new
      _updateState(_state.copyWith(selectedCategory: category));
    }
  }

  /// Select goal type
  void selectGoalType(String? type) {
    if (_state.selectedGoalType == type) {
      // Toggle off
      _updateState(_state.clearGoalType());
    } else {
      // Select new
      _updateState(_state.copyWith(
        selectedGoalType: type,
        selectedFriends: [], // Clear friends when changing type
      ));
    }
  }

  /// Update date range
  void updateDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return;

    final days = dateRange.end.difference(dateRange.start).inDays + 1;
    final hasError = days < 7;

    _updateState(_state.copyWith(
      selectedDateRange: dateRange,
      durationDays: days,
      showDateRangeError: hasError,
    ));

    durationController.text = days.toString();
  }

  /// Update selected friends
  void updateSelectedFriends(List<String> friends) {
    _updateState(_state.copyWith(selectedFriends: friends));
  }

  /// Remove a friend
  void removeFriend(String friend) {
    final updatedFriends = List<String>.from(_state.selectedFriends)
      ..remove(friend);
    _updateState(_state.copyWith(selectedFriends: updatedFriends));
  }

  /// Validate form
  String? validateForm(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) {
      return 'Please fill in all required fields';
    }
    return _state.validationError;
  }

  /// Submit form
  Future<Map<String, dynamic>> submitGoal() async {
    final svc = GoalService();
    
    // Convert image to base64 if selected
    String? goalPictureBase64;
    if (_state.hasImage) {
      try {
        final bytes = await _state.selectedImage!.readAsBytes();
        goalPictureBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
      } catch (e) {
        print('Error encoding image: $e');
      }
    }

    // Prepare data
    final type = _state.selectedGoalType == 'Mutual' ? 'group' : 'single';
    final durationText = '${_state.durationDays} days';

    // Call API
    return await svc.createGoal(
      title: titleController.text,
      durationDays: _state.durationDays,
      durationText: durationText,
      category: _state.selectedCategory,
      type: type,
      startDate: _state.selectedDateRange?.start,
      goalPicture: goalPictureBase64,
    );
  }

  /// Reset form
  void reset() {
    titleController.clear();
    durationController.clear();
    _updateState(GoalFormState.initial());
  }
}
