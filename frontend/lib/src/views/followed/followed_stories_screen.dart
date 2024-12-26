import 'package:flutter/material.dart';
import '../../models/truyen.dart';
import '../../widgets/truyen_card.dart';
import '../../data/sample_data.dart';

class FollowedStoriesScreen extends StatelessWidget {
  const FollowedStoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tạm thời dùng dữ liệu mẫu
    final followedStories = sampleTruyens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Truyện đang theo dõi'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: followedStories.length,
        itemBuilder: (context, index) {
          return TruyenCard(truyen: followedStories[index]);
        },
      ),
    );
  }
}
