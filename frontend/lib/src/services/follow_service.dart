import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/follow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/session_cubit.dart';

class FollowService {
  static SessionCubit? _sessionCubit;

  static void initialize(BuildContext context) {
    _sessionCubit = context.read<SessionCubit>();
  }

  static Future<String?> _getToken() async {
    return _sessionCubit?.getValidToken();
  }

  // Lấy danh sách truyện đang theo dõi của user
  static Future<List<Follow>> getFollowedNovels() async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final response = await http.get(
      Uri.parse('${dotenv.get('API_URL')}/follows'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Follow.fromJson(json)).toList();
    } else {
      throw Exception('Không thể lấy danh sách truyện đang theo dõi');
    }
  }

  // Theo dõi một truyện
  static Future<Follow> followNovel(String novelId) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Vui lòng đăng nhập để thực hiện chức năng này');

    final url = '${dotenv.get('API_URL')}/follows';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          'novelId': int.parse(novelId),
        }),
      );

      print('Follow response status: ${response.statusCode}');
      print('Follow response body: ${response.body}');

      if (response.statusCode == 201) {
        return Follow.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể theo dõi truyện');
      }
    } catch (e) {
      print('Follow error: $e');
      rethrow;
    }
  }

  // Bỏ theo dõi một truyện
  static Future<void> unfollowNovel(String novelId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final url = '${dotenv.get('API_URL')}/follows/novel/${int.parse(novelId)}';
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể bỏ theo dõi truyện');
      }
    } catch (e) {
      print('Unfollow error: $e');
      rethrow;
    }
  }

  // Kiểm tra xem user có đang theo dõi truyện không
  static Future<bool> isFollowing(String novelId) async {
    try {
      final follows = await getFollowedNovels();
      return follows.any((follow) => follow.novelId == novelId);
    } catch (e) {
      return false;
    }
  }
}
