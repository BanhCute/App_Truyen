import 'package:flutter/material.dart';
import '../../models/truyen.dart';
import '../../widgets/truyen_card.dart';

class HotStoriesScreen extends StatelessWidget {
  const HotStoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Danh sách truyện hot
    final List<Truyen> truyenHot = const [
      Truyen(
          title: "Doraemon",
          imageUrl:
              "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiUBftbgOZfAhnKmdPGAnmMlUAFZpvzBE0yQQ5L-XnOV_vcVVVRbPFG4b6o5UZYMg4Qe0HQQqesqP6cU91xnbgzQbqrlqdr6qbwPdPuXsKAw-Mucxp3N8xJZu3Rq_53HxRKHbMn4mF2kOlzZkc-IAdWBizIrEsPI4eR54twId_PGkBaIq-Tlxz5IR9K/s1536/DORAEMON%20Vol.2%20-%20FUJIKO%20F%20FUJIO_Page_01_Image_0001.jpg",
          isHot: true,
          chapter: 15,
          updatedAt: "1 Phút Trước"),
      Truyen(
          title: "Hunter X Hunter",
          imageUrl:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSVFQx-jWl8oHOluT8-PXxCL_BzmDedSsa6JPfzBwFGiK8zJCF&s",
          isHot: true,
          chapter: 167,
          updatedAt: "2 Phút Trước"),
      Truyen(
          title: "Cậu Út Nhà Công Tước Là Sát Thủ Hồi Quy",
          imageUrl:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMxILuwJIS96JtWH9A9G-oaKy3qgs0GndHo8hv1CyfKyPlgjnk",
          isHot: true,
          chapter: 256,
          updatedAt: "5 Phút Trước"),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A57),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.local_fire_department, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Truyện Hot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7,
          ),
          padding: const EdgeInsets.all(8.0),
          itemCount: truyenHot.length,
          itemBuilder: (context, index) {
            return TruyenCard(truyen: truyenHot[index]);
          },
        ),
      ),
    );
  }
}
