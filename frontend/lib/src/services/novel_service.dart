import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/novel.dart';

class NovelService {
  static Future<List<Novel>> getRecommendedNovels() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final novels = data.map((json) => Novel.fromJson(json)).toList();
        novels.sort((a, b) => b.rating.compareTo(a.rating));
        return novels.take(4).toList();
      } else {
        throw Exception('Không thể lấy danh sách truyện đề xuất');
      }
    } catch (e) {
      print('Error getting recommended novels: $e');
      return [];
    }
  }

  // Cập nhật số lượt follow
  static Future<void> updateFollowCount(
      String novelId, bool isIncrement) async {
    try {
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/follow-count'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'increment': isIncrement}),
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể cập nhật số lượt theo dõi');
      }
    } catch (e) {
      print('Error updating follow count: $e');
    }
  }

  // Cập nhật số lượt xem
  static Future<void> incrementView(String novelId) async {
    try {
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/view'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể cập nhật số lượt xem');
      }
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Lấy số lượt follow của truyện
  static Future<int> getFollowCount(String novelId) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['followerCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting follow count: $e');
      return 0;
    }
  }

  // Lấy số lượt xem của truyện
  static Future<int> getViewCount(String novelId) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['view'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting view count: $e');
      return 0;
    }
  }
}
