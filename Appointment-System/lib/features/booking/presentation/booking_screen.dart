import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/appointment_provider.dart';

// ── Doctor Data Model ─────────────────────────────────────────────────────────
class DoctorModel {
  final String name;
  final String degree;
  final String specialty;
  final String avatar; // initials
  final Color color;

  const DoctorModel({
    required this.name,
    required this.degree,
    required this.specialty,
    required this.avatar,
    required this.color,
  });

  String get fullTitle => 'Dr. $name, $degree';
}

const List<DoctorModel> kDoctors = [
  DoctorModel(name: 'Sarah Jenkins',  degree: 'MD',   specialty: 'General Medicine',       avatar: 'SJ', color: Color(0xFF6366F1)),
  DoctorModel(name: 'Arjun Mehta',   degree: 'MS',   specialty: 'Orthopedic Surgery',      avatar: 'AM', color: Color(0xFF0EA5E9)),
  DoctorModel(name: 'Priya Sharma',  degree: 'MBBS', specialty: 'Pediatrics',              avatar: 'PS', color: Color(0xFF10B981)),
  DoctorModel(name: 'Rajiv Kapoor',  degree: 'DM',   specialty: 'Cardiology',              avatar: 'RK', color: Color(0xFFF43F5E)),
  DoctorModel(name: 'Neha Gupta',    degree: 'MS',   specialty: 'Gynecology & Obstetrics', avatar: 'NG', color: Color(0xFFF59E0B)),
  DoctorModel(name: 'James Wilson',  degree: 'PhD',  specialty: 'Neurology',               avatar: 'JW', color: Color(0xFF8B5CF6)),
  DoctorModel(name: 'Anita Desai',   degree: 'MD',   specialty: 'Dermatology',             avatar: 'AD', color: Color(0xFF14B8A6)),
  DoctorModel(name: 'Omar Sheikh',   degree: 'FRCS', specialty: 'ENT Surgery',             avatar: 'OS', color: Color(0xFFEC4899)),
];

// ── Booking Screen ────────────────────────────────────────────────────────────
class BookingScreen extends ConsumerStatefulWidget {
  final String? appointmentId; // set when rescheduling
  const BookingScreen({super.key, this.appointmentId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedService = 'General Consultation';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '10:30 AM';
  DoctorModel? _selectedDoctor;

  final List<String> _services = [
    'General Consultation',
    'Specialist Review',
    'Follow-up',
    'Emergency',
    'Routine Check-up',
    'Vaccination',
  ];

  final List<Map<String, dynamic>> _slots = [
    {'time': '09:00 AM', 'available': true,  'spots': 3},
    {'time': '10:30 AM', 'available': true,  'spots': 2},
    {'time': '11:15 AM', 'available': false, 'spots': 0},
    {'time': '01:00 PM', 'available': true,  'spots': 4},
    {'time': '02:45 PM', 'available': true,  'spots': 1},
    {'time': '04:00 PM', 'available': false, 'spots': 0},
  ];

  bool get _isRescheduling => widget.appointmentId != null;

  @override
  void initState() {
    super.initState();
    if (_isRescheduling) {
      // Pre-fill from existing appointment
      final appt = ref
          .read(appointmentProvider)
          .firstWhere((a) => a['id'] == widget.appointmentId,
              orElse: () => {});
      if (appt.isNotEmpty) {
        _nameController.text = appt['name'] ?? '';
        _selectedService = appt['service'] ?? _selectedService;
        _selectedDate = DateTime.parse(appt['date']);
        _selectedSlot = appt['time'] ?? _selectedSlot;
        // Try to match doctor
        final docName = appt['doctor'] as String? ?? '';
        _selectedDoctor = kDoctors.cast<DoctorModel?>().firstWhere(
          (d) => d!.fullTitle == docName,
          orElse: () => null,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Doctor selector bottom sheet ─────────────────────────────────────────
  void _showDoctorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Select Doctor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Choose your preferred doctor",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kDoctors.length,
                itemBuilder: (_, i) {
                  final doc = kDoctors[i];
                  final isSelected = _selectedDoctor?.name == doc.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDoctor = doc);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? doc.color.withOpacity(0.1)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected ? doc.color : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: doc.color.withOpacity(0.15),
                            child: Text(
                              doc.avatar,
                              style: TextStyle(
                                color: doc.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. ${doc.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: doc.color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        doc.degree,
                                        style: TextStyle(
                                          color: doc.color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        doc.specialty,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: doc.color),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a doctor.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final notifier = ref.read(appointmentProvider.notifier);

    if (_isRescheduling) {
      notifier.rescheduleAppointment(
        widget.appointmentId!,
        _selectedDate,
        _selectedSlot,
      );
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.event_repeat, color: AppColors.secondary),
            SizedBox(width: 8),
            Text("Rescheduled!"),
          ]),
          content: Text(
            "Your appointment has been rescheduled.\n\n"
            "📅 ${DateFormat('MMM d, yyyy').format(_selectedDate)}\n"
            "⏰ $_selectedSlot",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text("Done"),
            ),
          ],
        ),
      );
    } else {
      notifier.addAppointment(
        _selectedService,
        _selectedDate,
        _selectedSlot,
        _nameController.text.trim(),
        _selectedDoctor!.fullTitle,
      );

      final queueNumber = notifier.state.last['queueNumber'];
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text("Booked!"),
          ]),
          content: Text(
            "Appointment booked successfully!\n\n"
            "👨‍⚕️ ${_selectedDoctor!.fullTitle}\n"
            "📅 ${DateFormat('MMM d, yyyy').format(_selectedDate)}\n"
            "⏰ $_selectedSlot\n"
            "🎫 Queue: $queueNumber",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRescheduling ? 'Reschedule Appointment' : 'Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRescheduling ? "Update Appointment" : "Appointment Details",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // ── Patient name ─────────────────────────────────────────────
              if (!_isRescheduling)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
              if (!_isRescheduling) const SizedBox(height: 16),

              // ── Doctor selector ──────────────────────────────────────────
              const Text(
                "Select Doctor",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _showDoctorPicker,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _selectedDoctor != null
                        ? _selectedDoctor!.color.withOpacity(0.06)
                        : Colors.grey[100],
                    border: Border.all(
                      color: _selectedDoctor != null
                          ? _selectedDoctor!.color.withOpacity(0.5)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedDoctor == null
                      ? Row(
                          children: [
                            const Icon(Icons.person_search,
                                color: Colors.grey),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text("Tap to choose a doctor",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        )
                      : Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  _selectedDoctor!.color.withOpacity(0.15),
                              child: Text(
                                _selectedDoctor!.avatar,
                                style: TextStyle(
                                  color: _selectedDoctor!.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. ${_selectedDoctor!.name}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: _selectedDoctor!.color
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _selectedDoctor!.degree,
                                          style: TextStyle(
                                            color: _selectedDoctor!.color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _selectedDoctor!.specialty,
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.edit_outlined,
                                color: _selectedDoctor!.color, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Service Type ─────────────────────────────────────────────
              if (!_isRescheduling)
                DropdownButtonFormField<String>(
                  value: _selectedService,
                  decoration: const InputDecoration(
                    labelText: "Service Type",
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                  ),
                  items: _services
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedService = v!),
                ),
              if (!_isRescheduling) const SizedBox(height: 24),

              // ── Date picker ──────────────────────────────────────────────
              const Text(
                "Preferred Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.primary),
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Time slots ───────────────────────────────────────────────
              const Text(
                "Available Slots",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _slots.length,
                itemBuilder: (_, i) {
                  final slot = _slots[i];
                  final isAvailable = slot['available'] as bool;
                  final isSelected = _selectedSlot == slot['time'];
                  return InkWell(
                    onTap: isAvailable
                        ? () =>
                            setState(() => _selectedSlot = slot['time'])
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isAvailable
                                ? Colors.white
                                : Colors.grey[100],
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isAvailable
                                  ? AppColors.primary.withOpacity(0.3)
                                  : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot['time'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isAvailable
                                      ? Colors.black87
                                      : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                          if (isAvailable)
                            Text(
                              "${slot['spots']} left",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.success,
                                fontSize: 9,
                              ),
                            )
                          else
                            const Text("Full",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 9)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── Submit button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isRescheduling ? "Confirm Reschedule" : "Confirm Booking",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
