import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/category.dart';

class CategoryService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
