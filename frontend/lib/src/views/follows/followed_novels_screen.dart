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

class FollowedNovelsScreen extends StatefulWidget {
  const FollowedNovelsScreen({Key? key}) : super(key: key);

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
      // Lấy danh sách follows
      final follows = await FollowService.getFollowedNovels();

      // Lấy thông tin novel cho mỗi follow
      final headers = await FollowService.getHeaders();
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels'),
        headers: headers,
      );

      print('Get novels response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List allNovels = json.decode(response.body);
        final followedNovels = allNovels
            .where((novel) => follows.any((f) => f.novelId == novel['id']))
            .map((json) => Novel.fromJson(json))
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
      // Reload danh sách sau khi unfollow
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
                              FutureBuilder<ReadingHistory?>(
                                future:
                                    ReadingHistoryService.getLastRead(novel.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data?.lastChapter != null) {
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
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
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
                                                duration:
                                                    const Duration(seconds: 2),
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
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NovelDetailScreen(novel: novel),
                              ),
                            ).then((_) =>
                                loadFollowedNovels()); // Reload sau khi quay lại
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
