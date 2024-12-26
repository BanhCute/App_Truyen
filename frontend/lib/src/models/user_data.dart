class UserData {
  final List<String> followedStories; // Lưu ID của truyện đã follow
  final Map<String, int> readingHistory; // Lưu ID truyện và chapter đã đọc

  UserData({
    List<String>? followedStories,
    Map<String, int>? readingHistory,
  })  : followedStories = followedStories ?? [],
        readingHistory = readingHistory ?? {};

  // Thêm/xóa truyện khỏi danh sách theo dõi
  void toggleFollow(String storyId) {
    if (followedStories.contains(storyId)) {
      followedStories.remove(storyId);
    } else {
      followedStories.add(storyId);
    }
  }

  // Cập nhật lịch sử đọc
  void updateReadingHistory(String storyId, int chapterNumber) {
    readingHistory[storyId] = chapterNumber;
  }

  // Xóa lịch sử đọc của một truyện
  void removeFromHistory(String storyId) {
    readingHistory.remove(storyId);
  }
} 