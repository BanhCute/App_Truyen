import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rating.dart';

class RatingService {
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<Rating>> getNovelRatings(String novelId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/ratings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Rating.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lấy đánh giá');
      }
    } catch (e) {
      print('Error getting ratings: $e');
      return [];
    }
  }

  static Future<Rating> rateNovel(
      String novelId, double score, String content) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/ratings'),
        headers: headers,
        body: json.encode({
          'score': score,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        return Rating.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể đánh giá truyện');
      }
    } catch (e) {
      print('Error rating novel: $e');
      throw Exception('Không thể đánh giá truyện. Vui lòng thử lại sau.');
    }
  }

  static Future<Rating> updateRating(
      String novelId, String ratingId, double score, String content) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/ratings/$ratingId'),
        headers: headers,
        body: json.encode({
          'score': score,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return Rating.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể cập nhật đánh giá');
      }
    } catch (e) {
      print('Error updating rating: $e');
      throw Exception('Không thể cập nhật đánh giá. Vui lòng thử lại sau.');
    }
  }

  static Future<double> getAverageRating(String novelId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/ratings/average'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['average'].toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      print('Error getting average rating: $e');
      return 0.0;
    }
  }
}
