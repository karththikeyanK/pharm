import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharm/db/user_helper.dart';

import '../db/db_helper.dart';
import '../db/model/user.dart';

final userProvider = StateNotifierProvider<UserNotifier, List<User>>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<List<User>> {
  UserNotifier() : super([]) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final users = await UserHelper.instance.getAllUsers();
    state = users;
  }

  Future<void> addUser(User user) async {
    await UserHelper.instance.insertUser(user);
    fetchUsers();
  }

  Future<void> updateUser(BuildContext context ,User user) async {
    // Check if the username already exists
    final existingUser = await UserHelper.instance.getUserByUsername(user.username);

    if (existingUser != null && existingUser.id != user.id) {
      // If the username exists and the user is not the same user being updated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Username already exists!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20.0),
        ),
      );
      return; // Exit the method without updating
    }

    // Check if username or password is empty or if the password length is less than 4 characters
    if (user.username.isEmpty || user.password.isEmpty || user.password.length < 4) {
      // Show alert if validation fails
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('Username and password cannot be empty and password must be at least 4 characters long.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // Exit the method without updating
    }

    // Proceed with the update if all checks pass
    await UserHelper.instance.updateUser(user);
    fetchUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Update successful!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20.0),
      ),
    );

    Navigator.pop(context);
  }


  Future<void> deleteUser(int id) async {
    await UserHelper.instance.deleteUser(id);
    fetchUsers();
  }

  Future<User?> checkUser(String username, String password) async {
    final user = await UserHelper.instance.checkUser(username, password);
    return user;
  }
}
