import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:frontend/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/novel.dart';
import 'upload_chapter_screen.dart';
import 'dart:convert';

class SelectNovelScreen extends StatefulWidget {
  final Novel? selectedNovel;
  const SelectNovelScreen({Key? key, this.selectedNovel}) : super(key: key);

  @override
  State<SelectNovelScreen> createState() => _SelectNovelScreenState();
}

class _SelectNovelScreenState extends State<SelectNovelScreen> {
  List<Novel> novels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNovels();
  }

  Future<void> _loadNovels() async {
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
        Uri.parse('${dotenv.get('API_URL')}/novels'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          novels = data.map((json) => Novel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load novels');
      }
    } catch (e) {
      print('Error loading novels: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn truyện để thêm chương'),
        backgroundColor: const Color(0xFF1B3A57),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : novels.isEmpty
              ? const Center(child: Text('Chưa có truyện nào'))
              : ListView.builder(
                  itemCount: novels.length,
                  itemBuilder: (context, index) {
                    final novel = novels[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
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
                        subtitle: Text(novel.author),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<SessionCubit>(),
                                child: UploadChapterScreen(novel: novel),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
