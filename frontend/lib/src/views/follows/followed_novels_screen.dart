import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../models/reading_history.dart';
import '../../services/follow_service.dart';
import '../../services/reading_history_service.dart';
import '../novel_detail/novel_detail_screen.dart';
import '../details/chapter_detail_screen.dart';

class FollowedNovelsScreen extends StatefulWidget {
  const FollowedNovelsScreen({super.key});

  @override
  State<FollowedNovelsScreen> createState() => _FollowedNovelsScreenState();
}

class _FollowedNovelsScreenState extends State<FollowedNovelsScreen> {
  List<Novel> novels = [];
  bool isLoading = true;
  Map<String, int> chapterCounts = {};

  @override
  void initState() {
    super.initState();
    FollowService.initialize(context);
    loadFollowedNovels();
  }

  Future<void> loadChapters() async {
    try {
      final chaptersResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
      );

      if (chaptersResponse.statusCode == 200) {
        final List<dynamic> chaptersData = json.decode(chaptersResponse.body);

        // Đếm số chương cho mỗi novel
        for (var novel in novels) {
          final count = chaptersData
              .where((chapter) =>
                  chapter['novelId'].toString() == novel.id.toString())
              .length;
          chapterCounts[novel.id.toString()] = count;
        }
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error loading chapters: $e');
    }
  }

  Future<void> loadFollowedNovels() async {
    try {
      final follows = await FollowService.getFollowedNovels();
      final novelIds = follows.map((f) => f.novelId.toString()).toList();

      if (novelIds.isNotEmpty) {
        final response = await http.get(
          Uri.parse('${dotenv.get('API_URL')}/novels'),
        );

        if (response.statusCode == 200) {
          final List<dynamic> allNovels = json.decode(response.body);
          final followedNovels = allNovels
              .where((novel) => novelIds.contains(novel['id'].toString()))
              .map((novel) => Novel.fromJson(novel))
              .toList();

          if (mounted) {
            setState(() {
              novels = followedNovels;
              isLoading = false;
            });
            loadChapters(); // Load số chương sau khi có danh sách truyện
          }
        } else {
          throw Exception('Không thể lấy thông tin truyện');
        }
      } else {
        if (mounted) {
          setState(() {
            novels = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading followed novels: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> unfollowNovel(String novelId) async {
    try {
      await FollowService.unfollowNovel(novelId);
      loadFollowedNovels();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã bỏ theo dõi truyện'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error unfollowing novel: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truyện đang theo dõi'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B3A57)
            : Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : novels.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Bạn chưa theo dõi truyện nào, nếu chưa đăng nhập thì vui lòng đăng nhập để theo dõi!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await loadFollowedNovels();
                  },
                  child: Stack(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.39,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: novels.length,
                        itemBuilder: (context, index) {
                          final novel = novels[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NovelDetailScreen(novel: novel),
                                  ),
                                ).then((_) => loadFollowedNovels());
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ảnh bìa truyện
                                  AspectRatio(
                                    aspectRatio: 0.7,
                                    child: Image.network(
                                      novel.cover,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            novel.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tác giả: ${novel.author}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          FutureBuilder<ReadingHistory?>(
                                            future: ReadingHistoryService
                                                .getLastRead(novel.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data?.lastChapter !=
                                                      null) {
                                                return Text(
                                                  'Đang đọc: ${snapshot.data!.lastChapter!.name}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              FutureBuilder<ReadingHistory?>(
                                                future: ReadingHistoryService
                                                    .getLastRead(novel.id),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data
                                                              ?.lastChapter !=
                                                          null) {
                                                    return Expanded(
                                                      child: TextButton.icon(
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
                                                        style: TextButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
                                                        ),
                                                        onPressed: () async {
                                                          try {
                                                            final response =
                                                                await http.get(
                                                              Uri.parse(
                                                                  '${dotenv.get('API_URL')}/chapters'),
                                                              headers: {
                                                                'Accept':
                                                                    'application/json',
                                                                'Content-Type':
                                                                    'application/json',
                                                              },
                                                            );

                                                            if (!mounted)
                                                              return;

                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              final List<
                                                                      dynamic>
                                                                  chaptersData =
                                                                  json.decode(
                                                                      response
                                                                          .body);

                                                              // Lọc chapters của novel hiện tại
                                                              final novelChapters = chaptersData
                                                                  .where((chapter) =>
                                                                      chapter['novelId']
                                                                          .toString() ==
                                                                      novel.id)
                                                                  .map((json) =>
                                                                      Chapter.fromJson(
                                                                          json))
                                                                  .toList();

                                                              if (novelChapters
                                                                  .isEmpty) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Không có chương nào'),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            2),
                                                                  ),
                                                                );
                                                                return;
                                                              }

                                                              // Sắp xếp chapters
                                                              novelChapters
                                                                  .sort((a, b) {
                                                                try {
                                                                  final aNum = int.parse(a
                                                                      .name
                                                                      .replaceAll(
                                                                          RegExp(
                                                                              r'[^0-9]'),
                                                                          ''));
                                                                  final bNum = int.parse(b
                                                                      .name
                                                                      .replaceAll(
                                                                          RegExp(
                                                                              r'[^0-9]'),
                                                                          ''));
                                                                  return aNum
                                                                      .compareTo(
                                                                          bNum);
                                                                } catch (e) {
                                                                  return a.name
                                                                      .compareTo(
                                                                          b.name);
                                                                }
                                                              });

                                                              final currentIndex =
                                                                  novelChapters.indexWhere((ch) =>
                                                                      ch.id ==
                                                                      snapshot
                                                                          .data!
                                                                          .lastChapter!
                                                                          .id);

                                                              if (currentIndex !=
                                                                  -1) {
                                                                if (!mounted)
                                                                  return;
                                                                await Navigator
                                                                    .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ChapterDetailScreen(
                                                                      novel:
                                                                          novel,
                                                                      chapter:
                                                                          novelChapters[
                                                                              currentIndex],
                                                                      currentIndex:
                                                                          currentIndex,
                                                                      allChapters:
                                                                          novelChapters,
                                                                    ),
                                                                  ),
                                                                );
                                                                if (mounted) {
                                                                  loadFollowedNovels();
                                                                }
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Không tìm thấy chương đang đọc'),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            2),
                                                                  ),
                                                                );
                                                              }
                                                            } else {
                                                              print(
                                                                  'Error response: ${response.statusCode} - ${response.body}');
                                                              throw Exception(
                                                                  'Không thể tải danh sách chương: ${response.statusCode}');
                                                            }
                                                          } catch (e) {
                                                            print(
                                                                'Error loading chapters: $e');
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Có lỗi xảy ra khi tải chương'),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox
                                                      .shrink();
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  size: 20,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                color: Colors.grey[700],
                                                tooltip: 'Bỏ theo dõi',
                                                onPressed: () {
                                                  unfollowNovel(novel.id);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                          'Đã bỏ theo dõi truyện'),
                                                      duration: const Duration(
                                                          seconds: 3),
                                                      action: SnackBarAction(
                                                        label: 'Hoàn tác',
                                                        onPressed: () async {
                                                          try {
                                                            await FollowService
                                                                .followNovel(
                                                                    novel.id);
                                                            loadFollowedNovels();
                                                          } catch (e) {
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(e
                                                                      .toString()
                                                                      .replaceAll(
                                                                          'Exception: ',
                                                                          '')),
                                                                  duration:
                                                                      const Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.menu_book,
                                                      size: 14,
                                                      color: Colors.grey),
                                                  Text(
                                                    ' ${chapterCounts[novel.id.toString()] ?? 0} ch.',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.remove_red_eye,
                                                      size: 14,
                                                      color: Colors.grey),
                                                  Text(
                                                    ' ${novel.view}',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.favorite,
                                                      size: 14,
                                                      color: Colors.grey),
                                                  Text(
                                                    ' ${novel.followerCount}',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (novels.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.delete_sweep),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xóa tất cả'),
                                  content: const Text(
                                      'Xóa tất cả truyện đang theo dõi?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final oldNovels =
                                            List<Novel>.from(novels);
                                        for (var novel in novels) {
                                          await FollowService.unfollowNovel(
                                              novel.id);
                                        }
                                        Navigator.pop(context);
                                        loadFollowedNovels();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Đã xóa tất cả truyện đang theo dõi'),
                                            duration:
                                                const Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'Hoàn tác',
                                              onPressed: () async {
                                                for (var novel
                                                    in oldNovels.reversed) {
                                                  await FollowService
                                                      .followNovel(novel.id);
                                                }
                                                loadFollowedNovels();
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
                            },
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
