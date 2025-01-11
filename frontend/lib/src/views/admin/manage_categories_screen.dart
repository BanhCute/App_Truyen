import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../models/category.dart';
import '../../../bloc/session_cubit.dart';
import 'package:provider/provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_mounted && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadCategories() async {
    if (!_mounted) return;

    _safeSetState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/categories'),
      );

      print('Load categories response status: ${response.statusCode}');
      print('Load categories response body: ${response.body}');

      if (!_mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _safeSetState(() {
          categories = data.map((json) => Category.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        _safeSetState(() {
          isLoading = false;
        });
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Không thể tải danh sách thể loại: ${response.statusCode} - ${response.body}')),
          );
        }
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (!_mounted) return;
      _safeSetState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  Future<void> addCategory() async {
    if (!_mounted) return;

    final TextEditingController nameController = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thêm thể loại mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên thể loại',
                  hintText: 'Nhập tên thể loại',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Thêm'),
            ),
          ],
        ),
      );

      if (!_mounted || result != true) return;

      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên thể loại')),
        );
        return;
      }

      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        throw Exception('Vui lòng đăng nhập');
      }

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.session.accessToken}',
        },
        body: json.encode({
          'name': nameController.text,
        }),
      );

      if (!_mounted) return;

      if (response.statusCode == 201) {
        await _loadCategories();
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm thể loại thành công')),
          );
        }
      } else {
        throw Exception('Không thể thêm thể loại');
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _deleteCategory(int id) async {
    if (!_mounted) return;

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        throw Exception('Vui lòng đăng nhập');
      }

      final response = await http.delete(
        Uri.parse('${dotenv.get('API_URL')}/categories/$id'),
        headers: {
          'Authorization': 'Bearer ${state.session.accessToken}',
        },
      );

      if (!_mounted) return;

      if (response.statusCode == 200) {
        await _loadCategories();
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa thể loại thành công')),
          );
        }
      } else {
        throw Exception('Không thể xóa thể loại');
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thể loại "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category.id);
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

  Future<void> _editCategory(Category category) async {
    if (!_mounted) return;

    final TextEditingController nameController =
        TextEditingController(text: category.name);

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sửa thể loại'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên thể loại',
                  hintText: 'Nhập tên thể loại',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      );

      if (!_mounted || result != true) return;

      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên thể loại')),
        );
        return;
      }

      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        throw Exception('Vui lòng đăng nhập');
      }

      final response = await http.patch(
        Uri.parse('${dotenv.get('API_URL')}/categories/${category.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.session.accessToken}',
        },
        body: json.encode({
          'name': nameController.text,
          'description': category.description,
        }),
      );

      print('Update category response status: ${response.statusCode}');
      print('Update category response body: ${response.body}');

      if (!_mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _loadCategories();
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thể loại thành công')),
          );
        }
      } else {
        throw Exception('Không thể cập nhật thể loại');
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      nameController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thể loại'),
        backgroundColor: const Color.fromARGB(255, 230, 240, 236),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editCategory(category),
                          tooltip: 'Sửa thể loại',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmation(category),
                          tooltip: 'Xóa thể loại',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCategory,
        backgroundColor: const Color.fromARGB(255, 230, 240, 236),
        child: const Icon(Icons.add),
      ),
    );
  }
}
