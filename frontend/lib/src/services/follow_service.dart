import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/follow.dart';

class FollowService {
  static late BuildContext _context;

  static void initialize(BuildContext context) {
    _context = context;
  }

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<Follow>> getFollowedNovels() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/follows'),
        headers: headers,
      );

      print('Get follows response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        final List jsonResponse = json.decode(response.body);
        return jsonResponse.map((json) => Follow.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        return [];
      } else {
        if (response.body.isEmpty) {
          throw Exception('Không thể lấy danh sách truyện đang theo dõi');
        }
        final error = json.decode(response.body);
        if (error is Map<String, dynamic>) {
          throw Exception(error['message'] ??
              'Không thể lấy danh sách truyện đang theo dõi');
        } else {
          throw Exception('Không thể lấy danh sách truyện đang theo dõi');
        }
      }
    } catch (e) {
      print('Get follows error: $e');
      return [];
    }
  }

  static Future<void> followNovel(String novelId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/follows'),
        headers: headers,
        body: json.encode({'novelId': int.parse(novelId)}),
      );

      if (response.statusCode == 201) {
        if (_context.mounted) {
          ScaffoldMessenger.of(_context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm vào danh sách theo dõi'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể theo dõi truyện');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Không thể theo dõi truyện');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  static Future<void> unfollowNovel(String novelId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/follows/novel/$novelId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể bỏ theo dõi truyện');
      }
    } catch (e) {
      throw Exception('Lỗi khi bỏ theo dõi truyện');
    }
  }

  static Future<bool> isFollowing(String novelId) async {
    try {
      final follows = await getFollowedNovels();
      return follows.any((follow) => follow.novelId.toString() == novelId);
    } catch (e) {
      return false;
    }
  }
}
