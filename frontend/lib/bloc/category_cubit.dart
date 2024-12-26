import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../src/models/category.dart';

class CategoryState {
  final bool isLoading;
  final String? error;
  final List<dynamic> categories;

  CategoryState({
    this.isLoading = false,
    this.error,
    this.categories = const [],
  });
}

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryState());

  Future<void> loadCategories() async {
    emit(CategoryState(isLoading: true));
    try {
      final response = await http.get(
        Uri.parse('https://webnovel-hife.onrender.com/api/v1/categories')
      );
      final List data = json.decode(response.body);
      final categories = data.map((json) => Category.fromJson(json)).toList();
      emit(CategoryState(categories: categories));
    } catch (e) {
      emit(CategoryState(error: e.toString()));
    }
  }
}
