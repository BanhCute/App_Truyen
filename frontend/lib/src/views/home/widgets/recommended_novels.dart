import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../../models/novel.dart';
import '../../novel_detail/novel_detail_screen.dart';

class RecommendedNovels extends StatelessWidget {
  final List<Novel> novels;

  const RecommendedNovels({
    super.key,
    required this.novels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Đề Xuất',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Swiper(
              itemCount: novels.length,
              autoplay: true,
              autoplayDelay: 3000,
              viewportFraction: 0.85,
              scale: 0.95,
              pagination: const SwiperPagination(),
              itemBuilder: (context, index) {
                final novel = novels[index];
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
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            novel.cover,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  novel.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Đánh giá: ${novel.rating}⭐',
                                  
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
