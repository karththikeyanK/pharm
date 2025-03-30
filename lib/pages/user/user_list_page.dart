import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/model/user.dart';
import '../../provider/user_provider.dart';
import 'add_user_screen.dart';
import 'package:go_router/go_router.dart';

import '../../provider/router_provider.dart';

class UserListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).go(ADMIN_SETTINGS);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddUserPage()));
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: users.isEmpty
            ? Center(child: Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)))
            : ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  title: Text(user.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('Role: ${user.role}', style: TextStyle(color: Colors.grey[600])),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDialog(context, ref, user);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref.read(userProvider.notifier).deleteUser(user.id!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, User user) {
    // final nameController = TextEditingController(text: user.name);
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController(text: user.password);
    final roleController = TextEditingController(text: user.role);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
              TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
              TextField(controller: roleController, decoration: InputDecoration(labelText: 'Role')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = User(
                  id: user.id,
                  username: usernameController.text,
                  password: passwordController.text,
                  role: roleController.text,
                );
                ref.read(userProvider.notifier).updateUser(context,updatedUser);

                Navigator.pop(context);

              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
