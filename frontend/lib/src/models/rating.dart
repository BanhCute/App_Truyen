class Rating {
  final int id;
  final int novelId;
  final int userId;
  final String content;
  final double score;
  final DateTime createdAt;
  final Map<String, dynamic>? user;

  Rating({
    required this.id,
    required this.novelId,
    required this.userId,
    required this.content,
    required this.score,
    required this.createdAt,
    this.user,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      novelId: json['novelId'],
      userId: json['userId'],
      content: json['content'],
      score: (json['score'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'userId': userId,
      'content': content,
      'score': score,
      'createdAt': createdAt.toIso8601String(),
      'user': user,
    };
  }
}
