class Truyen {
  final String id;
  final String title;
  final String imageUrl;
  final bool isHot;
  final int totalChapters;
  final String updatedAt;
  final double rating;
  final String description;
  final List<Chapter> chapters;
  final int chapter;

  const Truyen({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.isHot = false,
    required this.totalChapters,
    required this.updatedAt,
    this.rating = 0.0,
    required this.description,
    required this.chapters,
    required this.chapter,
  });
}

class Chapter {
  final String id;
  final int number;
  final String title;
  final String content;
  final List<Comment> comments;
  final DateTime publishDate;

  const Chapter({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    required this.comments,
    required this.publishDate,
  });
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
  });
}
