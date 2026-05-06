import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Row
            Row(
              children: [
                Expanded(child: _StatCard(title: "Total Apps", value: "1,284", icon: Icons.calendar_today, color: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: "Active Queue", value: "42", icon: Icons.people, color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(title: "Completed", value: "156", icon: Icons.check_circle, color: AppColors.success)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: "Cancelled", value: "8", icon: Icons.cancel, color: AppColors.error)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Live Queue Management",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Move Forward"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                final isFirst = index == 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isFirst ? AppColors.primary : Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isFirst ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
                      child: Text("#${402 + index}", style: TextStyle(color: isFirst ? AppColors.primary : Colors.black87)),
                    ),
                    title: Text(index == 0 ? "Jonathan Sterling" : "Client Name"),
                    subtitle: const Text("Consultation"),
                    trailing: isFirst
                        ? const Chip(label: Text("In Progress"), backgroundColor: Colors.greenAccent)
                        : const Chip(label: Text("Waiting")),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        border: Border(top: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
