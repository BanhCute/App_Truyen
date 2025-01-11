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
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/follow-count'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data['followCount'] ?? 0;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> getViewCount(String novelId) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/view-count'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data['viewCount'] ?? 0;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> incrementView(String novelId) async {
    try {
      await http.post(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/view'),
      );
    } catch (e) {
      print('Error incrementing view: $e');
    }
  }

  static Future<void> updateFollowCount(String novelId) async {
    try {
      await http.post(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId'),
      );
    } catch (e) {
      print('Error updating follow count: $e');
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
}
