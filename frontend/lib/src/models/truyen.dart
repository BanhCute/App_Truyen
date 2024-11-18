class Truyen {
  final String title;
  final String imageUrl;
  final bool isHot;
  final int chapter;
  final String updatedAt;

  const Truyen({
    required this.title,
    required this.imageUrl,
    this.isHot = false,
    required this.chapter,
    required this.updatedAt,
  });
}
