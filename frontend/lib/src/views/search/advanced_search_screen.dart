import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  List<Category> categories = [];
  Set<String> selectedGenres = {};
  String selectedCountry = 'Tất cả';
  String selectedStatus = 'Tất cả';
  String selectedSort = 'Ngày đăng giảm dần';
  String selectedChapterCount = '> 0';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
          Uri.parse('https://webtruyenfull.onrender.com/api/v1/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((json) => Category.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A57),
        title: const Text(
          'Tìm kiếm nâng cao',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thể loại truyện
            const Text(
              'Thể loại truyện',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: categories.map((category) {
                return FilterChip(
                  label: Text(category.name),
                  selected: selectedGenres.contains(category.name),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedGenres.add(category.name);
                      } else {
                        selectedGenres.remove(category.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Các dropdown
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quốc gia'),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCountry,
                        items: ['Tất cả', 'Nhật Bản', 'Trung Quốc', 'Hàn Quốc']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCountry = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tình trạng'),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedStatus,
                        items: [
                          'Tất cả',
                          'Đang tiến hành',
                          'Hoàn thành',
                          'Tạm ngưng'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Số lượng chương và Sắp xếp
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số lượng chương'),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedChapterCount,
                        items: [
                          '> 0',
                          '> 50',
                          '> 100',
                          '> 200',
                          '> 500',
                          '> 1000'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedChapterCount = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sắp xếp'),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedSort,
                        items: [
                          'Ngày đăng giảm dần',
                          'Ngày đăng tăng dần',
                          'Ngày cập nhật giảm dần',
                          'Ngày cập nhật tăng dần',
                          'Lượt xem giảm dần',
                          'Lượt xem tăng dần',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedSort = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nút tìm kiếm
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  // Xử lý tìm kiếm
                },
                child: Text(
                  'Tìm kiếm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Thêm class Category
class Category {
  final int id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
