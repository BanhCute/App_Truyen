import 'package:flutter/material.dart';
import 'package:frontend/src/models/user.dart';

class UserManagementScreen extends StatelessWidget {
  UserManagementScreen({super.key});

  final List<User> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài khoản'),
        backgroundColor: const Color(0xFF1B3A57),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final roles = user.roles.map((r) => r.roleName).join(', ');

          return ListTile(
            leading: user.avatar != null
                ? CircleAvatar(backgroundImage: NetworkImage(user.avatar!))
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.email != null) Text(user.email!),
                Text('Vai trò: $roles'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Chỉnh sửa'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa'),
                ),
              ],
              onSelected: (value) {
                // Xử lý chỉnh sửa hoặc xóa user
              },
            ),
          );
        },
      ),
    );
  }
}
