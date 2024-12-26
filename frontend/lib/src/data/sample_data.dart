import '../models/truyen.dart';

final List<Truyen> sampleTruyens = [
  Truyen(
    id: '1',
    title: "Doraemon",
    imageUrl:
        "https://i.pinimg.com/236x/1c/c6/9d/1cc69d23d50924b75ed7a34ed45969c4.jpg",
    isHot: true,
    totalChapters: 15,
    chapter: 15,
    updatedAt: "1 Phút Trước",
    rating: 4.8,
    description: "Doraemon là bộ truyện tranh nổi tiếng của Fujiko F. Fujio",
    chapters: defaultChapters,
  ),
  Truyen(
    id: '2',
    title: "Hunter X Hunter",
    imageUrl:
        "https://m.media-amazon.com/images/M/MV5BZjNmZDhkN2QtNDYyZC00YzJmLTg0ODUtN2FjNjhhMzE3ZmUxXkEyXkFqcGdeQXVyNjc2NjA5MTU@._V1_FMjpg_UX1000_.jpg",
    isHot: true,
    totalChapters: 167,
    chapter: 167,
    updatedAt: "2 Phút Trước",
    rating: 4.7,
    description: "Hunter X Hunter là bộ truyện tranh của Togashi Yoshihiro",
    chapters: defaultChapters,
  ),
  Truyen(
    id: '3',
    title: "One Piece",
    imageUrl:
        "https://upload.wikimedia.org/wikipedia/en/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg",
    isHot: true,
    totalChapters: 1089,
    chapter: 1089,
    updatedAt: "5 Phút Trước",
    rating: 4.9,
    description: "One Piece là bộ manga về hải tặc của Eiichiro Oda",
    chapters: defaultChapters,
  ),
  Truyen(
    id: '4',
    title: "Naruto",
    imageUrl:
        "https://upload.wikimedia.org/wikipedia/en/9/94/NarutoCoverTankobon1.jpg",
    isHot: true,
    totalChapters: 700,
    chapter: 700,
    updatedAt: "10 Phút Trước",
    rating: 4.6,
    description: "Naruto là bộ truyện tranh nổi tiếng của Masashi Kishimoto",
    chapters: defaultChapters,
  ),
  Truyen(
    id: '5',
    title: "Dragon Ball",
    imageUrl:
        "https://upload.wikimedia.org/wikipedia/en/c/c9/DB_Tank%C5%8Dbon.png",
    isHot: true,
    totalChapters: 519,
    chapter: 519,
    updatedAt: "15 Phút Trước",
    rating: 4.8,
    description: "Dragon Ball là bộ truyện tranh của Akira Toriyama",
    chapters: defaultChapters,
  ),
];

// Danh sách chapter mặc định cho mỗi truyện
final List<Chapter> defaultChapters = [
  Chapter(
    id: '1',
    number: 1,
    title: 'Chapter 1: Khởi Đầu',
    content: 'Nội dung chapter 1...',
    publishDate: DateTime.now(),
    comments: [],
  ),
  Chapter(
    id: '2',
    number: 2,
    title: 'Chapter 2: Cuộc Phiêu Lưu',
    content: 'Nội dung chapter 2...',
    publishDate: DateTime.now(),
    comments: [],
  ),
  Chapter(
    id: '3',
    number: 3,
    title: 'Chapter 3: Thử Thách',
    content: 'Nội dung chapter 3...',
    publishDate: DateTime.now(),
    comments: [],
  ),
];

// Danh sách đề xuất sử dụng lại từ sampleTruyens
final List<Map<String, String>> deXuatItems = [
  {
    'image': sampleTruyens[0].imageUrl,
    'title': 'Truyện Nhiều Người Đọc',
  },
  {
    'image': sampleTruyens[1].imageUrl,
    'title': 'Truyện Hot Tháng',
  },
  {
    'image': sampleTruyens[2].imageUrl,
    'title': 'Truyện Mới Cập Nhật',
  },
  {
    'image': sampleTruyens[3].imageUrl,
    'title': 'Truyện Đề Cử',
  },
];

// Hàm helper để lấy truyện theo id
Truyen getTruyenById(String id) {
  return sampleTruyens.firstWhere((truyen) => truyen.id == id);
}
