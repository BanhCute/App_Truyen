import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';

class CommentService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Lấy danh sách comment của một chapter
  static Future<List<Comment>> getChapterComments(String chapterId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('API_URL')}/comments?chapterId=$chapterId'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Không thể lấy danh sách bình luận');
    }
  }

  // Thêm comment mới
  static Future<Comment> addComment(String chapterId, String content) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final response = await http.post(
      Uri.parse('${dotenv.get('API_URL')}/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'chapterId': chapterId,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Không thể thêm bình luận');
    }
  }

  // Xóa comment
  static Future<void> deleteComment(String commentId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final response = await http.delete(
      Uri.parse('${dotenv.get('API_URL')}/comments/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa bình luận');
    }
  }
}
