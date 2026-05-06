import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedService = 'General Consultation';
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = '10:30 AM';

  final List<String> _services = ['General Consultation', 'Specialist Review', 'Follow-up', 'Emergency'];
  final List<Map<String, dynamic>> _slots = [
    {'time': '09:00 AM', 'available': false, 'spots': 0},
    {'time': '10:30 AM', 'available': true, 'spots': 2},
    {'time': '11:15 AM', 'available': true, 'spots': 5},
    {'time': '01:00 PM', 'available': false, 'spots': 0},
    {'time': '02:45 PM', 'available': true, 'spots': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Appointment Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                initialValue: "Alex Smith",
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: const InputDecoration(
                  labelText: "Service Type",
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
                items: _services.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedService = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Preferred Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Available Slots",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  final isAvailable = slot['available'] as bool;
                  final isSelected = _selectedSlot == slot['time'];

                  return InkWell(
                    onTap: isAvailable
                        ? () {
                            setState(() {
                              _selectedSlot = slot['time'] as String;
                            });
                          }
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isAvailable ? Colors.white : Colors.grey[200]),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isAvailable ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot['time'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isAvailable ? Colors.black87 : Colors.grey),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          if (isAvailable)
                            Text(
                              "${slot['spots']} spots left",
                              style: TextStyle(
                                color: isSelected ? Colors.white70 : AppColors.success,
                                fontSize: 10,
                              ),
                            )
                          else
                            const Text(
                              "Full",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Success"),
                          content: const Text("Appointment booked successfully!\nYour Queue Number is #A-105."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                context.pop(); // Go back to Home
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Booking", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text("Save Offline", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
