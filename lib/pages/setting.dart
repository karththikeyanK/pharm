import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/provider/router_provider.dart';

import '../constant/appconstant.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Settings - ${AppsConstant.userName}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3, // Three boxes per row
          crossAxisSpacing: 16, // Spacing between columns
          mainAxisSpacing: 16, // Spacing between rows
          childAspectRatio: 2, // Adjust the height of the boxes
          children: [
            _buildSettingBox(
              context,
              title: 'Add User',
              route: ADD_USER,
              icon: Icons.person_add,
            ),
            _buildSettingBox(
              context,
              title: 'View Users',
              route: VIEW_USER,
              icon: Icons.people,
            ),
            _buildSettingBox(
              context,
              title: 'Billing Page',
              route: BILLING_PAGE,
              icon: Icons.report,
            ),
            _buildSettingBox(
              context,
              title: 'View Billings',
              route: VIEW_BILLING_PAGE,
              icon: Icons.receipt,
            ),
            _buildSettingBox(
              context,
              title: 'Add Stock',
              route: ADD_STOCK,
              icon: Icons.add_box,
            ),
            _buildSettingBox(
              context,
              title: 'View Stock',
              route: VIEW_STOCK,
              icon: Icons.inventory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingBox(BuildContext context, {required String title, required String route, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.go(route);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}