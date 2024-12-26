import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../src/models/novel.dart';

class NovelState {
  final bool isLoading;
  final String? error;
  final List<dynamic> novels;

  NovelState({
    this.isLoading = false,
    this.error,
    this.novels = const [],
  });
}

class NovelCubit extends Cubit<NovelState> {
  NovelCubit() : super(NovelState());

  Future<void> loadNovels() async {
    emit(NovelState(isLoading: true));
    try {
      final response = await http.get(
        Uri.parse('https://webnovel-hife.onrender.com/api/v1/novels')
      );
      final List data = json.decode(response.body);
      final novels = data.map((json) => Novel.fromJson(json)).toList();
      emit(NovelState(novels: novels));
    } catch (e) {
      emit(NovelState(error: e.toString()));
    }
  }
} 