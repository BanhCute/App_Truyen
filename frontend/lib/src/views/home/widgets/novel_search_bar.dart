import 'package:flutter/material.dart';
import '../../../models/novel.dart';
import '../../novel_detail/novel_detail_screen.dart';

class NovelSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final List<Novel> filteredNovels;
  final Function(String) onSearch;

  const NovelSearchBar({
    Key? key,
    required this.searchController,
    required this.isSearching,
    required this.filteredNovels,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Colors.white),
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên truyện hoặc tác giả',
                hintStyle: TextStyle(color: Colors.grey[300]),
                suffixIcon: Icon(Icons.search, color: Colors.grey[300]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).primaryColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (isSearching)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
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
                children: filteredNovels
                    .map((novel) => ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              novel.cover,
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          title: Text(
                            novel.name,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tác giả: ${novel.author}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  Text(
                                    ' ${novel.rating}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NovelDetailScreen(novel: novel),
                              ),
                            );
                            searchController.clear();
                          },
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
