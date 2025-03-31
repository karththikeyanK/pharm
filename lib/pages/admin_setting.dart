import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/provider/router_provider.dart';

import '../constant/appconstant.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf5f7fa),
              Color(0xFFe4e8f0),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 80 : isMediumScreen ? 40 : 20,
              vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => context.pop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Settings Dashboard',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: Colors.deepPurple[100],
                      child: Text(
                        AppsConstant.userName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                    label: Text(
                      AppsConstant.userName,
                      style: const TextStyle(fontSize: 16),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 2,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: isLargeScreen
                      ? 4
                      : isMediumScreen
                      ? 3
                      : 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    _buildDesktopSettingBox(
                      context,
                      title: 'Add User',
                      route: ADD_USER,
                      icon: Icons.person_add_alt_1,
                      color: Colors.blueAccent,
                    ),
                    _buildDesktopSettingBox(
                      context,
                      title: 'View Users',
                      route: VIEW_USER,
                      icon: Icons.people_alt,
                      color: Colors.teal,
                    ),
                    _buildDesktopSettingBox(
                      context,
                      title: 'Billing Page',
                      route: BILLING_PAGE,
                      icon: Icons.payment,
                      color: Colors.orange,
                    ),
                    _buildDesktopSettingBox(
                      context,
                      title: 'View Billings',
                      route: VIEW_BILLING_PAGE,
                      icon: Icons.receipt_long,
                      color: Colors.purple,
                    ),
                    _buildDesktopSettingBox(
                      context,
                      title: 'Add Stock',
                      route: ADD_STOCK,
                      icon: Icons.add_box,
                      color: Colors.green,
                    ),
                    _buildDesktopSettingBox(
                      context,
                      title: 'View Stock',
                      route: VIEW_STOCK,
                      icon: Icons.inventory,
                      color: Colors.deepOrange,
                    ),
                    if (isLargeScreen) ...[
                      // Additional boxes for large screens
                      _buildDesktopSettingBox(
                        context,
                        title: 'Reports',
                        route: NOT_FOUND_PAGE,
                        icon: Icons.analytics,
                        color: Colors.indigo,
                      ),
                      _buildDesktopSettingBox(
                        context,
                        title: 'Settings',
                        route: NOT_FOUND_PAGE,
                        icon: Icons.settings,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSettingBox(
      BuildContext context, {
        required String title,
        required String route,
        required IconData icon,
        required Color color,
      }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getDescriptionForRoute(route),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Open',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDescriptionForRoute(String route) {
    switch (route) {
      case "/add_user":
        return 'Create new user accounts with specific permissions';
      case "/view_user":
        return 'View and manage all system users';
      case "/billing-page":
        return 'Generate new bills and invoices';
      case "/view-billing-page":
        return 'View billing history and reports';
      case "/add-stock":
        return 'Add new inventory items to stock';
      case "/view-stock":
        return 'View current inventory levels';
      default:
        return 'Manage system settings';
    }
  }
}