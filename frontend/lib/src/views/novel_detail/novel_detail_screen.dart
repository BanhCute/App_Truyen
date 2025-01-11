import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/utils/time_ago.dart';

import 'dart:convert';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../services/reading_history_service.dart';
import '../../services/view_service.dart';
import '../details/chapter_detail_screen.dart';
import '../../services/follow_service.dart';
import '../admin/manage_novel_categories_screen.dart';
import 'widgets/rating_section.dart';
import '../../services/novel_service.dart';

class NovelDetailScreen extends StatefulWidget {
  final Novel novel;

  const NovelDetailScreen({super.key, required this.novel});

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  List<Chapter> chapters = [];
  List<String> categories = [];
  bool isLoading = true;
  bool isFollowing = false;
  late Novel novel;
  bool _isAuthor = false;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    novel = widget.novel;
    FollowService.initialize(context);
    _loadData();
    checkFollowStatus();
    ReadingHistoryService.addToHistory(novel);
    ViewService.incrementView(novel.id);
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
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để theo dõi truyện'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (isFollowing) {
        await FollowService.unfollowNovel(widget.novel.id);
      } else {
        await FollowService.followNovel(widget.novel.id);
      }

      // Cập nhật số lượt follow từ server
      await NovelService.updateFollowCount(widget.novel.id);

      // Lấy số follow mới
      final newFollowCount = await NovelService.getFollowCount(widget.novel.id);

      setState(() {
        isFollowing = !isFollowing;
        novel = novel.copyWith(
          followerCount: newFollowCount,
        );
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

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final novelResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/${widget.novel.id}'),
      );

      if (novelResponse.statusCode == 200) {
        final novelData = json.decode(novelResponse.body);
        print('Novel response: ${novelResponse.body}');
        print('Categories in response: ${novelData['categories']}');

        final state = context.read<SessionCubit>().state;

        setState(() {
          novel = Novel.fromJson(novelData);
          _isAuthor = state is Authenticated &&
              state.session.user.id.toString() == novel.userId;
        });

        // Debug log cho categories
        novel.categories.forEach((cat) {
          print('Category ID: ${cat.id}');
          print('Category name: ${cat.name}');
        });
      }

      final chaptersResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
      );

      if (chaptersResponse.statusCode == 200) {
        final List<dynamic> chaptersData = json.decode(chaptersResponse.body);
        setState(() {
          chapters = chaptersData
              .where((chapter) => chapter['novelId'].toString() == novel.id)
              .map((chapter) => Chapter.fromJson(chapter))
              .toList();

          // Sắp xếp chương theo số
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

        print('Chapters loaded: ${chapters.length}'); // Debug log
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

  Future<void> _manageCategories() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageNovelCategoriesScreen(novel: novel),
      ),
    );

    if (result == true) {
      _loadData(); // Reload data after categories are updated
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A57),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFollowing ? Icons.favorite : Icons.favorite_border,
              color: isFollowing ? Colors.red : Colors.white,
            ),
            onPressed: toggleFollow,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFF1B3A57),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'novel_cover_${novel.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            novel.cover,
                            width: 130,
                            height: 190,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 130,
                              height: 190,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              novel.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    novel.author,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  getTimeAgo(novel.updatedAt.toIso8601String()),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildStatItem(
                                    Icons.remove_red_eye, '${novel.view}'),
                                const SizedBox(width: 16),
                                _buildStatItem(
                                    Icons.favorite, '${novel.followerCount}'),
                                const SizedBox(width: 16),
                                _buildStatItem(Icons.star,
                                    novel.rating.toStringAsFixed(1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thể loại',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isAuthor)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _manageCategories,
                          tooltip: 'Quản lý thể loại',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: novel.categories.isEmpty
                        ? [const Chip(label: Text('Chưa có thể loại'))]
                        : novel.categories.map((category) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giới thiệu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showFullDescription
                              ? novel.description
                              : (novel.description.length > 200
                                  ? '${novel.description.substring(0, 200)}...'
                                  : novel.description),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        if (novel.description.length > 200) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showFullDescription = !_showFullDescription;
                              });
                            },
                            child: Text(
                              _showFullDescription ? 'Thu gọn' : 'Xem thêm',
                              style: const TextStyle(
                                color: const Color(0xFF1B3A57),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danh sách chương',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                            ),
                            Text(
                              'Tổng số: ${chapters.length} chương',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (chapters.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChapterDetailScreen(
                                        novel: novel,
                                        chapter: chapters.first,
                                        currentIndex: 0,
                                        allChapters: chapters,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Đọc từ đầu'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B3A57),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChapterDetailScreen(
                                        novel: novel,
                                        chapter: chapters.last,
                                        currentIndex: chapters.length - 1,
                                        allChapters: chapters,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.skip_next, size: 18),
                                label: const Text('Đọc mới nhất'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            chapter.name,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white54
                                    : Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                getTimeAgo(chapter.createdAt.toIso8601String()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
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
                        ),
                      );
                    },
                  ),
                  RatingSection(
                    novelId: widget.novel.id,
                    onRatingUpdated: () {
                      _loadData();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
