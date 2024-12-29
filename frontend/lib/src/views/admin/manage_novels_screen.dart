import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';
import '../../models/novel.dart';
import 'edit_novel_screen.dart';
import 'upload_chapter_screen.dart';
import 'manage_novel_categories_screen.dart';

class ManageNovelsScreen extends StatefulWidget {
  const ManageNovelsScreen({super.key});

  @override
  State<ManageNovelsScreen> createState() => _ManageNovelsScreenState();
}

class _ManageNovelsScreenState extends State<ManageNovelsScreen> {
  List<Novel> novels = [];
  bool isLoading = true;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    loadNovels();
  }

  Future<void> loadNovels() async {
    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập')),
          );
        }
        return;
      }

      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${state.session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          novels = data.map((json) => Novel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Không thể tải danh sách truyện');
      }
    } catch (e) {
      print('Error loading novels: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Novel> get filteredNovels {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return novels;
    }
    return novels.where((novel) {
      final query = searchQuery!.toLowerCase();
      return novel.name.toLowerCase().contains(query) ||
          novel.author.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> deleteNovel(Novel novel) async {
    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) return;

      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/novels/${novel.id}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${state.session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa truyện thành công')),
          );
          loadNovels(); // Tải lại danh sách sau khi xóa
        }
      } else {
        throw Exception('Không thể xóa truyện');
      }
    } catch (e) {
      print('Error deleting novel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa truyện: $e')),
        );
      }
    }
  }

  void showDeleteConfirmation(Novel novel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa truyện "${novel.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteNovel(novel);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý truyện'),
        backgroundColor: const Color(0xFF1B3A57),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm truyện',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNovels.isEmpty
                    ? const Center(child: Text('Không có truyện nào'))
                    : ListView.builder(
                        itemCount: filteredNovels.length,
                        itemBuilder: (context, index) {
                          final novel = filteredNovels[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ExpansionTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  novel.cover,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              title: Text(novel.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tác giả: ${novel.author}'),
                                  Text('Trạng thái: ${novel.status}'),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Sửa truyện'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BlocProvider.value(
                                                value: context
                                                    .read<SessionCubit>(),
                                                child: EditNovelScreen(
                                                    novel: novel),
                                              ),
                                            ),
                                          ).then((edited) {
                                            if (edited == true) {
                                              loadNovels();
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add_circle),
                                        label: const Text('Thêm chương mới'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BlocProvider.value(
                                                value: context
                                                    .read<SessionCubit>(),
                                                child: UploadChapterScreen(
                                                    novel: novel),
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.category),
                                        label: const Text('Quản lý thể loại'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BlocProvider.value(
                                                value: context
                                                    .read<SessionCubit>(),
                                                child:
                                                    ManageNovelCategoriesScreen(
                                                        novel: novel),
                                              ),
                                            ),
                                          ).then((_) => loadNovels());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Xóa truyện'),
                                        onPressed: () =>
                                            showDeleteConfirmation(novel),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
