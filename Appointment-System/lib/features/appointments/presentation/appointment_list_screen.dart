import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/appointment_provider.dart';

class AppointmentListScreen extends ConsumerWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _AppointmentList extends ConsumerWidget {
  final String type;

  const _AppointmentList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(appointmentProvider.notifier);
    final isUpcoming = type == "upcoming";
    final appointments = type == "upcoming" 
        ? notifier.upcoming 
        : (type == "completed" ? notifier.completed : notifier.cancelled);

    if (appointments.isEmpty) {
      return Center(
        child: Text("No $type appointments found.", style: const TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final dateObj = DateTime.parse(appt['date']);
        final formattedDate = DateFormat('MMM d, yyyy').format(dateObj);
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
                      "$formattedDate • ${appt['time']}",
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
                Text(
                  appt['service'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    Text("Queue: ${appt['queueNumber']}"),
                    const Spacer(),
                    if (isUpcoming) ...[
                      TextButton(
                        onPressed: () {},
                        child: const Text("Reschedule"),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(appointmentProvider.notifier).cancelAppointment(appt['id']);
                        },
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
