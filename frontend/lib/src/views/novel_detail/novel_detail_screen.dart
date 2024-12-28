import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:frontend/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../services/reading_history_service.dart';
import '../admin/edit_chapter_screen.dart';
import '../details/chapter_detail_screen.dart';
import '../../services/follow_service.dart';
import '../admin/manage_novel_categories_screen.dart';
import '../admin/upload_chapter_screen.dart';

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
  bool isFollowing = false;
  late Novel novel;

  @override
  void initState() {
    super.initState();
    novel = widget.novel;
    FollowService.initialize(context);
    loadData();
    checkFollowStatus();
    ReadingHistoryService.addToHistory(novel);
  }

  Future<void> checkFollowStatus() async {
    try {
      final isFollowed = await FollowService.isFollowing(widget.novel.id);
      setState(() {
        isFollowing = isFollowed;
      });
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> toggleFollow() async {
    try {
      if (isFollowing) {
        await FollowService.unfollowNovel(widget.novel.id);
      } else {
        await FollowService.followNovel(widget.novel.id);
      }
      setState(() {
        isFollowing = !isFollowing;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isFollowing ? 'Đã theo dõi truyện' : 'Đã bỏ theo dõi truyện'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> loadData() async {
    try {
      // Load novel data
      final novelResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/${widget.novel.id}'),
      );

      if (novelResponse.statusCode == 200) {
        final novelData = json.decode(novelResponse.body);
        setState(() {
          novel = Novel.fromJson(novelData);
          categories = List<String>.from(novelData['categories'] ?? []);
        });
      }

      // Load chapters
      final chaptersResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
      );

      if (chaptersResponse.statusCode == 200) {
        final List chaptersData = json.decode(chaptersResponse.body);
        setState(() {
          chapters = chaptersData
              .where((chapter) => chapter['novelId'].toString() == novel.id)
              .map((json) => Chapter.fromJson(json))
              .toList();
          chapters.sort((a, b) {
            try {
              final aNum = int.parse(a.name.replaceAll(RegExp(r'[^0-9]'), ''));
              final bNum = int.parse(b.name.replaceAll(RegExp(r'[^0-9]'), ''));
              return aNum.compareTo(bNum);
            } catch (e) {
              print('Error sorting chapters: $e');
              return 0;
            }
          });
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      print('Error loading data: $e');
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
        title: Text(novel.name),
        backgroundColor: const Color(0xFF1B3A57),
        actions: [
          BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: Icon(
                    isFollowing ? Icons.favorite : Icons.favorite_border,
                    color: isFollowing ? Colors.red : Colors.white,
                  ),
                  onPressed: toggleFollow,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            novel.cover,
                            width: 120,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 120),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                novel.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tác giả: ${novel.author}',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  Text(
                                    ' ${novel.rating.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Giới thiệu:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                    ),
                    Text(
                      novel.description,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Danh sách chương:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              chapter.name,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChapterDetailScreen(
                                    novel: novel,
                                    chapter: chapter,
                                    currentIndex: index,
                                    allChapters: chapters,
                                  ),
                                ),
                              );
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
