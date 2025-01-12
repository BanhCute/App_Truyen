import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/novel.dart';
import '../../novel_detail/novel_detail_screen.dart';

class RecentNovels extends StatefulWidget {
  final List<Novel> novels;

  const RecentNovels({
    super.key,
    required this.novels,
  });

  @override
  State<RecentNovels> createState() => _RecentNovelsState();
}

class _RecentNovelsState extends State<RecentNovels> {
  Map<String, int> chapterCounts = {};
  Map<String, double> ratings = {};
  Map<String, int> ratingCounts = {};
  String _selectedFilter = 'Mới cập nhật';

  final List<String> _filters = [
    'Mới cập nhật',
    'Đang tiến hành',
    'Hoàn thành',
    'Tạm ngưng',
    'Theo dõi nhiều nhất',
  ];

  @override
  void initState() {
    super.initState();
    _loadNovelData();
  }

  List<Novel> get filteredNovels {
    List<Novel> result = List.from(widget.novels);
    switch (_selectedFilter) {
      case 'Đang tiến hành':
        result =
            result.where((novel) => novel.status == 'Đang tiến hành').toList();
        break;
      case 'Hoàn thành':
        result = result.where((novel) => novel.status == 'Hoàn thành').toList();
        break;
      case 'Tạm ngưng':
        result = result.where((novel) => novel.status == 'Tạm ngưng').toList();
        break;

      case 'Theo dõi nhiều nhất':
        result.sort((a, b) => b.followerCount.compareTo(a.followerCount));
        break;
      default:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return result;
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Đảm bảo difference không âm
    if (difference.isNegative) {
      return 'Vừa xong';
    }

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Danh sách Truyện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      iconSize: 18,
                      isDense: true,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                      items: _filters
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filteredNovels.length,
          itemBuilder: (context, index) {
            final novel = filteredNovels[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovelDetailScreen(novel: novel),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh bìa truyện
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          novel.cover,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Thông tin truyện
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              novel.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tác giả: ${novel.author}',
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${chapterCounts[novel.id.toString()] ?? 0} chương',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${novel.followerCount}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ratings[novel.id.toString()]?.toStringAsFixed(1) ?? '0.0'} (${ratingCounts[novel.id.toString()] ?? 0})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _formatTimeAgo(novel.updatedAt),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(novel.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                novel.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(novel.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hoàn thành':
        return Colors.green;
      case 'Tạm ngưng':
        return Colors.red;
      case 'Đang tiến hành':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
