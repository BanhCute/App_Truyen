import 'package:flutter/material.dart';
import '../../../models/novel.dart';
import '../../../models/category.dart';
import '../../novel_detail/novel_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NovelSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final List<Novel> filteredNovels;
  final Function(String) onSearch;
  final Function(Category?)? onCategorySelected;

  const NovelSearchBar({
    super.key,
    required this.searchController,
    required this.isSearching,
    required this.filteredNovels,
    required this.onSearch,
    this.onCategorySelected,
  });

  @override
  State<NovelSearchBar> createState() => _NovelSearchBarState();
}

class _NovelSearchBarState extends State<NovelSearchBar> {
  Map<String, int> chapterCounts = {};
  Map<String, double> ratings = {};
  Map<String, int> ratingCounts = {};
  List<dynamic> categories = [];
  List<Category> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadNovelData();
    _loadCategories();
  }

  @override
  void didUpdateWidget(NovelSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filteredNovels != oldWidget.filteredNovels) {
      _loadNovelData();
    }
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
        for (var novel in widget.filteredNovels) {
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
        for (var novel in widget.filteredNovels) {
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

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/categories'),
      );

      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: widget.searchController,
              style: const TextStyle(
                color: Colors.black87,
              ),
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên truyện hoặc tác giả',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          widget.searchController.clear();
                          widget.onSearch('');
                        },
                      ),
                    Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (categories.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryId = category['id'] is String
                      ? int.parse(category['id'])
                      : category['id'];
                  final isSelected =
                      selectedCategories.any((cat) => cat.id == categoryId);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category['name'],
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          final newCategory = Category(
                            id: categoryId,
                            name: category['name'],
                            description: category['description'] ?? '',
                          );
                          if (selected) {
                            if (!selectedCategories
                                .any((cat) => cat.id == categoryId)) {
                              selectedCategories.add(newCategory);
                            }
                          } else {
                            selectedCategories
                                .removeWhere((cat) => cat.id == categoryId);
                          }
                          widget.onCategorySelected?.call(
                              selectedCategories.isNotEmpty
                                  ? selectedCategories.last
                                  : null);
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.grey[300],
                      checkmarkColor: Colors.black87,
                    ),
                  );
                },
              ),
            ),
          if (widget.isSearching)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: widget.filteredNovels
                    .map((novel) => InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NovelDetailScreen(novel: novel),
                              ),
                            );
                            widget.searchController.clear();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    novel.cover,
                                    width: 40,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        novel.name,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tác giả: ${novel.author}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    novel.status)[0],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                novel.status,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: _getStatusColor(
                                                      novel.status)[1],
                                                ),
                                              ),
                                            ),
                                            _buildInfoItem(
                                              Icons.star,
                                              '${ratings[novel.id.toString()]?.toStringAsFixed(1) ?? "0.0"} (${ratingCounts[novel.id.toString()] ?? 0})',
                                              Colors.amber,
                                              context,
                                            ),
                                            _buildInfoItem(
                                              Icons.menu_book,
                                              '${chapterCounts[novel.id.toString()] ?? 0} chương',
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]!
                                                  : Colors.grey[700]!,
                                              context,
                                            ),
                                            _buildInfoItem(
                                              Icons.favorite,
                                              '${novel.followerCount}',
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]!
                                                  : Colors.grey[700]!,
                                              context,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} năm trước';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} tháng trước';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} tuần trước';
    } else if (diff.inDays > 1) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 1) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 1) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa mới';
    }
  }

  Widget _buildInfoItem(
      IconData icon, String text, Color color, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        Text(
          ' $text',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Color> _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'hoàn thành' || statusLower == 'completed') {
      return [Colors.green[100]!, Colors.green[900]!];
    } else if (statusLower == 'tạm ngưng' || statusLower == 'paused') {
      return [Colors.red[100]!, Colors.red[900]!];
    }
    return [Colors.blue[100]!, Colors.blue[900]!];
  }
}
