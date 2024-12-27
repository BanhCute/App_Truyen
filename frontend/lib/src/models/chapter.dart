class Chapter {
  final String id;
  final String name;
  final String content;
  final String novelId;
  final DateTime createdAt;

  Chapter({
    required this.id,
    required this.name,
    required this.content,
    required this.novelId,
    required this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'].toString(),
      name: json['name'],
      content: json['content'],
      novelId: json['novelId'].toString(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'novelId': novelId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
