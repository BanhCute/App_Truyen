import 'package:flutter/material.dart';
import '../widgets/novel_search_bar.dart';
import '../widgets/recommended_novels.dart';
import '../widgets/recent_novels.dart';
import '../../../models/novel.dart';
import '../../../models/category.dart';

class HomeTab extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final List<Novel> filteredNovels;
  final List<Novel> recommendedNovels;
  final List<Novel> recentNovels;
  final Function(String) onSearch;
  final Function(Category?) onCategorySelected;
  final Future<void> Function() onRefresh;

  const HomeTab({
    super.key,
    required this.searchController,
    required this.isSearching,
    required this.filteredNovels,
    required this.recommendedNovels,
    required this.recentNovels,
    required this.onSearch,
    required this.onCategorySelected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            NovelSearchBar(
              searchController: searchController,
              isSearching: isSearching,
              filteredNovels: filteredNovels,
              onSearch: onSearch,
              onCategorySelected: onCategorySelected,
            ),
            RecommendedNovels(novels: recommendedNovels),
            RecentNovels(novels: recentNovels),
          ],
        ),
      ),
    );
  }
}
