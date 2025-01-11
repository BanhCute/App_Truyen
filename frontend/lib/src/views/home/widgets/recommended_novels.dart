import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../models/novel.dart';
import '../../novel_detail/novel_detail_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RecommendedNovels extends StatefulWidget {
  final List<Novel> novels;

  const RecommendedNovels({super.key, required this.novels});

  @override
  State<RecommendedNovels> createState() => _RecommendedNovelsState();
}

class _RecommendedNovelsState extends State<RecommendedNovels> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  Map<String, int> chapterCounts = {};
  Map<String, double> ratings = {};
  Map<String, int> ratingCounts = {};

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadNovelData();
  }

  Future<void> _loadNovelData() async {
    try {
      // Load chapters
      final chaptersResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
      );

      if (chaptersResponse.statusCode == 200) {
        final List<dynamic> chaptersData = json.decode(chaptersResponse.body);

        // Đếm số chương cho mỗi novel
        for (var novel in widget.novels) {
          final count = chaptersData
              .where((chapter) =>
                  chapter['novelId'].toString() == novel.id.toString())
              .length;
          chapterCounts[novel.id.toString()] = count;
        }
      }

      // Load ratings
      final ratingsResponse = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/ratings'),
      );

      if (ratingsResponse.statusCode == 200) {
        final ratingsData = json.decode(ratingsResponse.body);
        final List<dynamic> ratingsList = ratingsData['items'];

        // Tính rating trung bình cho mỗi novel
        for (var novel in widget.novels) {
          final novelRatings = ratingsList
              .where((r) => r['novelId'].toString() == novel.id.toString())
              .toList();

          if (novelRatings.isNotEmpty) {
            final sum = novelRatings.fold(
                0.0, (prev, curr) => prev + (curr['score'] ?? 0));
            ratings[novel.id.toString()] = sum / novelRatings.length;
            ratingCounts[novel.id.toString()] = novelRatings.length;
          } else {
            ratings[novel.id.toString()] = 0.0;
            ratingCounts[novel.id.toString()] = 0;
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading novel data: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < widget.novels.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Đề xuất cho bạn',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.novels.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: _buildNovelCard(widget.novels[index]),
                  );
                },
              ),
            ),
            // Nút điều hướng
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút trái
                  GestureDetector(
                    onTap: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  // Nút phải
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < widget.novels.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Center(
          child: SmoothPageIndicator(
            controller: _pageController,
            count: widget.novels.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
              activeDotColor: Theme.of(context).primaryColor,
              dotColor: Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNovelCard(Novel novel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NovelDetailScreen(novel: novel),
          ),
        );
      },
      child: Container(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'novel_cover_${novel.id}',
              child: Container(
                height: 280,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    novel.cover,
                    width: 180,
                    height: 280,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ratings[novel.id.toString()]?.toStringAsFixed(1) ?? "0.0"}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        ' (${ratingCounts[novel.id.toString()] ?? 0})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book,
                              size: 14, color: Colors.grey),
                          Text(
                            ' ${chapterCounts[novel.id.toString()] ?? 0} ch.',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye,
                              size: 14, color: Colors.grey),
                          Text(
                            ' ${novel.view}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite,
                              size: 14, color: Colors.grey),
                          Text(
                            ' ${novel.followerCount}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
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
