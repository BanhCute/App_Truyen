import 'package:flutter/material.dart';
import '../../models/truyen.dart';
import '../../widgets/truyen_card.dart';
import '../../data/sample_data.dart';

class HotStoriesScreen extends StatelessWidget {
  const HotStoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sử dụng dữ liệu mẫu
    final List<Truyen> truyenHot = sampleTruyens;

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
