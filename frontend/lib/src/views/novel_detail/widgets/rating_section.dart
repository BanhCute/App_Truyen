import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/session_cubit.dart';

import '../../../models/rating.dart';
import '../../../services/rating_service.dart';
import 'rating_dialog.dart';

class RatingSection extends StatefulWidget {
  final String novelId;
  final Function? onRatingUpdated;

  const RatingSection({
    Key? key,
    required this.novelId,
    this.onRatingUpdated,
  }) : super(key: key);

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  List<Rating> _ratings = [];
  bool _isLoading = true;
  Rating? _userRating;
  double _averageRating = 0;
  late SessionState _sessionState;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRatings = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _sessionState = context.read<SessionCubit>().state;
    _loadRatings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionState = context.read<SessionCubit>().state;
  }

  Future<void> _loadRatings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RatingService.getNovelRatings(
        widget.novelId,
        page: _currentPage,
        limit: _pageSize,
      );

      final ratings = result['items'] as List<Rating>;
      final meta = result['meta'] as Map<String, dynamic>;

      print('Loaded ${ratings.length} ratings for novel ${widget.novelId}');

      if (mounted) {
        setState(() {
          _ratings = ratings;
          _totalPages = meta['totalPages'] as int;
          _totalRatings = meta['total'] as int;

          if (_ratings.isNotEmpty) {
            _averageRating =
                _ratings.map((r) => r.score).reduce((a, b) => a + b) /
                    _ratings.length;
          }

          // Tìm đánh giá của người dùng hiện tại
          if (_sessionState is Authenticated) {
            final userId = (_sessionState as Authenticated).session.user.id;
            print('Current user ID: $userId');

            _userRating = _ratings.firstWhere(
              (rating) =>
                  rating.userId == userId &&
                  rating.novelId == int.parse(widget.novelId),
              orElse: () {
                print(
                    'No rating found for user $userId and novel ${widget.novelId}');
                return Rating(
                  id: -1,
                  novelId: int.parse(widget.novelId),
                  userId: userId,
                  content: '',
                  score: 5.0,
                  createdAt: DateTime.now(),
                );
              },
            );
            print('Found user rating: ${_userRating?.id}');
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading ratings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changePage(int page) {
    if (page != _currentPage && page > 0 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
      _loadRatings();
    }
  }

  Future<void> _handleRating({Rating? existingRating}) async {
    if (_sessionState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => RatingDialog(
        initialRating: existingRating?.score ?? 5,
        initialContent: existingRating?.content ?? '',
        isUpdate: existingRating?.id != -1,
      ),
    );

    if (result != null && mounted) {
      try {
        if (existingRating?.id != -1) {
          await RatingService.updateRating(
            widget.novelId,
            existingRating!.id.toString(),
            result['rating'],
            result['content'],
          );
        } else {
          await RatingService.rateNovel(
            widget.novelId,
            result['rating'],
            result['content'],
          );
        }

        await _loadRatings();
        if (widget.onRatingUpdated != null) {
          widget.onRatingUpdated!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(existingRating?.id == -1
                  ? 'Đã đánh giá truyện'
                  : 'Đã cập nhật đánh giá'),
            ),
          );
        }
      } catch (e) {
        print('Error handling rating: $e');
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh giá',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isLoading)
                    Row(
                      children: [
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.amber),
                        Text(
                          ' ($_totalRatings đánh giá)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
              BlocBuilder<SessionCubit, SessionState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return ElevatedButton(
                      onPressed: () =>
                          _handleRating(existingRating: _userRating),
                      child: Text(
                          _userRating?.id == -1 ? 'Đánh giá' : 'Sửa đánh giá'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_ratings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('Chưa có đánh giá nào')),
          )
        else
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ratings.length,
                itemBuilder: (context, index) {
                  final rating = _ratings[index];
                  return RatingItem(rating: rating);
                },
              ),
              if (_totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1
                            ? () => _changePage(_currentPage - 1)
                            : null,
                      ),
                      Text('$_currentPage/$_totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < _totalPages
                            ? () => _changePage(_currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class RatingItem extends StatelessWidget {
  final Rating rating;

  const RatingItem({
    Key? key,
    required this.rating,
  }) : super(key: key);

  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.add(const Duration(hours: 7));
    return '${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')} ${localTime.day}/${localTime.month}/${localTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(rating.userAvatar),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDateTime(rating.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      rating.score.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
              ],
            ),
            if (rating.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                rating.content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
