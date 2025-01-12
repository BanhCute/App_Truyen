import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/chapter.dart';
import '../../../models/reading_history.dart';
import '../../../models/novel.dart';
import '../../../services/reading_history_service.dart';
import '../../novel_detail/novel_detail_screen.dart';
import '../../details/chapter_detail_screen.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<ReadingHistory> history = [];
  Map<String, int> chapterCounts = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Lấy lịch sử đọc
      final historyData = await ReadingHistoryService.getHistory();

      // Lấy thông tin truyện và số chương mới nhất
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> novels = json.decode(response.body);
        final List<ReadingHistory> updatedHistory = [];

        // Cập nhật thông tin truyện
        for (var item in historyData) {
          final novelData = novels.firstWhere(
            (novel) => novel['id'].toString() == item.novel.id,
            orElse: () => null,
          );

          if (novelData != null) {
            final updatedNovel = Novel(
              id: novelData['id'].toString(),
              name: novelData['name'] ?? '',
              description: novelData['description'] ?? '',
              author: novelData['author'] ?? '',
              cover: novelData['cover'] ?? '',
              categories: (novelData['categories'] as List?)
                      ?.map((cat) => NovelCategory.fromJson(cat))
                      .toList() ??
                  [],
              createdAt: DateTime.parse(
                  novelData['createdAt'] ?? DateTime.now().toIso8601String()),
              updatedAt: DateTime.parse(
                  novelData['updatedAt'] ?? DateTime.now().toIso8601String()),
              rating: (novelData['rating'] ?? 0).toDouble(),
              view: novelData['view'] ?? 0,
              followerCount: novelData['followerCount'] ?? 0,
              status: novelData['status'] ?? 'Đang cập nhật',
              userId: novelData['userId'] ?? 0,
            );

            updatedHistory.add(ReadingHistory(
              novel: updatedNovel,
              lastChapter: item.lastChapter,
            ));
          } else {
            updatedHistory.add(item);
          }
        }

        // Cập nhật số chương
        final chaptersResponse = await http.get(
          Uri.parse('${dotenv.get('API_URL')}/chapters'),
        );

        if (chaptersResponse.statusCode == 200) {
          final List<dynamic> chaptersData = json.decode(chaptersResponse.body);
          final Map<String, int> newChapterCounts = {};

          for (var item in updatedHistory) {
            final count = chaptersData
                .where((chapter) =>
                    chapter['novelId'].toString() == item.novel.id.toString())
                .length;
            newChapterCounts[item.novel.id.toString()] = count;
          }

          if (mounted) {
            setState(() {
              history = updatedHistory;
              chapterCounts = newChapterCounts;
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading history: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đọc truyện'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B3A57)
            : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadHistory();
        },
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : history.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có lịch sử đọc truyện',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 80,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.39,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return _buildHistoryItem(context, item);
                        },
                      ),
                      if (history.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: FloatingActionButton(
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.delete_sweep),
                              onPressed: () => _showClearHistoryDialog(context),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ReadingHistory item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NovelDetailScreen(novel: item.novel),
            ),
          ).then((_) => loadHistory());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.7,
              child: Image.network(
                item.novel.cover,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.novel.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tác giả: ${item.novel.author}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.lastChapter != null) ...[
                      Text(
                        'Đang đọc: ${item.lastChapter!.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (item.lastChapter != null)
                          TextButton.icon(
                            icon: const Icon(
                              Icons.play_arrow,
                              size: 18,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              'Đọc tiếp',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            onPressed: () => _continueReading(context, item),
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Xóa khỏi lịch sử',
                          onPressed: () =>
                              _showDeleteConfirmDialog(context, item),
                        ),
                      ],
                    ),
                    _buildNovelStats(item),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNovelStats(ReadingHistory item) {
    return Wrap(
      spacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book, size: 14, color: Colors.grey),
            Text(
              ' ${chapterCounts[item.novel.id.toString()] ?? 0} ch.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 14, color: Colors.grey),
            Text(
              ' ${item.novel.followerCount}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _continueReading(
      BuildContext context, ReadingHistory item) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> chaptersData = json.decode(response.body);
        final novelChapters = chaptersData
            .where((chapter) => chapter['novelId'].toString() == item.novel.id)
            .map((json) => Chapter.fromJson(json))
            .toList();

        if (novelChapters.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có chương nào'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        novelChapters.sort((a, b) {
          try {
            final aNum = int.parse(a.name.replaceAll(RegExp(r'[^0-9]'), ''));
            final bNum = int.parse(b.name.replaceAll(RegExp(r'[^0-9]'), ''));
            return aNum.compareTo(bNum);
          } catch (e) {
            return a.name.compareTo(b.name);
          }
        });

        final currentIndex =
            novelChapters.indexWhere((ch) => ch.id == item.lastChapter!.id);

        if (currentIndex != -1) {
          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterDetailScreen(
                novel: item.novel,
                chapter: novelChapters[currentIndex],
                currentIndex: currentIndex,
                allChapters: novelChapters,
              ),
            ),
          );
          if (mounted) {
            loadHistory();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy chương đang đọc'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception(
            'Không thể tải danh sách chương: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading chapters: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi tải chương'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, ReadingHistory item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa truyện "${item.novel.name}" khỏi lịch sử đọc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ReadingHistoryService.removeFromHistory(item.novel.id);
      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${item.novel.name}" khỏi lịch sử'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () async {
              await ReadingHistoryService.addToHistory(
                item.novel,
                lastChapter: item.lastChapter,
              );
              setState(() {});
            },
          ),
        ),
      );
    }
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Xóa toàn bộ lịch sử đọc truyện?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final oldHistory = List<ReadingHistory>.from(history);
              await ReadingHistoryService.clearHistory();
              Navigator.pop(context);
              setState(() {});

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa toàn bộ lịch sử'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Hoàn tác',
                    onPressed: () async {
                      for (var item in oldHistory.reversed) {
                        await ReadingHistoryService.addToHistory(
                          item.novel,
                          lastChapter: item.lastChapter,
                        );
                      }
                      setState(() {});
                    },
                  ),
                ),
              );
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
