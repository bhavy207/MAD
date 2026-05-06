import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/appointment_provider.dart';

class QueueStatusScreen extends ConsumerWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appointmentProvider);
    final upcomingAppts = ref.read(appointmentProvider.notifier).upcoming;
    final hasUpcoming = upcomingAppts.isNotEmpty;
    final myToken = hasUpcoming ? upcomingAppts.first['queueNumber'] as String : "#A-104";
    
    int myNumber = 104;
    try {
      myNumber = int.parse(myToken.split('-').last);
    } catch (_) {}

    final servingNumber = myNumber > 100 ? myNumber - 2 : myNumber;
    final servingToken = "#A-$servingNumber";
    final peopleAhead = myNumber > servingNumber ? myNumber - servingNumber - 1 : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.wifi, color: AppColors.success, size: 16),
                    SizedBox(width: 8),
                    Text("Live Updates Active", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text("Currently Serving", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                servingToken,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 40),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text("Your Token", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        myToken,
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.grey[200],
                        color: AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("People Ahead", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text("$peopleAhead", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(width: 1, height: 40, color: Colors.grey[300]),
                          Column(
                            children: [
                              const Text("Est. Wait Time", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text("${peopleAhead * 15}m", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Queue Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              _QueueItem(token: "#A-${servingNumber - 1}", status: "Completed", isCurrent: false),
              _QueueItem(token: servingToken, status: "Serving", isCurrent: true),
              if (peopleAhead > 0)
                _QueueItem(token: "#A-${servingNumber + 1}", status: "Next", isCurrent: false),
              _QueueItem(token: myToken, status: "You", isCurrent: false, isYou: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final String token;
  final String status;
  final bool isCurrent;
  final bool isYou;

  const _QueueItem({
    required this.token,
    required this.status,
    required this.isCurrent,
    this.isYou = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isYou ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isYou ? AppColors.primary : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isCurrent)
                const Icon(Icons.arrow_right, color: AppColors.primary)
              else if (status == "Completed")
                const Icon(Icons.check_circle, color: AppColors.success)
              else
                const SizedBox(width: 24),
              const SizedBox(width: 12),
              Text(
                token,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: status == "Completed" ? Colors.grey : Colors.black87,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary
                  : (status == "Completed" ? Colors.grey[200] : Colors.blue[50]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isCurrent
                    ? Colors.white
                    : (status == "Completed" ? Colors.grey : Colors.blue[700]),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
