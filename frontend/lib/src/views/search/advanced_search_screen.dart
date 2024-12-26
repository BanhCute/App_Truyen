import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/category_cubit.dart';
import '../../../bloc/novel_cubit.dart';
import '../../models/category.dart';
import '../../models/novel.dart';

class AdvancedSearchScreen extends StatelessWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CategoryCubit()..loadCategories()),
        BlocProvider(create: (_) => NovelCubit()..loadNovels()),
      ],
      child: const AdvancedSearchView(),
    );
  }
}

class AdvancedSearchView extends StatelessWidget {
  const AdvancedSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ truyện'),
      ),
      body: BlocBuilder<NovelCubit, NovelState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('Lỗi: ${state.error}'));
          }

          return ListView.builder(
            itemCount: state.novels.length,
            itemBuilder: (context, index) {
              final novel = state.novels[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    novel.cover,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                  title: Text(novel.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tác giả: ${novel.author}'),
                      Text('Trạng thái: ${novel.status}'),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye, size: 16),
                          Text(' ${novel.view}'),
                          SizedBox(width: 8),
                          Icon(Icons.star, size: 16),
                          Text(' ${novel.rating}'),
                          SizedBox(width: 8),
                          Icon(Icons.favorite, size: 16),
                          Text(' ${novel.followerCount}'),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Chuyển đến trang chi tiết truyện
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
