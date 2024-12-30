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
    final userData = prefs.getString('user_data');
    if (userData == null) {
      throw Exception('Vui lòng đăng nhập để đánh giá');
    }
    final user = json.decode(userData);
    return user['id'] as int;
  }

  static Future<Map<String, dynamic>> getNovelRatings(String novelId,
      {int page = 1, int limit = 10}) async {
    try {
      print('Fetching ratings for novel: $novelId (page $page, limit $limit)');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('API_URL')}/ratings?novelId=$novelId&page=$page&limit=$limit'),
        headers: headers,
      );

      print('Rating response status: ${response.statusCode}');
      print('Rating response headers: ${response.headers}');
      print('Rating response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: $data');

        if (data is Map<String, dynamic>) {
          final items = (data['items'] as List).map((json) {
            print('Processing rating: $json');
            return Rating.fromJson(json);
          }).toList();

          return {
            'items': items,
            'meta': data['meta'],
          };
        } else {
          print('Invalid response format: $data');
          return {
            'items': <Rating>[],
            'meta': {
              'page': page,
              'limit': limit,
              'total': 0,
              'totalPages': 0,
            }
          };
        }
      } else {
        print(
            'Failed to load ratings: ${response.statusCode} - ${response.body}');
        return {
          'items': <Rating>[],
          'meta': {
            'page': page,
            'limit': limit,
            'total': 0,
            'totalPages': 0,
          }
        };
      }
    } catch (e, stackTrace) {
      print('Error getting ratings: $e');
      print('Stack trace: $stackTrace');
      return {
        'items': <Rating>[],
        'meta': {
          'page': page,
          'limit': limit,
          'total': 0,
          'totalPages': 0,
        }
      };
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
      final result = await getNovelRatings(novelId);
      final ratings = result['items'] as List<Rating>;
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
      final result = await getNovelRatings(novelId);
      final ratings = result['items'] as List<Rating>;
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
