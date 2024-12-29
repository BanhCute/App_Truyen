import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/session_cubit.dart';

import '../../../models/rating.dart';
import '../../../services/rating_service.dart';

class RatingSection extends StatefulWidget {
  final String novelId;

  const RatingSection({
    super.key,
    required this.novelId,
  });

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  List<Rating> _ratings = [];
  bool _isLoading = true;
  Rating? _userRating;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final ratings = await RatingService.getNovelRatings(widget.novelId);
      final average = await RatingService.getAverageRating(widget.novelId);

      if (mounted) {
        setState(() {
          _ratings = ratings;
          _averageRating = average;
          _isLoading = false;

          // Tìm đánh giá của người dùng hiện tại
          final state = context.read<SessionCubit>().state;
          if (state is Authenticated) {
            _userRating = ratings.firstWhere(
              (rating) => rating.userId == state.session.user.id,
              orElse: () => Rating(
                id: -1,
                novelId: int.parse(widget.novelId),
                userId: state.session.user.id,
                content: '',
                score: 5.0,
                createdAt: DateTime.now(),
              ),
            );
          }
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

  void _showRatingDialog({Rating? existingRating}) {
    final state = context.read<SessionCubit>().state;
    if (state is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
      );
      return;
    }

    double selectedScore = existingRating?.score ?? 5;
    final contentController =
        TextEditingController(text: existingRating?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title:
              Text(existingRating == null ? 'Đánh giá truyện' : 'Sửa đánh giá'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedScore = index + 1;
                              });
                            },
                            child: Icon(
                              index < selectedScore
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nhận xét',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (existingRating != null && existingRating.id != -1) {
                    await RatingService.updateRating(
                      widget.novelId,
                      existingRating.id.toString(),
                      selectedScore,
                      contentController.text,
                    );
                  } else {
                    await RatingService.rateNovel(
                      widget.novelId,
                      selectedScore,
                      contentController.text,
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    _loadRatings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            existingRating?.id == -1 || existingRating == null
                                ? 'Đã đánh giá truyện'
                                : 'Đã cập nhật đánh giá'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().contains('Cannot PATCH')
                            ? 'Không thể cập nhật đánh giá. Vui lòng thử lại sau.'
                            : e.toString()),
                      ),
                    );
                  }
                }
              },
              child: Text(existingRating?.id == -1 || existingRating == null
                  ? 'Đánh giá'
                  : 'Cập nhật'),
            ),
          ],
        ),
      ),
    );
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
                          ' (${_ratings.length} đánh giá)',
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
                          _showRatingDialog(existingRating: _userRating),
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
          const Center(child: Text('Chưa có đánh giá nào'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ratings.length,
            itemBuilder: (context, index) {
              final rating = _ratings[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    rating.user?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                  ),
                ),
                title: Row(
                  children: [
                    Text(rating.user?['name'] ?? 'Người dùng'),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < rating.score
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rating.content),
                    Text(
                      '${rating.createdAt.day}/${rating.createdAt.month}/${rating.createdAt.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
