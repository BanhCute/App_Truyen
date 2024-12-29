import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../bloc/session_cubit.dart';
import '../../models/follow.dart';
import '../../models/novel.dart';
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

  @override
  void initState() {
    super.initState();
    FollowService.initialize(context);
    loadFollowedNovels();
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
                  child: Text('Bạn chưa theo dõi truyện nào'),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await loadFollowedNovels();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: novels.length,
                    itemBuilder: (context, index) {
                      final novel = novels[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                            title: Text(
                              novel.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tác giả: ${novel.author}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                FutureBuilder<ReadingHistory?>(
                                  future: ReadingHistoryService.getLastRead(
                                      novel.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data?.lastChapter != null) {
                                      final chapterName =
                                          snapshot.data!.lastChapter!.name;
                                      final chapterNumber =
                                          RegExp(r'Chương (\d+)')
                                                  .firstMatch(chapterName)
                                                  ?.group(1) ??
                                              chapterName;
                                      return Text(
                                        'Đang đọc: ${snapshot.data!.lastChapter!.name}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FutureBuilder<ReadingHistory?>(
                                  future: ReadingHistoryService.getLastRead(
                                      novel.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data?.lastChapter != null) {
                                      return IconButton(
                                        icon: const Icon(Icons.play_arrow),
                                        tooltip: 'Đọc tiếp',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChapterDetailScreen(
                                                novel: novel,
                                                chapter:
                                                    snapshot.data!.lastChapter!,
                                                currentIndex: novel.chapters
                                                        ?.indexWhere((c) =>
                                                            c.id ==
                                                            snapshot
                                                                .data!
                                                                .lastChapter!
                                                                .id) ??
                                                    0,
                                                allChapters:
                                                    novel.chapters ?? [],
                                              ),
                                            ),
                                          ).then((_) => loadFollowedNovels());
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.grey[700],
                                  tooltip: 'Bỏ theo dõi',
                                  onPressed: () {
                                    unfollowNovel(novel.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            const Text('Đã bỏ theo dõi truyện'),
                                        duration: const Duration(seconds: 3),
                                        action: SnackBarAction(
                                          label: 'Hoàn tác',
                                          onPressed: () async {
                                            try {
                                              await FollowService.followNovel(
                                                  novel.id);
                                              loadFollowedNovels();
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(e
                                                        .toString()
                                                        .replaceAll(
                                                            'Exception: ', '')),
                                                    duration: const Duration(
                                                        seconds: 2),
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NovelDetailScreen(novel: novel),
                                ),
                              ).then((_) => loadFollowedNovels());
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
