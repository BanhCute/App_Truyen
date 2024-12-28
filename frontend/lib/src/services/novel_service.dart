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
}
