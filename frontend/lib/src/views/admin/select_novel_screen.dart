import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:frontend/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import 'edit_chapter_screen.dart';
import 'dart:convert';

class SelectNovelScreen extends StatefulWidget {
  final Novel? selectedNovel;
  const SelectNovelScreen({super.key, this.selectedNovel});

  @override
  State<SelectNovelScreen> createState() => _SelectNovelScreenState();
}

class _SelectNovelScreenState extends State<SelectNovelScreen> {
  List<Chapter> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        return;
      }
      final token = state.session.accessToken;

      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          chapters = data
              .where((chapter) =>
                  chapter['novelId'].toString() == widget.selectedNovel?.id)
              .map((json) => Chapter.fromJson(json))
              .toList();
          chapters.sort((a, b) {
            try {
              final aNum = int.parse(a.name.replaceAll(RegExp(r'[^0-9]'), ''));
              final bNum = int.parse(b.name.replaceAll(RegExp(r'[^0-9]'), ''));
              return aNum.compareTo(bNum);
            } catch (e) {
              return 0;
            }
          });
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      print('Error loading chapters: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteChapter(Chapter chapter) async {
    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        return;
      }
      final token = state.session.accessToken;

      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/chapters/${chapter.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa chương thành công')),
          );
          _loadChapters(); // Tải lại danh sách sau khi xóa
        }
      } else {
        throw Exception('Không thể xóa chương');
      }
    } catch (e) {
      print('Error deleting chapter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa chương: $e')),
        );
      }
    }
  }

  void showDeleteConfirmation(Chapter chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa chương "${chapter.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteChapter(chapter);
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
        title: Text('Chọn chương - ${widget.selectedNovel?.name ?? ""}'),
        backgroundColor: const Color.fromARGB(255, 230, 240, 236),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chapters.isEmpty
              ? const Center(child: Text('Chưa có chương nào'))
              : ListView.builder(
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(chapter.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: context.read<SessionCubit>(),
                                      child:
                                          EditChapterScreen(chapter: chapter),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDeleteConfirmation(chapter),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
