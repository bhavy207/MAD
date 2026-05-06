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

  // ── Cancel with confirmation ──────────────────────────────────────────────
  Future<void> _cancelAppointment(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error),
            SizedBox(width: 8),
            Text("Cancel Appointment"),
          ],
        ),
        content: const Text(
          "Are you sure you want to cancel this appointment?\n\n"
          "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep It"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Cancel",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(appointmentProvider.notifier).cancelAppointment(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Appointment cancelled."),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider so list updates reactively
    ref.watch(appointmentProvider);
    final notifier = ref.read(appointmentProvider.notifier);
    final isUpcoming = type == "upcoming";

    final appointments = type == "upcoming"
        ? notifier.upcoming
        : (type == "completed" ? notifier.completed : notifier.cancelled);

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "No $type appointments",
              style: const TextStyle(
                  color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.push('/book'),
                icon: const Icon(Icons.add),
                label: const Text("Book Now"),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final dateObj = DateTime.parse(appt['date']);
        final formattedDate = DateFormat('MMM d, yyyy').format(dateObj);
        final doctor = (appt['doctor'] as String?) ?? 'Dr. Sarah Jenkins';

        Color badgeColor;
        String badgeText;
        Color badgeBg;

        if (type == 'upcoming') {
          badgeColor = AppColors.secondary;
          badgeBg = AppColors.secondary.withOpacity(0.1);
          badgeText = "CONFIRMED";
        } else if (type == 'completed') {
          badgeColor = AppColors.success;
          badgeBg = AppColors.success.withOpacity(0.1);
          badgeText = "COMPLETED";
        } else {
          badgeColor = AppColors.error;
          badgeBg = AppColors.error.withOpacity(0.1);
          badgeText = "CANCELLED";
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "$formattedDate  •  ${appt['time']}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Service name ───────────────────────────────────────────
                Text(
                  appt['service'] ?? '',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // ── Doctor ─────────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ── Queue + action row ─────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        size: 15, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Queue: ${appt['queueNumber']}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const Spacer(),
                    if (isUpcoming) ...[
                      // ── Reschedule ─────────────────────────────────────
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/book/${appt['id']}');
                        },
                        icon: const Icon(Icons.event_repeat, size: 14),
                        label: const Text("Reschedule",
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(
                              color: AppColors.primary.withOpacity(0.5)),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ── Cancel ─────────────────────────────────────────
                      OutlinedButton.icon(
                        onPressed: () => _cancelAppointment(
                            context, ref, appt['id']),
                        icon: const Icon(Icons.cancel_outlined, size: 14),
                        label: const Text("Cancel",
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side:
                              BorderSide(color: AppColors.error.withOpacity(0.5)),
                          foregroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
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
