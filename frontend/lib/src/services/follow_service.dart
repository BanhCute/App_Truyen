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

  static Future<void> _updateFollowCount(String novelId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/follow-count'),
        headers: headers,
      );
      print(
          'Update follow count response: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error updating follow count: $e');
    }
  }

  static Future<void> followNovel(String novelId) async {
    try {
      final headers = await getHeaders();
      print('Following novel $novelId with headers: $headers');

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/follows'),
        headers: headers,
        body: json.encode({'novelId': int.parse(novelId)}),
      );

      print('Follow response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        await _updateFollowCount(novelId);

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
      print('Error following novel: $e');
      if (e is FormatException) {
        throw Exception('Không thể theo dõi truyện');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  static Future<void> unfollowNovel(String novelId) async {
    try {
      final headers = await getHeaders();
      print('Unfollowing novel $novelId with headers: $headers');

      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/follows/novel/$novelId'),
        headers: headers,
      );

      print('Unfollow response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        await _updateFollowCount(novelId);
      } else {
        throw Exception('Không thể bỏ theo dõi truyện');
      }
    } catch (e) {
      print('Error unfollowing novel: $e');
      throw Exception('Lỗi khi bỏ theo dõi truyện');
    }
  }

  static Future<bool> isFollowing(String novelId) async {
    try {
      final follows = await getFollowedNovels();
      print(
          'Checking follow status for novel $novelId. Current follows: ${follows.length}');
      final isFollowed =
          follows.any((follow) => follow.novelId.toString() == novelId);
      print('Novel $novelId is followed: $isFollowed');
      return isFollowed;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }
}
