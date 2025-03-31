import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/provider/router_provider.dart';

import '../../db/model/user.dart';
import '../../provider/user_provider.dart';

class UserListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go(ADMIN_SETTINGS),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.refresh(userProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).go(ADD_USER),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: users.isEmpty
            ? _buildEmptyState()
            : _buildUserList(users, context, ref),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the + button to add a new user',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<User> users, BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: users.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                    child: Icon(
                      user.role == 'ADMIN' ? Icons.admin_panel_settings : Icons.person,
                      color: _getRoleColor(user.role),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Role: ${user.role}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(context, ref, user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue.shade600),
          onPressed: () => _showEditDialog(context, ref, user),
          tooltip: 'Edit User',
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade600),
          onPressed: () => {
            if(user.username == "1010"){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.username} could not be deleted'),
                  backgroundColor: Colors.red.shade600,
                ),
              )
            }else{
              _showDeleteConfirmation(context, ref, user)
            }
          },
          tooltip: 'Delete User',
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    return role == 'ADMIN' ? Colors.blue.shade700 : Colors.green.shade600;
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${user.username}?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {

              ref.read(userProvider.notifier).deleteUser(user.id!);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.username} deleted successfully'),
                  backgroundColor: Colors.green.shade600,
                ),
              );

            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, User user) {
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController(text: user.password);
    String? selectedRole = user.role.toUpperCase();
    final isSpecialUser = user.username == '1010'; // Check if special user

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 24),

                // Username Field (disabled for special user)
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: isSpecialUser,
                    fillColor: isSpecialUser ? Colors.grey.shade200 : null,
                  ),
                  readOnly: isSpecialUser,
                  enabled: !isSpecialUser,
                ),
                const SizedBox(height: 16),

                // Password Field (always enabled)
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Role Dropdown (disabled for special user)
                if (!isSpecialUser) ...[
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'ADMIN',
                        child: Text('Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'CASHIER',
                        child: Text('Cashier'),
                      ),
                    ],
                    onChanged: (value) => selectedRole = value,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.assignment_ind),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        final updatedUser = User(
                          id: user.id,
                          username: usernameController.text,
                          password: passwordController.text,
                          role: isSpecialUser ? user.role : selectedRole!,
                        );
                        ref.read(userProvider.notifier).updateUser(context, updatedUser);
                        context.pop();
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}