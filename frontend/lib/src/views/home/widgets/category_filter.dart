import 'package:flutter/material.dart';
import '../../../models/novel.dart';

class CategoryFilter extends StatelessWidget {
  final List<NovelCategory> categories;
  final Function(NovelCategory) onCategorySelected;
  final List<NovelCategory> selectedCategories;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              selectedCategories.any((cat) => cat.id == category.id);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category.name,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                ),
              ),
              selected: isSelected,
              showCheckmark: true,
              checkmarkColor: Colors.white,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              selectedColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
