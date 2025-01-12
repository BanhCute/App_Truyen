import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../services/follow_service.dart';
import '../../../bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/reading_history_service.dart';

import '../novel_detail/novel_detail_screen.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Novel novel;
  final Chapter chapter;
  final int currentIndex;
  final List<Chapter> allChapters;

  const ChapterDetailScreen({
    super.key,
    required this.novel,
    required this.chapter,
    required this.currentIndex,
    required this.allChapters,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  bool _isFollowing = false;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
    _saveReadingHistory();
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

  Future<void> _reloadChapter() async {
    try {
      if (mounted) {
        setState(() {
          _isReloading = true;
        });
      }
      // Simulate a reload operation
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isReloading = false;
        });
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

  Future<void> _saveReadingHistory() async {
    try {
      await ReadingHistoryService.addToHistory(
        widget.novel,
        lastChapter: widget.chapter,
      );
    } catch (e) {
      print('Error saving reading history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A57),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.novel.name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            Text(
              widget.chapter.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Nút reload
          IconButton(
            icon: _isReloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
            tooltip: 'Tải lại chương',
            onPressed: _isReloading ? null : _reloadChapter,
          ),
          BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  _isFollowing ? Icons.favorite : Icons.favorite_border,
                  color: _isFollowing ? Colors.red : Colors.white,
                ),
                tooltip: 'Theo dõi truyện',
                onPressed: () {
                  if (state is Authenticated) {
                    _toggleFollow();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng đăng nhập để theo dõi truyện'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            tooltip: 'Chi tiết truyện',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NovelDetailScreen(novel: widget.novel),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Nội dung chương
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.chapter.content.split('\n').map((imageUrl) {
                  if (imageUrl.trim().isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(
                                'Không thể tải hình ảnh',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF1B3A57),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Thanh điều hướng
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút chương trước
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.currentIndex > 0
                          ? () => _navigateToChapter(
                              context, widget.currentIndex - 1)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Chương trước'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A57),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nút chọn chương
                  ElevatedButton(
                    onPressed: () => _showChapterList(context),
                    child: const Icon(Icons.list),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3A57),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nút chương sau
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          widget.currentIndex < widget.allChapters.length - 1
                              ? () => _navigateToChapter(
                                  context, widget.currentIndex + 1)
                              : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Chương sau'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A57),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChapter(BuildContext context, int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterDetailScreen(
          novel: widget.novel,
          chapter: widget.allChapters[index],
          currentIndex: index,
          allChapters: widget.allChapters,
        ),
      ),
    );
  }

  void _showChapterList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách chương',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.allChapters.length,
                itemBuilder: (context, index) {
                  final isCurrentChapter = index == widget.currentIndex;
                  return ListTile(
                    title: Text(
                      widget.allChapters[index].name,
                      style: TextStyle(
                        color: isCurrentChapter
                            ? Theme.of(context).primaryColor
                            : null,
                        fontWeight: isCurrentChapter ? FontWeight.bold : null,
                      ),
                    ),
                    leading: isCurrentChapter
                        ? Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (!isCurrentChapter) {
                        _navigateToChapter(context, index);
                      }
                    },
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
