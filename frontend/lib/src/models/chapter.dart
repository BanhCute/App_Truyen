class Chapter {
  final int id;
  final String name;
  final String createdAt;
  final int novelId;

  Chapter({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.novelId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'],
      novelId: json['novelId'],
    );
  }
} 