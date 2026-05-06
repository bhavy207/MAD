import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search'),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AppointmentList(type: "upcoming"),
            _AppointmentList(type: "completed"),
            _AppointmentList(type: "cancelled"),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/book'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final String type;

  const _AppointmentList({required this.type});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final isUpcoming = type == "upcoming";
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: isUpcoming ? 2 : 1,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Oct 12, 2024 • 10:30 AM",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUpcoming ? AppColors.secondary.withOpacity(0.1) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUpcoming ? "CONFIRMED" : type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUpcoming ? AppColors.secondary : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "General Consultation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Dr. Sarah Jenkins",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text("Queue: #A-104"),
                    const Spacer(),
                    if (isUpcoming) ...[
                      TextButton(
                        onPressed: () {},
                        child: const Text("Reschedule"),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text("Cancel"),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
