import 'novel.dart';

class Follow {
  final int id;
  final int userId;
  final int novelId;
  final DateTime createdAt;
  final Novel novel;

  Follow({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.createdAt,
    required this.novel,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'],
      userId: json['userId'],
      novelId: json['novelId'],
      createdAt: DateTime.parse(json['createdAt']),
      novel: Novel.fromJson(json['novel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'createdAt': createdAt.toIso8601String(),
      'novel': novel.toJson(),
    };
  }
}
