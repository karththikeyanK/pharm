import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/provider/router_provider.dart';

import '../../db/model/user.dart';
import '../../provider/user_provider.dart';

class AddUserPage extends ConsumerStatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends ConsumerState<AddUserPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedRole = 'ADMIN'; // Default role selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background color for the screen
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: 450, // Adjust the height as needed
          width: 350, // Adjust the width to make it smaller
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Add User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                    DropdownMenuItem(value: 'CASHIER', child: Text('Cashier')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final user = User(
                          name: nameController.text,
                          username: usernameController.text,
                          password: passwordController.text,
                          role: selectedRole!,
                        );
                        ref.read(userProvider.notifier).addUser(user);
                        GoRouter.of(context).go(ADMIN_SETTINGS);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Blue button color
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add User'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
