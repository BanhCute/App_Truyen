class Rating {
  final int id;
  final int novelId;
  final int userId;
  final String content;
  final double score;
  final DateTime createdAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? novel;

  Rating({
    required this.id,
    required this.novelId,
    required this.userId,
    required this.content,
    required this.score,
    required this.createdAt,
    this.user,
    this.novel,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing rating JSON: $json');
      return Rating(
        id: json['id'],
        novelId: json['novelId'],
        userId: json['userId'] ?? -1,
        content: json['content'] ?? '',
        score: (json['score'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        user: json['user'] != null
            ? Map<String, dynamic>.from(json['user'])
            : null,
        novel: json['novel'] != null
            ? Map<String, dynamic>.from(json['novel'])
            : null,
      );
    } catch (e) {
      print('Error parsing rating: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  String get userName {
    if (user == null) return 'Người dùng';

    // Debug log
    print('User data in rating: $user');

    // Lấy thông tin từ user object
    final name = user!['name']?.toString();

    // Trả về tên nếu có
    if (name != null && name.isNotEmpty) return name;

    return 'Người dùng';
  }

  String get userAvatar {
    if (user == null) return 'U';

    // Lấy avatar từ user object
    final avatar = user!['avatar']?.toString();

    // Nếu có avatar thì trả về
    if (avatar != null && avatar.isNotEmpty) {
      return avatar;
    }

    // Nếu không có avatar thì lấy chữ cái đầu của tên
    final name = userName;
    if (name == 'Người dùng') return 'U';

    return name[0].toUpperCase();
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
      'novel': novel,
    };
  }
}
