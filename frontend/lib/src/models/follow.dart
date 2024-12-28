import 'novel.dart';

class Follow {
  final int id;
  final int novelId;
  final int userId;
  final DateTime createdAt;

  Follow({
    required this.id,
    required this.novelId,
    required this.userId,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'],
      novelId: json['novelId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
