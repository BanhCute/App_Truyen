import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/session_cubit.dart';

import '../../../models/rating.dart';
import '../../../services/rating_service.dart';

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
      final ratings = await RatingService.getNovelRatings(widget.novelId);

      if (mounted) {
        setState(() {
          _ratings = ratings;

          if (_ratings.isNotEmpty) {
            _averageRating =
                _ratings.map((r) => r.score).reduce((a, b) => a + b) /
                    _ratings.length;
          }

          // Tìm đánh giá của người dùng hiện tại
          if (_sessionState is Authenticated) {
            _userRating = _ratings.firstWhere(
              (rating) =>
                  rating.userId ==
                  (_sessionState as Authenticated).session.user.id,
              orElse: () => Rating(
                id: -1,
                novelId: int.parse(widget.novelId),
                userId: (_sessionState as Authenticated).session.user.id,
                content: '',
                score: 5.0,
                createdAt: DateTime.now(),
              ),
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

  void _showRatingDialog({Rating? existingRating}) {
    if (_sessionState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
      );
      return;
    }

    double selectedScore = existingRating?.score ?? 5;
    String content = existingRating?.content ?? '';
    final contentController = TextEditingController(text: content);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              Text(_userRating?.id == -1 ? 'Đánh giá truyện' : 'Sửa đánh giá'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
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
                              setState(() {
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
                  onChanged: (value) {
                    content = value;
                  },
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (content.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập nhận xét')),
                  );
                  return;
                }

                try {
                  Navigator.of(dialogContext).pop();

                  if (_userRating != null && _userRating!.id != -1) {
                    await RatingService.updateRating(
                      widget.novelId,
                      _userRating!.id.toString(),
                      selectedScore,
                      content.trim(),
                    );
                  } else {
                    await RatingService.rateNovel(
                      widget.novelId,
                      selectedScore,
                      content.trim(),
                    );
                  }

                  if (!mounted) return;

                  await _loadRatings();
                  if (widget.onRatingUpdated != null) {
                    widget.onRatingUpdated!();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_userRating?.id == -1
                          ? 'Đã đánh giá truyện'
                          : 'Đã cập nhật đánh giá'),
                    ),
                  );
                } catch (e) {
                  print('Error in rating dialog: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              },
              child: Text(_userRating?.id == -1 ? 'Đánh giá' : 'Cập nhật'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      contentController.dispose();
    });
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('Chưa có đánh giá nào')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ratings.length,
            itemBuilder: (context, index) {
              final rating = _ratings[index];
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
                            backgroundColor: Colors.blue,
                            child: Text(
                              rating.userAvatar,
                              style: const TextStyle(color: Colors.white),
                            ),
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
                                  ),
                                ),
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
                          ),
                          Text(
                            '${rating.createdAt.add(const Duration(hours: 7)).hour}:${rating.createdAt.add(const Duration(hours: 7)).minute.toString().padLeft(2, '0')} ${rating.createdAt.add(const Duration(hours: 7)).day}/${rating.createdAt.add(const Duration(hours: 7)).month}/${rating.createdAt.add(const Duration(hours: 7)).year}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(rating.content),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
