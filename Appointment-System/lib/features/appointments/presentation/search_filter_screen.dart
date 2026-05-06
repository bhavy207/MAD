import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SearchFilterScreen extends StatelessWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search & Filter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search by Name or ID...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Status", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text("Confirmed"),
                  selected: true,
                  onSelected: (val) {},
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
                FilterChip(
                  label: const Text("Completed"),
                  selected: false,
                  onSelected: (val) {},
                ),
                FilterChip(
                  label: const Text("Cancelled"),
                  selected: false,
                  onSelected: (val) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Service Type", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text("Consultation"),
                  selected: true,
                  onSelected: (val) {},
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
                FilterChip(
                  label: const Text("Specialist"),
                  selected: false,
                  onSelected: (val) {},
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Apply Filters"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
