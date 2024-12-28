import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/reading_history.dart';

class ReadingHistoryService {
  static const String _key = 'reading_history';
  static const int _maxHistoryItems = 50;

  static Future<List<ReadingHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_key);
    if (historyJson == null) return [];

    List<dynamic> historyList = json.decode(historyJson);
    return historyList.map((item) => ReadingHistory.fromJson(item)).toList();
  }

  static Future<void> addToHistory(Novel novel, {Chapter? lastChapter}) async {
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

    // Thêm vào server nếu đã đăng nhập
    try {
      final token = await _getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${dotenv.get('API_URL')}/history'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'novelId': novel.id,
            'lastChapterId': lastChapter?.id,
          }),
        );
      }
    } catch (e) {
      print('Error adding history to server: $e');
    }
  }

  static Future<void> updateLastChapter(String novelId, Chapter chapter) async {
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

      // Cập nhật trên server nếu đã đăng nhập
      try {
        final token = await _getToken();
        if (token != null) {
          await http.patch(
            Uri.parse('${dotenv.get('API_URL')}/history'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'novelId': novelId,
              'lastChapterId': chapter.id,
            }),
          );
        }
      } catch (e) {
        print('Error updating last chapter on server: $e');
      }
    }
  }

  static Future<void> clearHistory() async {
    // Lưu lại lịch sử cũ để có thể hoàn tác
    final oldHistory = await getHistory();

    // Xóa local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);

    // Xóa trên server nếu đã đăng nhập
    try {
      final token = await _getToken();
      if (token != null) {
        for (var item in oldHistory) {
          try {
            final response = await http.get(
              Uri.parse('${dotenv.get('API_URL')}/history'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );

            if (response.statusCode == 200) {
              final List histories = json.decode(response.body);
              final history = histories.firstWhere(
                (h) => h['novelId'] == item.novel.id,
                orElse: () => null,
              );

              if (history != null) {
                await http.delete(
                  Uri.parse(
                      '${dotenv.get('API_URL')}/history/${history['id']}'),
                  headers: {
                    'Authorization': 'Bearer $token',
                  },
                );
              }
            }
          } catch (e) {
            print('Error deleting history from server: $e');
          }
        }
      }
    } catch (e) {
      print('Error clearing history from server: $e');
    }
  }

  static Future<void> removeFromHistory(String novelId) async {
    // Xóa local
    final prefs = await SharedPreferences.getInstance();
    List<ReadingHistory> history = await getHistory();
    history.removeWhere((item) => item.novel.id == novelId);
    await prefs.setString(
        _key, json.encode(history.map((item) => item.toJson()).toList()));

    // Xóa trên server n���u đã đăng nhập
    try {
      final token = await _getToken();
      if (token != null) {
        final response = await http.get(
          Uri.parse('${dotenv.get('API_URL')}/history'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final List histories = json.decode(response.body);
          final history = histories.firstWhere(
            (h) => h['novelId'] == novelId,
            orElse: () => null,
          );

          if (history != null) {
            await http.delete(
              Uri.parse('${dotenv.get('API_URL')}/history/${history['id']}'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );
          }
        }
      }
    } catch (e) {
      print('Error removing history from server: $e');
    }
  }

  static Future<ReadingHistory?> getLastRead(String novelId) async {
    final history = await getHistory();
    try {
      return history.firstWhere(
        (item) => item.novel.id == novelId,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isInHistory(String novelId) async {
    final history = await getHistory();
    return history.any((item) => item.novel.id == novelId);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
