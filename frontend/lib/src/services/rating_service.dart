import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rating.dart';

class RatingService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Vui lòng đăng nhập để đánh giá');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<int> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('session');
    if (sessionJson == null) {
      throw Exception('Vui lòng đăng nhập để đánh giá');
    }
    final session = json.decode(sessionJson);
    return session['user']['id'] as int;
  }

  static Future<List<Rating>> getNovelRatings(String novelId) async {
    try {
      print('Fetching ratings for novel: $novelId');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/ratings/novel/$novelId/with-user'),
        headers: headers,
      );

      print('Rating response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Rating.fromJson(json)).toList();
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

  static Future<void> rateNovel(
    String novelId,
    double score,
    String content,
  ) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getCurrentUserId();

      // Kiểm tra xem đã đánh giá chưa
      final ratings = await getNovelRatings(novelId);
      final existingRating = ratings.firstWhere(
        (r) => r.userId == userId,
        orElse: () => Rating(
          id: -1,
          novelId: int.parse(novelId),
          userId: userId,
          content: '',
          score: 5.0,
          createdAt: DateTime.now(),
        ),
      );

      if (existingRating.id != -1) {
        await updateRating(
          novelId,
          existingRating.id.toString(),
          score,
          content,
        );
        return;
      }

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/ratings'),
        headers: headers,
        body: json.encode({
          'novelId': int.parse(novelId),
          'score': score,
          'content': content,
        }),
      );

      print('Rate novel response: ${response.body}');

      if (response.statusCode != 201) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể đánh giá truyện');
      }
    } catch (e) {
      print('Error in rateNovel: $e');
      rethrow;
    }
  }

  static Future<void> updateRating(
    String novelId,
    String ratingId,
    double score,
    String content,
  ) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getCurrentUserId();
      print('Updating rating $ratingId for novel $novelId');

      // Kiểm tra quyền sửa rating
      final ratings = await getNovelRatings(novelId);
      final rating = ratings.firstWhere(
        (r) => r.id.toString() == ratingId && r.userId == userId,
        orElse: () => throw Exception('Bạn không có quyền sửa đánh giá này'),
      );

      final response = await http.put(
        Uri.parse('${dotenv.get('API_URL')}/ratings/$ratingId'),
        headers: headers,
        body: json.encode({
          'score': score,
          'content': content,
        }),
      );

      print('Update rating response: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể cập nhật đánh giá');
      }
    } catch (e) {
      print('Error in updateRating: $e');
      rethrow;
    }
  }
}
