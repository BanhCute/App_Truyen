import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:frontend/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';

class UploadChapterScreen extends StatefulWidget {
  final Novel novel;
  const UploadChapterScreen({super.key, required this.novel});

  @override
  State<UploadChapterScreen> createState() => _UploadChapterScreenState();
}

class _UploadChapterScreenState extends State<UploadChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<File> _images = [];
  bool _isLoading = false;
  List<Chapter> _existingChapters = [];

  @override
  void initState() {
    super.initState();
    _loadExistingChapters();
  }

  Future<void> _loadExistingChapters() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _existingChapters = data
              .where(
                  (chapter) => chapter['novelId'].toString() == widget.novel.id)
              .map((json) => Chapter.fromJson(json))
              .toList();

          // Sắp xếp chương theo số thứ tự
          _existingChapters.sort((a, b) {
            try {
              final aNum = int.parse(a.name.replaceAll(RegExp(r'[^0-9]'), ''));
              final bNum = int.parse(b.name.replaceAll(RegExp(r'[^0-9]'), ''));
              return aNum.compareTo(bNum);
            } catch (e) {
              return 0;
            }
          });
        });
      }
    } catch (e) {
      print('Error loading chapters: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _images.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return [];
    List<String> uploadedUrls = [];
    int maxRetries = 3;

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) return [];
      final token = state.session.accessToken;

      for (var image in _images) {
        int retryCount = 0;
        bool uploadSuccess = false;

        while (retryCount < maxRetries && !uploadSuccess) {
          try {
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('${dotenv.get('API_URL')}/cloudinary'),
            );

            request.headers['Authorization'] = 'Bearer $token';
            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
                image.path,
                contentType: MediaType('image', 'jpeg'),
              ),
            );

            var streamedResponse = await request.send().timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw TimeoutException('Quá thời gian tải lên');
              },
            );

            var response = await http.Response.fromStream(streamedResponse);
            print('Response status: ${response.statusCode}');
            print('Response data: ${response.body}');

            if (response.statusCode == 201) {
              var data = json.decode(response.body);
              uploadedUrls.add(data['urls'][0]);
              uploadSuccess = true;
            } else {
              print(
                  'Upload failed with status ${response.statusCode}: ${response.body}');
              retryCount++;
              if (retryCount < maxRetries) {
                await Future.delayed(
                    Duration(seconds: 2 * retryCount)); // Exponential backoff
              }
            }
          } catch (e) {
            print('Error uploading image: $e');
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(Duration(seconds: 2 * retryCount));
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Không thể tải lên ảnh sau $maxRetries lần thử. Vui lòng thử lại sau.'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error in _uploadImages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Có lỗi xảy ra khi tải lên ảnh. Vui lòng thử lại sau.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    return uploadedUrls;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ảnh')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thêm chương')),
        );
        return;
      }
      final token = state.session.accessToken;

      // Upload images
      final imageUrls = await _uploadImages();
      if (imageUrls.isEmpty) {
        throw Exception('Không thể tải lên ảnh');
      }

      // Create chapter
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'content': imageUrls.join('\n'),
          'novelId': int.parse(widget.novel.id),
        }),
      );

      if (response.statusCode == 201) {
        // Cập nhật thời gian cập nhật của truyện
        await http.patch(
          Uri.parse('${dotenv.get('API_URL')}/novels/${widget.novel.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'updatedAt': DateTime.now().toIso8601String(),
          }),
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm chương thành công!')),
          );
        }
      } else {
        throw Exception('Không thể thêm chương');
      }
    } catch (e) {
      print('Error creating chapter: $e');
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
        title: Text('Thêm chương - ${widget.novel.name}'),
        backgroundColor: const Color.fromARGB(255, 230, 240, 236),
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
                    // Hiển thị thông tin truyện
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin truyện:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text('Tác giả: ${widget.novel.author}'),
                            Text('Trạng thái: ${widget.novel.status}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hiển thị danh sách chương hiện có
                    if (_existingChapters.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Các chương hiện có:',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _existingChapters.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_existingChapters[index].name),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên chương',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên chương';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Chọn ảnh  '),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_images.isNotEmpty) ...[
                      Text(
                        'Ảnh đã chọn (${_images.length}):',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              children: [
                                Image.file(
                                  _images[index],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 230, 240, 236),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          'Thêm chương',
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
    super.dispose();
  }
}
