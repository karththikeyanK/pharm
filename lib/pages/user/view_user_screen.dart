import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharm/provider/user_provider.dart';

class ViewUserScreen extends ConsumerStatefulWidget {
  const ViewUserScreen({super.key});

  @override
  ViewUserScreenState createState() => ViewUserScreenState();
}

class ViewUserScreenState extends ConsumerState<ViewUserScreen> {
  @override
  void initState() {
    super.initState();
    // Load users when the screen is loaded
    ref.read(userProvider.notifier).loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userProvider); // Watch the state of users

    if (users.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View Users'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Users'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(user.name),
              subtitle: Text(user.username),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await ref.read(userProvider.notifier).deleteUser(user.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
