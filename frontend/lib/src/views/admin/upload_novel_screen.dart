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

class UploadNovelScreen extends StatefulWidget {
  const UploadNovelScreen({Key? key}) : super(key: key);

  @override
  State<UploadNovelScreen> createState() => _UploadNovelScreenState();
}

class _UploadNovelScreenState extends State<UploadNovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  String? _selectedStatus = 'Đang tiến hành';
  File? _coverImage;
  bool _isLoading = false;
  int _retryCount = 0; // Đếm số lần thử lại

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        // Nén ảnh trước khi lưu
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
            });
          } else {
            // Nếu nén thất bại, sử dụng file gốc
            setState(() {
              _coverImage = originalFile;
            });
          }
        } catch (e) {
          print('Error compressing image: $e');
          // Nếu có lỗi khi nén, sử dụng file gốc
          setState(() {
            _coverImage = originalFile;
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
    if (_coverImage == null) return null;

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) return null;
      final token = state.session.accessToken;

      // Kiểm tra kích thước file
      final fileSize = await _coverImage!.length();
      if (fileSize > 1000000) {
        throw Exception('Kích thước ảnh không được vượt quá 1MB');
      }

      // Tạo form data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.get('API_URL')}/cloudinary'),
      );

      // Thêm file vào form với đúng field name
      var stream = http.ByteStream(_coverImage!.openRead());
      var length = await _coverImage!.length();
      var multipartFile = http.MultipartFile(
        'image', // Đảm bảo tên field khớp với DTO
        stream,
        length,
        filename: _coverImage!.path.split('/').last,
        contentType: MediaType('image', 'jpeg'), // Thêm content type
      );
      request.files.add(multipartFile);

      // Thêm headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      print('Sending request to: ${request.url}');
      print('File size: $length bytes');
      print('Headers: ${request.headers}');

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response data: $responseData');

      if (response.statusCode == 201) {
        var data = json.decode(responseData);
        return data['url'];
      } else {
        var errorData = json.decode(responseData);
        String errorMessage = errorData['message'] is List
            ? errorData['message'].join(', ')
            : errorData['message']?.toString() ?? 'Lỗi không xác định';

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi tải ảnh'),
            content: Text('$errorMessage\n\nHệ thống sẽ sử dụng ảnh mặc định.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đồng ý'),
              ),
            ],
          ),
        );

        // Trả về URL ảnh mặc định
        return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqIaD4wuVHsK6dbGQlEC4MBycX72MfyVLoMg&s';
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text(
                'Không thể tải ảnh lên: $e\n\nHệ thống sẽ sử dụng ảnh mặc định.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đồng ý'),
              ),
            ],
          ),
        );
      }
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqIaD4wuVHsK6dbGQlEC4MBycX72MfyVLoMg&s';
    }
  }

  Future<void> _checkApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/novels'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('GET /novels status: ${response.statusCode}');
      print('GET /novels headers: ${response.headers}');
      print('GET /novels body: ${response.body}');
    } catch (e) {
      print('Error checking API: $e');
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
      print('Current session state: $currentState');

      if (currentState is! Authenticated) {
        print('Not authenticated');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để đăng truyện')),
          );
        }
        return;
      }

      final token = currentState.session.accessToken;
      print('Token: $token');

      // Upload ảnh nếu có
      String? coverUrl;
      if (_coverImage != null) {
        print('File name: ${_coverImage!.path.split('/').last}');
        print('File size: ${await _coverImage!.length()} bytes');
        print('Content-Type: multipart/form-data');

        coverUrl = await _uploadImage();
        print('Cover URL after upload: $coverUrl');

        if (coverUrl == null) {
          print('Upload failed, using default image');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không thể tải lên ảnh bìa')),
            );
          }
          return;
        }
      }

      // Tạo payload
      final payload = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'author': _authorController.text,
        'status': _selectedStatus ?? 'Đang tiến hành',
        'cover': coverUrl ??
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqIaD4wuVHsK6dbGQlEC4MBycX72MfyVLoMg&s',
        'userId': currentState.session.user.id,
      };

      final apiUrl = '${dotenv.get('API_URL')}/novels';
      print('Creating novel with payload: ${json.encode(payload)}');
      print('API URL: $apiUrl');
      print(
          'Request headers: {Authorization: Bearer $token, Accept: application/json, Content-Type: application/json}');

      try {
        print('Sending POST request to $apiUrl');
        final response = await http
            .post(
              Uri.parse(apiUrl),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 30));

        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('Novel created successfully');
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng truyện thành công!')),
            );
          }
        } else {
          print('Got error response: ${response.statusCode}');
          final responseData = json.decode(response.body);
          final errorMessage =
              responseData['message'] as String? ?? 'Có lỗi xảy ra';
          print('Error message: $errorMessage');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi đăng truyện: $errorMessage')),
            );
          }
        }
      } catch (e) {
        print('HTTP request failed: $e');
        if (e is TimeoutException) {
          print('Request timed out');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Kết nối tới server quá lâu, vui lòng thử lại')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi kết nối: $e')),
            );
          }
        }
      }
    } catch (e) {
      print('Error creating novel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi đăng truyện')),
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
        title: const Text('Đăng truyện mới'),
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
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_photo_alternate, size: 50),
                                    Text('Thêm ảnh bìa'),
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
                          'Đăng truyện',
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
