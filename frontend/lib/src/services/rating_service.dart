import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rating.dart';

class RatingService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<Rating>> getNovelRatings(String novelId) async {
    try {
      print('Fetching ratings for novel: $novelId');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/ratings'),
        headers: headers,
      );

      print('Rating response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final novelIdInt = int.parse(novelId);
        return data
            .where((json) => json['novelId'] == novelIdInt)
            .map((json) => Rating.fromJson(json))
            .toList();
      } else {
        print(
            'Failed to load ratings: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting ratings: $e');
      return [];
    }
  }

  static Future<void> _updateNovelRating(
      String novelId, List<Rating> ratings) async {
    try {
      final headers = await _getHeaders();
      final averageRating =
          ratings.map((r) => r.score).reduce((a, b) => a + b) / ratings.length;

      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId'),
        headers: headers,
        body: json.encode({
          'rating': averageRating,
        }),
      );

      if (response.statusCode != 200) {
        print(
            'Failed to update novel rating: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating novel rating: $e');
    }
  }

  static Future<void> rateNovel(
    String novelId,
    double score,
    String content,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${dotenv.get('API_URL')}/ratings'),
      headers: headers,
      body: json.encode({
        'novelId': int.parse(novelId),
        'score': score,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(json.decode(response.body)['message']);
    }

    await getNovelRatings(novelId);
  }

  static Future<void> updateRating(
    String novelId,
    String ratingId,
    double score,
    String content,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${dotenv.get('API_URL')}/ratings/$ratingId'),
      headers: headers,
      body: json.encode({
        'novelId': int.parse(novelId),
        'score': score,
        'content': content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['message']);
    }

    await getNovelRatings(novelId);
  }
}
