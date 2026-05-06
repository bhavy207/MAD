import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/appointment_provider.dart';
import '../../../core/providers/user_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Access Denied Screen ──────────────────────────────────────────────────
  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, size: 64, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              const Text(
                "Access Denied",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "You don't have permission to access the Admin Dashboard.\n\nOnly administrators can manage appointments and queue.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Go Back"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Confirm Dialog ────────────────────────────────────────────────────────
  Future<bool> _confirm(String title, String body, Color actionColor) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: actionColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Confirm", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── Note Dialog ───────────────────────────────────────────────────────────
  Future<void> _showNoteDialog(String id, String currentNote) async {
    final ctrl = TextEditingController(text: currentNote);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add / Edit Note"),
        content: TextFormField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter admin note for this appointment...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              ref.read(appointmentProvider.notifier).addNote(id, ctrl.text.trim());
              Navigator.pop(ctx);
              _snack("Note saved!", AppColors.success);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    // ── Guard: Only admins ────────────────────────────────────────────────
    if (!user.isAdmin) return _buildAccessDenied(context);

    ref.watch(appointmentProvider);
    final notifier = ref.read(appointmentProvider.notifier);
    final total = notifier.totalCount;
    final upcomingCount = notifier.upcomingCount;
    final completedCount = notifier.completedCount;
    final cancelledCount = notifier.cancelledCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('SmartQueue Management', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: "Upcoming ($upcomingCount)"),
            Tab(text: "Completed ($completedCount)"),
            Tab(text: "Cancelled ($cancelledCount)"),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Stats Row ───────────────────────────────────────────────────
          Container(
            color: AppColors.primary.withOpacity(0.06),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                _MiniStat(label: "Total", value: "$total", color: AppColors.primary),
                _MiniStat(label: "Active", value: "$upcomingCount", color: AppColors.secondary),
                _MiniStat(label: "Done", value: "$completedCount", color: AppColors.success),
                _MiniStat(label: "Cancelled", value: "$cancelledCount", color: AppColors.error),
              ],
            ),
          ),

          // ── Tab Views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AppointmentManageList(
                  appointments: notifier.upcoming,
                  emptyMessage: "No upcoming appointments.",
                  onComplete: (id) async {
                    final ok = await _confirm(
                      "Mark as Completed",
                      "Mark this appointment as completed?",
                      AppColors.success,
                    );
                    if (ok) {
                      ref.read(appointmentProvider.notifier).completeAppointment(id);
                      _snack("Appointment marked as completed ✓", AppColors.success);
                    }
                  },
                  onCancel: (id) async {
                    final ok = await _confirm(
                      "Cancel Appointment",
                      "Are you sure you want to cancel this appointment?",
                      AppColors.error,
                    );
                    if (ok) {
                      ref.read(appointmentProvider.notifier).cancelAppointment(id);
                      _snack("Appointment cancelled.", AppColors.error);
                    }
                  },
                  onNote: (id, note) => _showNoteDialog(id, note),
                  showComplete: true,
                  showApprove: false,
                ),
                _AppointmentManageList(
                  appointments: notifier.completed,
                  emptyMessage: "No completed appointments yet.",
                  onComplete: null,
                  onCancel: (id) async {
                    final ok = await _confirm(
                      "Delete Appointment",
                      "Permanently delete this completed appointment?",
                      AppColors.error,
                    );
                    if (ok) {
                      ref.read(appointmentProvider.notifier).deleteAppointment(id);
                      _snack("Appointment deleted.", Colors.grey);
                    }
                  },
                  onNote: (id, note) => _showNoteDialog(id, note),
                  showComplete: false,
                  showApprove: false,
                ),
                _AppointmentManageList(
                  appointments: notifier.cancelled,
                  emptyMessage: "No cancelled appointments.",
                  onComplete: null,
                  onCancel: (id) async {
                    final ok = await _confirm(
                      "Delete Appointment",
                      "Permanently delete this record?",
                      AppColors.error,
                    );
                    if (ok) {
                      ref.read(appointmentProvider.notifier).deleteAppointment(id);
                      _snack("Record deleted.", Colors.grey);
                    }
                  },
                  onNote: (id, note) => _showNoteDialog(id, note),
                  showComplete: false,
                  showApprove: true,
                  onApprove: (id) async {
                    final ok = await _confirm(
                      "Re-Approve",
                      "Restore this appointment to upcoming?",
                      AppColors.secondary,
                    );
                    if (ok) {
                      ref.read(appointmentProvider.notifier).approveAppointment(id);
                      _snack("Appointment re-approved! ✓", AppColors.secondary);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Widget ──────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

// ── Appointment Management List ───────────────────────────────────────────────
class _AppointmentManageList extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final String emptyMessage;
  final Future<void> Function(String id)? onComplete;
  final Future<void> Function(String id) onCancel;
  final Future<void> Function(String id, String note) onNote;
  final bool showComplete;
  final bool showApprove;
  final Future<void> Function(String id)? onApprove;

  const _AppointmentManageList({
    required this.appointments,
    required this.emptyMessage,
    required this.onComplete,
    required this.onCancel,
    required this.onNote,
    required this.showComplete,
    required this.showApprove,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final dateObj = DateTime.parse(appt['date']);
        final formattedDate = DateFormat('MMM d, yyyy').format(dateObj);
        final status = appt['status'] as String;
        final note = (appt['notes'] ?? '') as String;

        Color statusColor;
        IconData statusIcon;
        switch (status) {
          case 'completed':
            statusColor = AppColors.success;
            statusIcon = Icons.check_circle;
            break;
          case 'cancelled':
            statusColor = AppColors.error;
            statusIcon = Icons.cancel;
            break;
          default:
            statusColor = AppColors.secondary;
            statusIcon = Icons.schedule;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: statusColor.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: statusColor.withOpacity(0.12),
                      child: Text(
                        (appt['name'] as String? ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            appt['service'] ?? '',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ── Details ──────────────────────────────────────────────
                Row(
                  children: [
                    _InfoChip(icon: Icons.calendar_today, text: formattedDate),
                    const SizedBox(width: 8),
                    _InfoChip(icon: Icons.access_time, text: appt['time'] ?? ''),
                    const SizedBox(width: 8),
                    _InfoChip(icon: Icons.confirmation_number_outlined, text: appt['queueNumber'] ?? ''),
                  ],
                ),

                // ── Admin Note ───────────────────────────────────────────
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(note, style: const TextStyle(fontSize: 12, color: Colors.brown)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Action Buttons ───────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (showComplete && onComplete != null)
                      _ActionButton(
                        icon: Icons.check_circle_outline,
                        label: "Complete",
                        color: AppColors.success,
                        onTap: () => onComplete!(appt['id']),
                      ),
                    if (showApprove && onApprove != null)
                      _ActionButton(
                        icon: Icons.restore,
                        label: "Re-Approve",
                        color: AppColors.secondary,
                        onTap: () => onApprove!(appt['id']),
                      ),
                    _ActionButton(
                      icon: Icons.sticky_note_2_outlined,
                      label: note.isEmpty ? "Add Note" : "Edit Note",
                      color: Colors.amber.shade700,
                      onTap: () => onNote(appt['id'], note),
                    ),
                    _ActionButton(
                      icon: status == 'cancelled' || status == 'completed'
                          ? Icons.delete_outline
                          : Icons.cancel_outlined,
                      label: status == 'cancelled' || status == 'completed' ? "Delete" : "Cancel",
                      color: AppColors.error,
                      onTap: () => onCancel(appt['id']),
                    ),
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

// ── Info Chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
