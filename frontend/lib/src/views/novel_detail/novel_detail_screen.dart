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

  @override
  void initState() {
    super.initState();
    FollowService.initialize(context);
    loadData();
    checkFollowStatus();
    ReadingHistoryService.addToHistory(widget.novel);
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
      // Load chapters
      final chaptersResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
      );

      if (chaptersResponse.statusCode == 200) {
        final List chaptersData = json.decode(chaptersResponse.body);
        print('All chapters: ${chaptersData.length}');
        print('Novel ID: ${widget.novel.id}');
        print(
            'Filtered chapters: ${chaptersData.where((chapter) => chapter['novelId'] == widget.novel.id).length}');

        setState(() {
          chapters = chaptersData
              .where(
                  (chapter) => chapter['novelId'].toString() == widget.novel.id)
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
        print('Final chapters count: ${chapters.length}');
      } else {
        throw Exception('Failed to load chapters');
      }

      // Load categories
      final categoriesResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/categories'),
      );

      if (categoriesResponse.statusCode == 200) {
        final List categoriesData = json.decode(categoriesResponse.body);
        setState(() {
          categories =
              categoriesData.map((cat) => cat['name'].toString()).toList();
        });
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
                  actions: [
                    IconButton(
                      icon: Icon(
                        isFollowing ? Icons.favorite : Icons.favorite_border,
                        color: isFollowing ? Colors.red : null,
                      ),
                      onPressed: () {
                        final state = context.read<SessionCubit>().state;
                        if (state is Authenticated) {
                          toggleFollow();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Vui lòng đăng nhập để theo dõi truyện'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
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
                            chapter.name,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          trailing: context.read<SessionCubit>().state
                                  is Authenticated
                              ? IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlocProvider.value(
                                          value: context.read<SessionCubit>(),
                                          child: EditChapterScreen(
                                              chapter: chapter),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterDetailScreen(
                                  novel: widget.novel,
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
                    childCount: chapters.length,
                  ),
                ),
              ],
            ),
    );
  }
}
