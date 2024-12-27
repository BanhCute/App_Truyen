import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/session_cubit.dart';
import '../../models/follow.dart';
import '../../models/novel.dart';
import '../../services/follow_service.dart';
import '../novel_detail/novel_detail_screen.dart';

class FollowedNovelsScreen extends StatefulWidget {
  const FollowedNovelsScreen({Key? key}) : super(key: key);

  @override
  State<FollowedNovelsScreen> createState() => _FollowedNovelsScreenState();
}

class _FollowedNovelsScreenState extends State<FollowedNovelsScreen> {
  List<Follow> follows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FollowService.initialize(context);
    loadFollowedNovels();
  }

  Future<void> loadFollowedNovels() async {
    try {
      final followedNovels = await FollowService.getFollowedNovels();
      if (mounted) {
        setState(() {
          follows = followedNovels;
          isLoading = false;
        });
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
          : follows.isEmpty
              ? const Center(
                  child: Text('Bạn chưa theo dõi truyện nào'),
                )
              : ListView.builder(
                  itemCount: follows.length,
                  itemBuilder: (context, index) {
                    final follow = follows[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            follow.novel.cover,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        title: Text(follow.novel.name),
                        subtitle: Text('Tác giả: ${follow.novel.author}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => unfollowNovel(follow.novel.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NovelDetailScreen(novel: follow.novel),
                            ),
                          ).then((_) =>
                              loadFollowedNovels()); // Reload sau khi quay lại
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
