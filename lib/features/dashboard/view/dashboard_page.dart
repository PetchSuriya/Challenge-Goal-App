import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

/// DashboardPage - โมคอัพหน้าแดชบอร์ดหลังจากล็อกอิน
/// แสดงสรุปข้อมูลแบบการ์ดและรายการกิจกรรมล่าสุดอย่างง่าย
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        actions: const [SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient accent similar to Login
              _Header(),
              const SizedBox(height: 16),

              // Goal button
              _GradientButton(
                onPressed: () => context.go(AppConstants.goalRoute),
                icon: Icons.flag_outlined,
                label: 'Goal',
              ),
              const SizedBox(height: 20),

              // Summary cards
              _buildSummaryCards(context),
              const SizedBox(height: 24),

              // Recent section
              const Text(
                'รายการล่าสุด',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildRecentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final cards = [
      _SummaryCardData(
        icon: Icons.flag_outlined,
        title: 'เป้าหมาย',
        value: '12',
        color: Colors.indigo,
      ),
      _SummaryCardData(
        icon: Icons.check_circle_outline,
        title: 'สำเร็จ',
        value: '7',
        color: Colors.green,
      ),
      _SummaryCardData(
        icon: Icons.schedule_outlined,
        title: 'ระหว่างทำ',
        value: '3',
        color: Colors.orange,
      ),
      _SummaryCardData(
        icon: Icons.warning_amber_outlined,
        title: 'ต้องสนใจ',
        value: '2',
        color: Colors.red,
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final c = cards[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(c.icon, color: Colors.white),
              ),
              const Spacer(),
              Text(
                c.title,
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                c.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentList() {
    final items = List.generate(6, (i) => 'กิจกรรมตัวอย่าง #${i + 1}');
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final title = items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: const CircleAvatar(child: Icon(Icons.event_note)),
          title: Text(title),
          subtitle: const Text('รายละเอียดสั้น ๆ ของกิจกรรมล่าสุด'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
    );
  }
}

class _SummaryCardData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  _SummaryCardData({required this.icon, required this.title, required this.value, required this.color});
}



class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.dashboard_outlined, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สวัสดี 👋',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'นี่คือหน้าแดชบอร์ดที่สไตล์ใกล้เคียงกับหน้า Login',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  const _GradientButton({required this.onPressed, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
