import 'package:flutter/material.dart';
import '../../models/truyen.dart';
import '../details/story_detail_screen.dart';
import '../../data/sample_data.dart';

class ReadingHistoryScreen extends StatelessWidget {
  const ReadingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tạm thời dùng dữ liệu mẫu
    final readingHistory = sampleTruyens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đọc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng này sẽ sớm được cập nhật!'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: readingHistory.length,
        itemBuilder: (context, index) {
          final story = readingHistory[index];
          return ListTile(
            leading: Image.network(
              story.imageUrl,
              width: 40,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(story.title),
            subtitle: Text('Đã đọc: Chapter ${story.chapter}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryDetailScreen(truyen: story),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 