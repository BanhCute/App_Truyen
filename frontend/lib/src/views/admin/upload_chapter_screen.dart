import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:frontend/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/novel.dart';
import 'dart:convert';
import 'dart:io';

class UploadChapterScreen extends StatefulWidget {
  final Novel novel;

  const UploadChapterScreen({Key? key, required this.novel}) : super(key: key);

  @override
  State<UploadChapterScreen> createState() => _UploadChapterScreenState();
}

class _UploadChapterScreenState extends State<UploadChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<File> _chapterImages = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _chapterImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_chapterImages.isEmpty) return [];
    List<String> uploadedUrls = [];

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        print('Not authenticated');
        return [];
      }
      final token = state.session.accessToken;
      print('Token: $token');

      for (var image in _chapterImages) {
        try {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('${dotenv.get('API_URL')}/cloudinary'),
          );

          // Thêm form field 'image'
          var multipartFile =
              await http.MultipartFile.fromPath('image', image.path);
          request.files.add(multipartFile);

          // Thêm headers
          request.headers.addAll({
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });

          // Thêm form fields
          request.fields.addAll({'type': 'chapter', 'folder': 'images'});

          print('Uploading image: ${image.path}');
          print('Request URL: ${request.url}');
          print('Request headers: ${request.headers}');
          print('File field name: ${multipartFile.field}');
          print('File length: ${multipartFile.length}');

          var streamedResponse = await request.send();
          var response = await http.Response.fromStream(streamedResponse);

          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');

          if (response.statusCode == 201) {
            var data = json.decode(response.body);
            print('Parsed response data: $data');
            if (data['url'] != null) {
              uploadedUrls.add(data['url']);
              print('Added URL: ${data['url']}');
            } else {
              print('URL not found in response data');
            }
          } else {
            print('Upload failed with status ${response.statusCode}');
            print('Error response: ${response.body}');
          }
        } catch (e, stackTrace) {
          print('Error uploading single image: $e');
          print('Stack trace: $stackTrace');
        }
      }
    } catch (e, stackTrace) {
      print('Error in _uploadImages: $e');
      print('Stack trace: $stackTrace');
    }

    print('Final uploaded URLs: $uploadedUrls');
    return uploadedUrls;
  }

  void _removeImage(int index) {
    setState(() {
      _chapterImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_chapterImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một ảnh')),
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

      // Upload all images
      final imageUrls = await _uploadImages();
      if (imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi tải ảnh lên')),
        );
        return;
      }

      // Create chapter with all image URLs
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/chapters'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'content': imageUrls.join('\n'),
          'novelId': widget.novel.id,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm chương thành công!')),
          );
        }
      } else {
        print('Failed to create chapter: ${response.body}');
        throw Exception('Failed to create chapter');
      }
    } catch (e) {
      print('Error creating chapter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi thêm chương')),
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
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Thêm ảnh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_chapterImages.isNotEmpty) ...[
                      Text(
                        'Đã chọn ${_chapterImages.length} ảnh:',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _chapterImages.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              children: [
                                Image.file(
                                  _chapterImages[index],
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
                          backgroundColor: const Color(0xFF1B3A57),
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
