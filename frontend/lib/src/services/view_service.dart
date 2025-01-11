import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewService {
  static Future<void> incrementView(String novelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewKey = 'novel_view_$novelId';
      final lastViewTime = prefs.getInt(viewKey);
      final now = DateTime.now().millisecondsSinceEpoch;

      // Kiểm tra xem đã view trong 24h gần đây chưa
      if (lastViewTime == null || now - lastViewTime > 24 * 60 * 60 * 1000) {
        final response = await http.post(
          Uri.parse('${dotenv.get('API_URL')}/novels/$novelId/view'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Lưu thời gian view
          await prefs.setInt(viewKey, now);
        }
      }
    } catch (e) {
      print('Error incrementing view: $e');
    }
  }
}
