import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/reading_history.dart';

class ReadingHistoryService {
  static const String _key = 'reading_history';
  static const int _maxHistoryItems = 50;

  static Future<List<ReadingHistory>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_key);
      if (historyJson == null) return [];

      List<dynamic> historyList = json.decode(historyJson);
      return historyList.map((item) => ReadingHistory.fromJson(item)).toList();
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }

  static Future<void> addToHistory(Novel novel, {Chapter? lastChapter}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<ReadingHistory> history = await getHistory();

      // Xóa nếu truyện đã tồn tại trong lịch sử
      history.removeWhere((item) => item.novel.id == novel.id);

      // Thêm truyện mới vào đầu danh sách
      history.insert(0, ReadingHistory(novel: novel, lastChapter: lastChapter));

      // Giới hạn số lượng truyện trong lịch sử
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }

      // Lưu lại lịch sử
      await prefs.setString(
          _key, json.encode(history.map((item) => item.toJson()).toList()));
    } catch (e) {
      print('Error adding to history: $e');
    }
  }

  static Future<void> updateLastChapter(String novelId, Chapter chapter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<ReadingHistory> history = await getHistory();

      // Tìm và cập nhật chương đọc gần nhất
      final index = history.indexWhere((item) => item.novel.id == novelId);
      if (index != -1) {
        final oldHistory = history[index];
        history[index] = ReadingHistory(
          novel: oldHistory.novel,
          lastChapter: chapter,
        );

        // Lưu lại lịch sử
        await prefs.setString(
            _key, json.encode(history.map((item) => item.toJson()).toList()));
      }
    } catch (e) {
      print('Error updating last chapter: $e');
    }
  }

  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  static Future<void> removeFromHistory(String novelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<ReadingHistory> history = await getHistory();
      history.removeWhere((item) => item.novel.id == novelId);
      await prefs.setString(
          _key, json.encode(history.map((item) => item.toJson()).toList()));
    } catch (e) {
      print('Error removing from history: $e');
    }
  }

  static Future<ReadingHistory?> getLastRead(String novelId) async {
    try {
      final history = await getHistory();
      return history.firstWhere(
        (item) => item.novel.id == novelId,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isInHistory(String novelId) async {
    try {
      final history = await getHistory();
      return history.any((item) => item.novel.id == novelId);
    } catch (e) {
      return false;
    }
  }
}
