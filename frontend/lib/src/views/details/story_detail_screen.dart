import 'package:flutter/material.dart';
import '../../models/truyen.dart';
import '../details/chapter_detail_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final Truyen truyen;

  const StoryDetailScreen({Key? key, required this.truyen}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.truyen.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.truyen.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B3A57),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Implement follow functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần thông tin truyện
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh bìa truyện
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.truyen.imageUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Thông tin bên phải
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.truyen.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Đánh giá sao
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _rating = index + 1.0;
                                  });
                                  // Hiển thị snackbar thông báo
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Bạn đã đánh giá ${_rating.toInt()} sao'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  // TODO: Gửi rating lên server khi có backend
                                },
                                child: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${_rating.toStringAsFixed(1)}/5.0',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Số chương: ${widget.truyen.totalChapters}'),
                        Text('Cập nhật: ${widget.truyen.updatedAt}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mô tả truyện
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mô tả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.truyen.description),
                ],
              ),
            ),

            // Danh sách chapter
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách chương',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.truyen.chapters.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.truyen.chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = widget.truyen.chapters[index];
                        return ListTile(
                          title: Text(
                            'Chương ${chapter.number}: ${chapter.title}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            'Ngày đăng: ${chapter.publishDate.day}/${chapter.publishDate.month}/${chapter.publishDate.year}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterDetailScreen(
                                  truyen: widget.truyen,
                                  chapter: chapter,
                                  currentIndex: index,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Chưa có chương nào',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
