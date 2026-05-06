import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Map<String, dynamic>>>((ref) {
  return AppointmentNotifier();
});

class AppointmentNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  AppointmentNotifier() : super([]) {
    _loadAppointments();
  }

  final _box = Hive.box('appointments_offline');
  final _uuid = const Uuid();

  void _loadAppointments() {
    final data = _box.values.toList().cast<Map<dynamic, dynamic>>();
    state = data.map((e) => Map<String, dynamic>.from(e)).toList();
    state.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });
  }

  // ── User: Add appointment ─────────────────────────────────────────────────
  void addAppointment(String service, DateTime date, String time, String name, String doctorName) {
    final newAppointment = {
      'id': _uuid.v4(),
      'name': name,
      'service': service,
      'doctor': doctorName,
      'date': date.toIso8601String(),
      'time': time,
      'status': 'upcoming',
      'queueNumber': '#A-${100 + state.length + 1}',
      'notes': '',
    };
    _box.add(newAppointment);
    _loadAppointments();
  }

  // ── Helper: update a field for an appointment by id ──────────────────────
  void _updateAppointmentField(String id, Map<String, dynamic> fields) {
    final mapList = _box.toMap();
    for (var entry in mapList.entries) {
      if (entry.value['id'] == id) {
        final appt = Map<String, dynamic>.from(entry.value);
        appt.addAll(fields);
        _box.put(entry.key, appt);
        break;
      }
    }
    _loadAppointments();
  }

  // ── User: Cancel ──────────────────────────────────────────────────────────
  void cancelAppointment(String id) =>
      _updateAppointmentField(id, {'status': 'cancelled'});

  // ── User: Reschedule (update date + time) ─────────────────────────────────
  void rescheduleAppointment(String id, DateTime newDate, String newTime) =>
      _updateAppointmentField(id, {
        'date': newDate.toIso8601String(),
        'time': newTime,
      });

  // ── Admin: Complete appointment ───────────────────────────────────────────
  void completeAppointment(String id) =>
      _updateAppointmentField(id, {'status': 'completed'});

  // ── Admin: Approve / restore to upcoming ─────────────────────────────────
  void approveAppointment(String id) =>
      _updateAppointmentField(id, {'status': 'upcoming'});

  // ── Admin: Delete permanently ─────────────────────────────────────────────
  void deleteAppointment(String id) {
    final mapList = _box.toMap();
    for (var entry in mapList.entries) {
      if (entry.value['id'] == id) {
        _box.delete(entry.key);
        break;
      }
    }
    _loadAppointments();
  }

  // ── Admin: Add a note to an appointment ──────────────────────────────────
  void addNote(String id, String note) =>
      _updateAppointmentField(id, {'notes': note});

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get all => state;
  List<Map<String, dynamic>> get upcoming => state.where((e) => e['status'] == 'upcoming').toList();
  List<Map<String, dynamic>> get completed => state.where((e) => e['status'] == 'completed').toList();
  List<Map<String, dynamic>> get cancelled => state.where((e) => e['status'] == 'cancelled').toList();

  int get totalCount => state.length;
  int get upcomingCount => upcoming.length;
  int get completedCount => completed.length;
  int get cancelledCount => cancelled.length;
}
