import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OfflineSyncScreen extends StatelessWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.cloud_off_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              "You are currently offline",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your app is still working. Bookings will sync automatically when you reconnect.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Pending Sync Items", style: TextStyle(fontWeight: FontWeight.bold)),
                      Badge(
                        label: Text("3"),
                        backgroundColor: AppColors.warning,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _SyncItem(title: "Booking: #A-105", status: "Pending"),
                  _SyncItem(title: "Cancel: #A-098", status: "Pending"),
                  _SyncItem(title: "Update Profile", status: "Pending"),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sync),
                label: const Text("Retry Sync"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncItem extends StatelessWidget {
  final String title;
  final String status;

  const _SyncItem({required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.pending_actions, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          Text(
            status,
            style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
