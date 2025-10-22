import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// GoalFormPage - หน้าฟอร์มสำหรับสร้างเป้าหมายใหม่
class GoalFormPage extends StatefulWidget {
  const GoalFormPage({super.key});

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  
  File? _selectedImage;
  String? _selectedCategory; // เปลี่ยนเป็น nullable
  String? _selectedGoalType; // เปลี่ยนเป็น nullable
  DateTimeRange? _selectedDateRange;
  List<String> _selectedFriends = [];
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Fitness', 'icon': Icons.fitness_center},
    {'name': 'Learning', 'icon': Icons.school},
    {'name': 'Health', 'icon': Icons.favorite},
    {'name': 'Work', 'icon': Icons.work},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7B68EE), // สีม่วงหลัก - วันที่เลือก
              onPrimary: Colors.white, // ตัวหนังสือบนวันที่เลือก
              secondary: Color(0xFFDA70D6), // สีชมพู
              onSecondary: Colors.white,
              surface: Colors.white, // พื้นหลังปฏิทิน
              onSurface: Colors.black87, // ตัวหนังสือทั่วไป
              background: Colors.white, // พื้นหลังโดยรวม
              onBackground: Colors.black87,
              primaryContainer: Color(0xFFE6D9FF), // พื้นหลังช่วงวันที่ที่เลือก (สีม่วงอ่อน)
              onPrimaryContainer: Color(0xFF4B0082), // ตัวหนังสือในช่วงที่เลือก
              surfaceVariant: Colors.white, // พื้นหลังส่วนอื่นๆ
              onSurfaceVariant: Colors.black87,
            ),
            scaffoldBackgroundColor: Colors.white, // พื้นหลัง scaffold
            canvasColor: Colors.white, // พื้นหลัง canvas
            cardColor: Colors.white, // พื้นหลัง card
            textTheme: const TextTheme(
              headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black87),
              labelLarge: TextStyle(color: Colors.black87),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7B68EE), // สีปุ่ม Cancel/SAVE
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
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        // คำนวณจำนวนวัน
        final days = picked.end.difference(picked.start).inDays + 1;
        _durationController.text = days.toString();
      });
    }
  }

  void _showAddFriendDialog() {
    // Mock list of available friends
    final List<Map<String, dynamic>> availableFriends = [
      {'name': 'John doe', 'avatar': '👤'},
      {'name': 'Jane doe', 'avatar': '👤'},
      {'name': 'Alex Smith', 'avatar': '👤'},
      {'name': 'Sarah Johnson', 'avatar': '👤'},
      {'name': 'Mike Brown', 'avatar': '👤'},
      {'name': 'Emma Wilson', 'avatar': '👤'},
      {'name': 'Chris Lee', 'avatar': '👤'},
      {'name': 'Lisa Anderson', 'avatar': '👤'},
    ];
    
    final TextEditingController searchController = TextEditingController();
    List<String> tempSelectedFriends = List.from(_selectedFriends);
    List<Map<String, dynamic>> filteredFriends = List.from(availableFriends);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void filterFriends(String query) {
            setDialogState(() {
              if (query.isEmpty) {
                filteredFriends = List.from(availableFriends);
              } else {
                filteredFriends = availableFriends
                    .where((friend) => friend['name']
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                    .toList();
              }
            });
          }
          
          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 600),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Add friend',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Field
                  TextField(
                    controller: searchController,
                    onChanged: filterFriends,
                    decoration: InputDecoration(
                      hintText: 'Enter friend name or e.g. john doe, jane doe',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF7B68EE), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Friends List
                  Flexible(
                    child: filteredFriends.isEmpty
                        ? Center(
                            child: Text(
                              'No friends found',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredFriends.length,
                            itemBuilder: (context, index) {
                              // แสดงเป็น 2 คอลัมน์
                              if (index % 2 == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      // คอลัมน์ซ้าย
                                      Expanded(
                                        child: _FriendCheckboxItem(
                                          name: filteredFriends[index]['name'],
                                          avatar: filteredFriends[index]['avatar'],
                                          isSelected: tempSelectedFriends.contains(
                                            filteredFriends[index]['name'],
                                          ),
                                          onChanged: (selected) {
                                            setDialogState(() {
                                              if (selected) {
                                                tempSelectedFriends.add(
                                                  filteredFriends[index]['name'],
                                                );
                                              } else {
                                                tempSelectedFriends.remove(
                                                  filteredFriends[index]['name'],
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // คอลัมน์ขวา
                                      if (index + 1 < filteredFriends.length)
                                        Expanded(
                                          child: _FriendCheckboxItem(
                                            name: filteredFriends[index + 1]['name'],
                                            avatar: filteredFriends[index + 1]['avatar'],
                                            isSelected: tempSelectedFriends.contains(
                                              filteredFriends[index + 1]['name'],
                                            ),
                                            onChanged: (selected) {
                                              setDialogState(() {
                                                if (selected) {
                                                  tempSelectedFriends.add(
                                                    filteredFriends[index + 1]['name'],
                                                  );
                                                } else {
                                                  tempSelectedFriends.remove(
                                                    filteredFriends[index + 1]['name'],
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                        )
                                      else
                                        const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7B68EE), Color(0xFFDA70D6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFriends = tempSelectedFriends;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // ตรวจสอบว่าเลือก Category และ Goal Type แล้วหรือยัง
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_selectedGoalType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a goal type'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_durationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select date range'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // TODO: ส่งข้อมูลไปบันทึก
      Navigator.pop(context, {
        'title': _titleController.text,
        'duration': int.parse(_durationController.text),
        'category': _selectedCategory,
        'goalType': _selectedGoalType,
        'dateRange': _selectedDateRange,
        'friends': _selectedFriends,
        'image': _selectedImage,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B68EE), Color(0xFFDA70D6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Goal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create your next achievement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image, Goal Title, and Duration in same row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Picker (Left side) - Match height with Goal Title + Duration
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              constraints: const BoxConstraints(
                                minHeight: 180, // เพิ่มความสูงให้ยืดตามเนื้อหา
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          color: Colors.grey.shade400,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 4),
                                        Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Goal Title and Duration (Right side)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Goal Title
                                const Text(
                                  'Goal Title',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _titleController,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Read 30 minutes daily',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter goal title';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Duration (Below Goal Title, same column)
                                const Text(
                                  'Duration (days)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _durationController,
                                        keyboardType: TextInputType.number,
                                        readOnly: true,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Select date range',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                          suffixText: _durationController.text.isNotEmpty ? 'days' : null,
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Colors.purple, width: 2),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter duration';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Please enter a valid number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 1,
                                      child: ElevatedButton.icon(
                                        onPressed: _selectDateRange,
                                        icon: const Icon(Icons.date_range, size: 16),
                                        label: Text(
                                          _selectedDateRange == null
                                              ? 'Select'
                                              : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple.shade50,
                                          foregroundColor: Colors.purple,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Category Section
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category['name'];
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle: ถ้าเลือกอยู่แล้วให้ยกเลิก, ถ้ายังไม่เลือกให้เลือก
                                if (_selectedCategory == category['name']) {
                                  _selectedCategory = null; // ยกเลิกการเลือก
                                } else {
                                  _selectedCategory = category['name']; // เลือกใหม่
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.purple.shade50
                                    : Colors.grey.shade50,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.purple.shade100
                                          : Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      category['icon'],
                                      color: isSelected
                                          ? Colors.purple
                                          : Colors.grey.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.purple
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Goal Type Section
                      const Text(
                        'Goal Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _GoalTypeCard(
                              icon: Icons.person_outline,
                              title: 'Personal',
                              subtitle: 'Just for you',
                              isSelected: _selectedGoalType == 'Personal',
                              onTap: () {
                                setState(() {
                                  // Toggle: ถ้าเลือก Personal อยู่แล้วให้ยกเลิก
                                  if (_selectedGoalType == 'Personal') {
                                    _selectedGoalType = null; // ยกเลิกการเลือก
                                  } else {
                                    _selectedGoalType = 'Personal'; // เลือก Personal
                                    _selectedFriends.clear(); // ล้างรายชื่อเพื่อน
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GoalTypeCard(
                              icon: Icons.people_outline,
                              title: 'Mutual',
                              subtitle: 'With a friend',
                              isSelected: _selectedGoalType == 'Mutual',
                              onTap: () {
                                setState(() {
                                  // Toggle: ถ้าเลือก Mutual อยู่แล้วให้ยกเลิก
                                  if (_selectedGoalType == 'Mutual') {
                                    _selectedGoalType = null; // ยกเลิกการเลือก
                                    _selectedFriends.clear(); // ล้างรายชื่อเพื่อน
                                  } else {
                                    _selectedGoalType = 'Mutual'; // เลือก Mutual
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      // Add Friend Section (only show for Mutual)
                      if (_selectedGoalType == 'Mutual') ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Add friend',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Display selected friends
                        ..._selectedFriends.map((friend) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.purple,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  friend,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedFriends.remove(friend);
                                  });
                                },
                                icon: const Icon(Icons.close),
                                color: Colors.grey,
                                iconSize: 20,
                              ),
                            ],
                          ),
                        )),
                        
                        // Add Friend Button
                        OutlinedButton.icon(
                          onPressed: _showAddFriendDialog,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add friend'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B68EE), Color(0xFFDA70D6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Goal Type Card Widget
class _GoalTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple.shade100 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.purple : Colors.grey.shade600,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.purple : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.purple.shade300 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Friend Checkbox Item Widget
class _FriendCheckboxItem extends StatelessWidget {
  final String name;
  final String avatar;
  final bool isSelected;
  final Function(bool) onChanged;

  const _FriendCheckboxItem({
    required this.name,
    required this.avatar,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF7B68EE) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                avatar,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            // Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: const Color(0xFF7B68EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
