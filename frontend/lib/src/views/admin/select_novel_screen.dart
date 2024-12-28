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
  const SelectNovelScreen({Key? key, this.selectedNovel}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn chương - ${widget.selectedNovel?.name ?? ""}'),
        backgroundColor: const Color(0xFF1B3A57),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: context.read<SessionCubit>(),
                                  child: EditChapterScreen(chapter: chapter),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
