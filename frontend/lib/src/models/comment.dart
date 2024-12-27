class Comment {
  final String id;
  final String userId;
  final String chapterId;
  final String content;
  final DateTime createdAt;
  final String? userName; // Tên người dùng bình luận

  Comment({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.content,
    required this.createdAt,
    this.userName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      chapterId: json['chapterId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'chapterId': chapterId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
    };
  }
}
