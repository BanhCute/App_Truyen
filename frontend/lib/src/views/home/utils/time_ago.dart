String getTimeAgo(String dateString) {
  DateTime date = DateTime.parse(dateString).toLocal();
  DateTime now = DateTime.now();
  Duration difference = now.difference(date);

  if (difference.inDays > 0) {
    return 'Cập nhật ${difference.inDays} ngày trước';
  } else if (difference.inHours > 0) {
    return 'Cập nhật ${difference.inHours} giờ trước';
  } else if (difference.inMinutes > 0) {
    return 'Cập nhật ${difference.inMinutes} phút trước';
  } else if (difference.inSeconds > 30) {
    return 'Cập nhật ${difference.inSeconds} giây trước';
  } else {
    return 'Vừa cập nhật';
  }
}
