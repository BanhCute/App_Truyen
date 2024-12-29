import 'package:flutter/material.dart';

class StoryManagementScreen extends StatelessWidget {
  const StoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý truyện'),
        backgroundColor: const Color(0xFF1B3A57),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hiển thị dialog thêm truyện
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Thêm truyện mới'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Tên truyện'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Link ảnh'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    // Xử lý thêm truyện
                    Navigator.pop(context);
                  },
                  child: const Text('Thêm'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 10, // Số lượng truyện mẫu
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.book),
            title: Text('Truyện ${index + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Xử lý sửa truyện
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Xử lý xóa truyện
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
