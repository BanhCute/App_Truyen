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

      final data = json.decode(response.body) as List;

      final novels = data.map((json) => Novel.fromJson(json)).toList();

      novels.sort((a, b) => b.rating.compareTo(a.rating));

      return novels.take(4).toList();
    } catch (e) {
      print('Error getting recommended novels: $e');

      return [];
    }
  }

  static Future<int> getFollowCount(String novelId) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId'),
      );

      if (response.statusCode == 200) {
        final novelData = json.decode(response.body);
        return novelData['followerCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting follow count: $e');
      return 0;
    }
  }

  static Future<void> updateFollowCount(String novelId) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/follow-count'),
      );

      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
        throw Exception('Không thể cập nhật số lượt theo dõi');
      }
    } catch (e) {
      print('Error updating follow count: $e');
      throw Exception('Không thể cập nhật số lượt theo dõi');
    }
  }

  static Future<void> deleteNovel(String novelId) async {
    try {
      await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId'),
      );
    } catch (e) {
      print('Error deleting novel: $e');
    }
  }

  static Future<Novel> updateNovelInfo(String novelId) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId'),
      );

      if (response.statusCode == 200) {
        final novelData = json.decode(response.body);
        return Novel.fromJson(novelData);
      }
      throw Exception('Không thể cập nhật thông tin truyện');
    } catch (e) {
      print('Error updating novel info: $e');
      throw Exception('Không thể cập nhật thông tin truyện');
    }
  }

  static Future<List<Novel>> getAllNovels() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> novelsData = json.decode(response.body);
        return novelsData.map((json) => Novel.fromJson(json)).toList();
      }
      throw Exception('Không thể lấy danh sách truyện');
    } catch (e) {
      print('Error getting all novels: $e');
      throw Exception('Không thể lấy danh sách truyện');
    }
  }
}
