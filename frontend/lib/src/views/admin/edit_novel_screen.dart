import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../models/novel.dart';

class EditNovelScreen extends StatefulWidget {
  final Novel novel;
  const EditNovelScreen({super.key, required this.novel});

  @override
  State<EditNovelScreen> createState() => _EditNovelScreenState();
}

class _EditNovelScreenState extends State<EditNovelScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _authorController;
  String? _selectedStatus;
  File? _coverImage;
  String? _currentCoverUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.novel.name);
    _descriptionController =
        TextEditingController(text: widget.novel.description);
    _authorController = TextEditingController(text: widget.novel.author);
    _selectedStatus = widget.novel.status;
    _currentCoverUrl = widget.novel.cover;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        final File originalFile = File(pickedFile.path);
        try {
          final Directory tempDir = await getTemporaryDirectory();
          final String targetPath =
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.path,
            targetPath,
            quality: 85,
            format: CompressFormat.jpeg,
          );

          if (compressedFile != null) {
            setState(() {
              _coverImage = File(compressedFile.path);
              _currentCoverUrl =
                  null; // Reset current cover URL when new image is picked
            });
          } else {
            setState(() {
              _coverImage = originalFile;
              _currentCoverUrl = null;
            });
          }
        } catch (e) {
          print('Error compressing image: $e');
          setState(() {
            _coverImage = originalFile;
            _currentCoverUrl = null;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_coverImage == null) return _currentCoverUrl;

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) return null;
      final token = state.session.accessToken;

      final fileSize = await _coverImage!.length();
      if (fileSize > 1000000) {
        throw Exception('Kích thước ảnh không được vượt quá 1MB');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.get('API_URL')}/cloudinary'),
      );

      var stream = http.ByteStream(_coverImage!.openRead());
      var length = await _coverImage!.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: _coverImage!.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        var data = json.decode(responseData);
        return data['urls'][0];
      } else {
        var errorData = json.decode(responseData);
        String errorMessage = errorData['message'] is List
            ? errorData['message'].join(', ')
            : errorData['message']?.toString() ?? 'Lỗi không xác định';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải ảnh: $errorMessage')),
          );
        }
        return _currentCoverUrl;
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải ảnh lên: $e')),
        );
      }
      return _currentCoverUrl;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionCubit = context.read<SessionCubit>();
      final currentState = sessionCubit.state;

      if (currentState is! Authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Vui lòng đăng nhập để cập nhật truyện')),
          );
        }
        return;
      }

      final token = currentState.session.accessToken;
      String? coverUrl = await _uploadImage();

      final payload = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'author': _authorController.text,
        'status': _selectedStatus ?? widget.novel.status,
        if (coverUrl != null) 'cover': coverUrl,
      };

      final apiUrl = '${dotenv.get('API_URL')}/novels/${widget.novel.id}';

      final response = await http
          .patch(
            Uri.parse(apiUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật truyện thành công!')),
          );
        }
      } else {
        final responseData = json.decode(response.body);
        final errorMessage =
            responseData['message'] as String? ?? 'Có lỗi xảy ra';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi cập nhật truyện: $errorMessage')),
          );
        }
      }
    } catch (e) {
      print('Error updating novel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
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
        title: const Text('Sửa truyện'),
        backgroundColor: const Color(0xFF1B3A57),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 200,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _coverImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _coverImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _currentCoverUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _currentCoverUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(Icons.error, size: 50),
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate,
                                            size: 50),
                                        Text('Thay đổi ảnh bìa'),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên truyện',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên truyện';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Tác giả',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên tác giả';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mô tả';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Đang tiến hành',
                          child: Text('Đang tiến hành'),
                        ),
                        DropdownMenuItem(
                          value: 'Hoàn thành',
                          child: Text('Hoàn thành'),
                        ),
                        DropdownMenuItem(
                          value: 'Tạm ngưng',
                          child: Text('Tạm ngưng'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3A57),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          'Cập nhật truyện',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}
