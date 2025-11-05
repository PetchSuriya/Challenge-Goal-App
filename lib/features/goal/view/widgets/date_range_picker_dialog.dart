import 'package:flutter/material.dart';

/// Date Range Picker Dialog - แยกออกจาก goal_form_page.dart
/// แสดง date range picker พร้อมตรวจสอบ minimum 7 days
class CustomDateRangePicker {
  /// แสดง date range picker และ return DateTimeRange ที่เลือก
  static Future<DateTimeRange?> show({
    required BuildContext context,
    DateTimeRange? initialDateRange,
  }) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
      helpText: 'SELECT DATE RANGE (Minimum 7 days)',
      saveText: 'SAVE',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFDA70D6),
              onPrimary: Colors.white,
              secondary: Color(0xFFDA70D6),
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
              background: Colors.white,
              onBackground: Colors.black87,
              primaryContainer: Color(0xFFFFC0E5),
              onPrimaryContainer: Color(0xFFD6006B),
              surfaceVariant: Colors.white,
              onSurfaceVariant: Colors.black87,
            ),
            scaffoldBackgroundColor: Colors.white,
            canvasColor: Colors.white,
            cardColor: Colors.white,
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black87),
              labelLarge: TextStyle(color: Colors.black87),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7B68EE),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            dialogBackgroundColor: Colors.white,
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
            ),
          ),
          child: child!,
        );
      },
    );

    return picked;
  }

  /// ตรวจสอบว่า date range มีอย่างน้อย 7 วันหรือไม่
  static bool isValidDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return false;
    final days = dateRange.end.difference(dateRange.start).inDays + 1;
    return days >= 7;
  }

  /// คำนวณจำนวนวันจาก DateTimeRange
  static int calculateDays(DateTimeRange? dateRange) {
    if (dateRange == null) return 0;
    return dateRange.end.difference(dateRange.start).inDays + 1;
  }
}
