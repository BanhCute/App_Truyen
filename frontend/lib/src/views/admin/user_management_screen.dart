import 'package:flutter/material.dart';
import 'package:du_an_1/src/models/user.dart';

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
          return ListTile(
            title: Text(users[index].email),
            subtitle: Text(users[index].role),
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
