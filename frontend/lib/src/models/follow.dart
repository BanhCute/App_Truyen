class Follow {
  final String id;
  final String userId;
  final String novelId;
  final DateTime createdAt;

  Follow({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'],
      userId: json['userId'],
      novelId: json['novelId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
