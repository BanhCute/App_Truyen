import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/novel.dart';
import '../../../bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageNovelCategoriesScreen extends StatefulWidget {
  final Novel novel;

  const ManageNovelCategoriesScreen({
    Key? key,
    required this.novel,
  }) : super(key: key);

  @override
  State<ManageNovelCategoriesScreen> createState() =>
      _ManageNovelCategoriesScreenState();
}

class _ManageNovelCategoriesScreenState
    extends State<ManageNovelCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  List<int> _selectedCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _selectedCategories =
        widget.novel.categories.map((e) => int.parse(e)).toList();
  }

  Future<void> _loadCategories() async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.get('API_URL')}/categories'));
      if (response.statusCode == 200) {
        setState(() {
          _categories =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thực hiện')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
            '${dotenv.get('API_URL')}/novels/${widget.novel.id}/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.session.accessToken}',
        },
        body: json.encode({
          'categoryIds': _selectedCategories,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật thể loại')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Không thể cập nhật thể loại');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thể loại'),
        backgroundColor: const Color(0xFF1B3A57),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected =
                          _selectedCategories.contains(category['id']);

                      return CheckboxListTile(
                        title: Text(category['name']),
                        subtitle: Text(category['description'] ?? ''),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedCategories.add(category['id']);
                            } else {
                              _selectedCategories.remove(category['id']);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A57),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _saveCategories,
                      child: const Text('Lưu thay đổi'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
