import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/provider/router_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            // Add User Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Add User Screen
                context.go(ADD_USER);
              },
              child: const Text('Add User'),
            ),
            const SizedBox(height: 10),

            // View Users Button
            ElevatedButton(
              onPressed: () {
                // Navigate to View User Screen
                context.go(VIEW_USER);
              },
              child: const Text('View Users'),
            ),
            const SizedBox(height: 10),

            // Get Report Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Get Report Screen
                context.go('/get_report');
              },
              child: const Text('Get Report'),
            ),
            const SizedBox(height: 10),

            // View Billings Button
            ElevatedButton(
              onPressed: () {
                // Navigate to View Billings Screen
                context.go('/view_billings');
              },
              child: const Text('View Billings'),
            ),
            const SizedBox(height: 10),

            // Add Stock Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Add Stock Screen
                context.go('/add_stock');
              },
              child: const Text('Add Stock'),
            ),
            const SizedBox(height: 10),

            // View Stock Button
            ElevatedButton(
              onPressed: () {
                // Navigate to View Stock Screen
                context.go('/view_stock');
              },
              child: const Text('View Stock'),
            ),
          ],
        ),
      ),
    );
  }
}
