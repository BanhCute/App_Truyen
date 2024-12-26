import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/novel.dart';

class ReadingHistoryService {
  static const String _key = 'reading_history';
  static const int _maxHistoryItems = 50;

  static Future<List<Novel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_key);
    if (historyJson == null) return [];

    List<dynamic> historyList = json.decode(historyJson);
    return historyList.map((item) => Novel.fromJson(item)).toList();
  }

  static Future<void> addToHistory(Novel novel) async {
    final prefs = await SharedPreferences.getInstance();
    List<Novel> history = await getHistory();

    // Xóa nếu truyện đã tồn tại trong lịch sử
    history.removeWhere((item) => item.id == novel.id);

    // Thêm truyện mới vào đầu danh sách
    history.insert(0, novel);

    // Giới hạn số lượng truyện trong lịch sử
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }

    // Lưu lại lịch sử
    await prefs.setString(
        _key, json.encode(history.map((novel) => novel.toJson()).toList()));
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> isInHistory(int novelId) async {
    final history = await getHistory();
    return history.any((novel) => novel.id == novelId);
  }

  static Future<void> removeFromHistory(int novelId) async {
    final prefs = await SharedPreferences.getInstance();
    List<Novel> history = await getHistory();
    history.removeWhere((novel) => novel.id == novelId);
    await prefs.setString(
        _key, json.encode(history.map((novel) => novel.toJson()).toList()));
  }
}
