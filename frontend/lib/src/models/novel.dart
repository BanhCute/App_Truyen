import 'chapter.dart';

class NovelCategory {
  final int id;
  final String name;
  final String? description;

  NovelCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory NovelCategory.fromJson(Map<String, dynamic> json) {
    // Kiểm tra nếu json có chứa 'category'
    if (json['category'] is Map<String, dynamic>) {
      final categoryData = json['category'] as Map<String, dynamic>;
      return NovelCategory(
        id: categoryData['id'] as int? ?? 0,
        name: categoryData['name']?.toString() ?? '',
        description: categoryData['description']?.toString(),
      );
    }
    // Nếu json là category trực tiếp
    return NovelCategory(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Novel {
  final String id;
  final String name;
  final String description;
  final String author;
  final String cover;
  final List<NovelCategory> categories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int view;
  final int followerCount;
  final String status;
  final int userId;
  final List<Chapter>? chapters;

  Novel({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.cover,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.rating = 0,
    this.view = 0,
    this.followerCount = 0,
    this.status = 'Đang cập nhật',
    this.chapters,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    // Parse categories from the nested structure
    final categoryList = (json['categories'] as List?)
            ?.map((cat) => NovelCategory.fromJson(cat))
            .toList() ??
        [];

    return Novel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      cover: json['cover'] ?? '',
      categories: categoryList,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      rating: (json['rating'] ?? 0).toDouble(),
      view: json['view'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      status: json['status'] ?? 'Đang cập nhật',
      userId: json['userId'] ?? 0,
      chapters: json['chapters'] != null
          ? (json['chapters'] as List)
              .map((chapter) => Chapter.fromJson(chapter))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'cover': cover,
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rating': rating,
      'view': view,
      'followerCount': followerCount,
      'status': status,
      'userId': userId,
      'chapters': chapters?.map((chapter) => chapter.toJson()).toList(),
    };
  }

  Novel copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    String? cover,
    List<NovelCategory>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? view,
    int? followerCount,
    String? status,
    int? userId,
    List<Chapter>? chapters,
  }) {
    return Novel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      cover: cover ?? this.cover,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      view: view ?? this.view,
      followerCount: followerCount ?? this.followerCount,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      chapters: chapters ?? this.chapters,
    );
  }
}
