import 'novel.dart';
import 'chapter.dart';

class ReadingHistory {
  final Novel novel;
  final Chapter? lastChapter; // Chương đang đọc, null nếu chưa đọc

  ReadingHistory({
    required this.novel,
    this.lastChapter,
  });

  Map<String, dynamic> toJson() {
    return {
      'novel': novel.toJson(),
      'lastChapter': lastChapter?.toJson(),
    };
  }

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      novel: Novel.fromJson(json['novel']),
      lastChapter: json['lastChapter'] != null
          ? Chapter.fromJson(json['lastChapter'])
          : null,
    );
  }
}
