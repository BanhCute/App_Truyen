import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../services/reading_history_service.dart';

class NovelDetailScreen extends StatefulWidget {
  final Novel novel;

  const NovelDetailScreen({Key? key, required this.novel}) : super(key: key);

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  List<Chapter> chapters = [];
  List<String> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    // Lưu vào lịch sử khi xem chi tiết
    ReadingHistoryService.addToHistory(widget.novel);
  }

  Future<void> loadData() async {
    try {
      // Load chapters
      final chaptersResponse = await http
          .get(Uri.parse('${dotenv.get('API_URL')}/chapters'));
      final List chaptersData = json.decode(chaptersResponse.body);
      final allChapters =
          chaptersData.map((json) => Chapter.fromJson(json)).toList();

      // Filter chapters for this novel
      chapters = allChapters
          .where((chapter) => chapter.novelId == widget.novel.id)
          .toList();
      chapters.sort((a, b) => int.parse(a.name).compareTo(int.parse(b.name)));

      // Load categories
      final categoriesResponse = await http.get(
          Uri.parse('${dotenv.get('API_URL')}/categories'));
      final List categoriesData = json.decode(categoriesResponse.body);
      categories = categoriesData.map((cat) => cat['name'].toString()).toList();

      if (mounted)
        setState(() {
          isLoading = false;
        });
    } catch (e) {
      print('Error loading data: $e');
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B3A57) // Màu nền tối
          : Colors.white, // Màu nền sáng
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // App Bar với ảnh bìa
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1B3A57)
                          : Colors.white,
                  iconTheme: IconThemeData(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      widget.novel.cover,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Thông tin truyện
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.novel.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tác giả: ${widget.novel.author}',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Text(
                              ' ${widget.novel.rating}',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.remove_red_eye, size: 20),
                            Text(
                              ' ${widget.novel.view}',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.favorite, color: Colors.red, size: 20),
                            Text(
                              ' ${widget.novel.followerCount}',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thể loại:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: categories
                              .map((category) => Chip(
                                    label: Text(
                                      category,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Giới thiệu:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                        ),
                        Text(
                          widget.novel.description,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Danh sách chương:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Danh sách chương
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = chapters[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            'Chương ${chapter.name}',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          onTap: () {
                            // TODO: Navigate to chapter detail
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: Colors.transparent,
                          hoverColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                        ),
                      );
                    },
                    childCount: chapters.length,
                  ),
                ),
              ],
            ),
    );
  }
}
