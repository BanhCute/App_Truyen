import 'package:flutter/material.dart';
import '../../../models/novel.dart';
import '../../novel_detail/novel_detail_screen.dart';
import '../utils/time_ago.dart';

class RecentNovels extends StatelessWidget {
  final List<Novel> novels;

  const RecentNovels({
    Key? key,
    required this.novels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.update, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Truyện Mới Cập Nhật',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: novels.length,
          itemBuilder: (context, index) {
            final novel = novels[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    novel.cover,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
                title: Text(novel.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tác giả: ${novel.author}'),
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${novel.rating}'),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: novel.status == 'Hoàn thành'
                                ? Colors.green.withOpacity(0.2)
                                : novel.status == 'Tạm ngưng'
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            novel.status,
                            style: TextStyle(
                              fontSize: 12,
                              color: novel.status == 'Hoàn thành'
                                  ? Colors.green
                                  : novel.status == 'Tạm ngưng'
                                      ? Colors.red
                                      : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      getTimeAgo(novel.updatedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovelDetailScreen(novel: novel),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
