import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../models/comment.dart';
import '../../services/follow_service.dart';
import '../../services/comment_service.dart';
import '../../../bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/reading_history_service.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Novel novel;
  final Chapter chapter;
  final int currentIndex;
  final List<Chapter> allChapters;

  const ChapterDetailScreen({
    required this.novel,
    required this.chapter,
    required this.currentIndex,
    required this.allChapters,
    super.key,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  bool _showControls = true;
  bool _isFollowing = false;
  List<Comment> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
    _loadComments();
    ReadingHistoryService.addToHistory(widget.novel,
        lastChapter: widget.chapter);
  }

  Future<void> _loadFollowStatus() async {
    try {
      final isFollowing = await FollowService.isFollowing(widget.novel.id);
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    try {
      if (_isFollowing) {
        await FollowService.unfollowNovel(widget.novel.id);
      } else {
        await FollowService.followNovel(widget.novel.id);
      }
      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isFollowing ? 'Đã theo dõi truyện' : 'Đã bỏ theo dõi truyện'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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

  Future<void> _loadComments() async {
    try {
      final comments =
          await CommentService.getChapterComments(widget.chapter.id);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final comment = await CommentService.addComment(
        widget.chapter.id,
        _commentController.text.trim(),
      );
      setState(() {
        _comments.add(comment);
        _commentController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thêm bình luận. Vui lòng thử lại sau.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nội dung chapter
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Container(
                color: Colors.black,
                child: ListView.builder(
                  itemCount: widget.chapter.content.split('\n').length,
                  itemBuilder: (context, index) {
                    final imageUrl = widget.chapter.content.split('\n')[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 1),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Không thể tải ảnh',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Controls overlay
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: SafeArea(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            widget.chapter.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        BlocBuilder<SessionCubit, SessionState>(
                          builder: (context, state) {
                            return IconButton(
                              icon: Icon(
                                _isFollowing
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFollowing ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                if (state is Authenticated) {
                                  _toggleFollow();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Vui lòng đăng nhập để theo dõi truyện'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.list, color: Colors.white),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => ChapterListBottomSheet(
                                novel: widget.novel,
                                currentChapterIndex: widget.currentIndex,
                                allChapters: widget.allChapters,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget hiển thị danh sách chapter
class ChapterListBottomSheet extends StatelessWidget {
  final Novel novel;
  final int currentChapterIndex;
  final List<Chapter> allChapters;

  const ChapterListBottomSheet({
    super.key,
    required this.novel,
    required this.currentChapterIndex,
    required this.allChapters,
  });

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
              itemCount: allChapters.length,
              itemBuilder: (context, index) {
                final chapter = allChapters[index];
                return ListTile(
                  title: Text(
                    'Chương ${index + 1}: ${chapter.name}',
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
                            novel: novel,
                            chapter: chapter,
                            currentIndex: index,
                            allChapters: allChapters,
                          ),
                        ),
                      );
                      // Cập nhật lịch sử đọc khi chọn chương từ danh sách
                      ReadingHistoryService.addToHistory(
                        novel,
                        lastChapter: chapter,
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

// Widget hiển thị danh sách bình luận
class CommentBottomSheet extends StatelessWidget {
  final List<Comment> comments;
  final bool isLoading;
  final TextEditingController commentController;
  final VoidCallback onSubmit;

  const CommentBottomSheet({
    super.key,
    required this.comments,
    required this.isLoading,
    required this.commentController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bình luận',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                      ? const Center(child: Text('Chưa có bình luận nào'))
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                              title: Text(comment.userName ?? 'Người dùng'),
                              subtitle: Text(comment.content),
                              trailing: Text(
                                '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Viết bình luận...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
