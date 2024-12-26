import 'package:flutter/material.dart';
import '../../models/truyen.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Truyen truyen;
  final Chapter chapter;
  final int currentIndex;

  const ChapterDetailScreen({
    required this.truyen,
    required this.chapter,
    required this.currentIndex,
    Key? key,
  }) : super(key: key);

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement follow functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh điều hướng chapter
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: widget.currentIndex > 0
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChapterDetailScreen(
                                truyen: widget.truyen,
                                chapter: widget
                                    .truyen.chapters[widget.currentIndex - 1],
                                currentIndex: widget.currentIndex - 1,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
                Text('Chương ${widget.chapter.number}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed:
                      widget.currentIndex < widget.truyen.chapters.length - 1
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChapterDetailScreen(
                                    truyen: widget.truyen,
                                    chapter: widget.truyen
                                        .chapters[widget.currentIndex + 1],
                                    currentIndex: widget.currentIndex + 1,
                                  ),
                                ),
                              );
                            }
                          : null,
                ),
              ],
            ),
          ),
          // Nội dung chapter
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(widget.chapter.content),
            ),
          ),
          // Phần bình luận
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Thêm bình luận...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // TODO: Implement comment functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget hiển thị danh sách chapter
class ChapterListBottomSheet extends StatelessWidget {
  final Truyen truyen;
  final int currentChapterIndex;

  const ChapterListBottomSheet({
    Key? key,
    required this.truyen,
    required this.currentChapterIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách chương',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: truyen.chapters.length,
              itemBuilder: (context, index) {
                final chapter = truyen.chapters[index];
                return ListTile(
                  title: Text(
                    'Chương ${chapter.number}: ${chapter.title}',
                    style: TextStyle(
                      fontWeight: index == currentChapterIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Đóng bottom sheet
                    if (index != currentChapterIndex) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetailScreen(
                            truyen: truyen,
                            chapter: chapter,
                            currentIndex: index,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
