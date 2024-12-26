class Novel {
  final int id;
  final String name;
  final String description;
  final String createdAt;
  final String cover;
  final String author;
  final String status;
  final int view;
  final String updatedAt;
  final int rating;
  final int followerCount;
  final int commentCount;
  final int userId;

  Novel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.cover,
    required this.author,
    required this.status,
    required this.view,
    required this.updatedAt,
    required this.rating,
    required this.followerCount,
    required this.commentCount,
    required this.userId,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'],
      cover: json['cover'],
      author: json['author'],
      status: json['status'],
      view: json['view'],
      updatedAt: json['updatedAt'],
      rating: json['rating'],
      followerCount: json['followerCount'],
      commentCount: json['commentCount'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'cover': cover,
      'author': author,
      'status': status,
      'view': view,
      'updatedAt': updatedAt,
      'rating': rating,
      'followerCount': followerCount,
      'commentCount': commentCount,
      'userId': userId,
    };
  }
}
