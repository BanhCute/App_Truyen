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
    super.key,
    required this.novel,
  });

  @override
  State<ManageNovelCategoriesScreen> createState() =>
      _ManageNovelCategoriesScreenState();
}

class _ManageNovelCategoriesScreenState
    extends State<ManageNovelCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  List<int> _selectedCategories = [];
  bool _isLoading = true;
  late final SessionCubit _sessionCubit;

  @override
  void initState() {
    super.initState();
    _sessionCubit = context.read<SessionCubit>();
    _loadCategories();
    if (widget.novel.categories.isNotEmpty) {
      _selectedCategories = widget.novel.categories
          .map((cat) => cat.category['id'] as int)
          .toList();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.get('API_URL')}/categories'));
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _categories =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final state = _sessionCubit.state;
      if (state is! Authenticated) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thực hiện')),
        );
        return;
      }

      print('Selected categories: $_selectedCategories');
      print('Novel ID: ${widget.novel.id}');

      final requestBody = json.encode({
        'categoryIds': _selectedCategories,
      });
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse(
            '${dotenv.get('API_URL')}/novels/${int.parse(widget.novel.id)}/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.session.accessToken}',
        },
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Response categories: ${responseData['categories']}');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thể loại')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Không thể cập nhật thể loại');
      }
    } catch (e) {
      print('Error saving categories: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
