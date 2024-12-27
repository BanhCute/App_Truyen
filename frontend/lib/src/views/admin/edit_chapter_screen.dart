import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:frontend/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chapter.dart';
import 'dart:convert';
import 'dart:io';

class EditChapterScreen extends StatefulWidget {
  final Chapter chapter;

  const EditChapterScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  State<EditChapterScreen> createState() => _EditChapterScreenState();
}

class _EditChapterScreenState extends State<EditChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  List<String> _existingImages = [];
  List<File> _newImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chapter.name);
    _existingImages = widget.chapter.content.split('\n');
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<List<String>> _uploadNewImages() async {
    if (_newImages.isEmpty) return [];
    List<String> uploadedUrls = [];

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) return [];
      final token = state.session.accessToken;

      for (var image in _newImages) {
        try {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('${dotenv.get('API_URL')}/cloudinary/upload'),
          );

          request.headers['Authorization'] = 'Bearer $token';
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              image.path,
            ),
          );

          print('Uploading image: ${image.path}');
          print('Request headers: ${request.headers}');

          var response = await request.send();
          var responseData = await response.stream.bytesToString();
          print('Response status: ${response.statusCode}');
          print('Response data: $responseData');

          if (response.statusCode == 201) {
            var data = json.decode(responseData);
            uploadedUrls.add(data['url']);
          } else {
            print(
                'Upload failed with status ${response.statusCode}: $responseData');
          }
        } catch (e) {
          print('Error uploading single image: $e');
        }
      }
    } catch (e) {
      print('Error in _uploadNewImages: $e');
    }

    return uploadedUrls;
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final state = context.read<SessionCubit>().state;
      if (state is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để sửa chương')),
        );
        return;
      }
      final token = state.session.accessToken;

      // Upload new images
      final newImageUrls = await _uploadNewImages();
      final allImageUrls = [..._existingImages, ...newImageUrls];

      if (allImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng thêm ít nhất một ảnh')),
        );
        return;
      }

      // Update chapter
      final response = await http.put(
        Uri.parse('${dotenv.get('API_URL')}/chapters/${widget.chapter.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'content': allImageUrls.join('\n'),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật chương thành công!')),
          );
        }
      } else {
        print('Failed to update chapter: ${response.body}');
        throw Exception('Failed to update chapter');
      }
    } catch (e) {
      print('Error updating chapter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi cập nhật chương')),
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
        title: Text('Sửa chương - ${widget.chapter.name}'),
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
                      label: const Text('Thêm ảnh mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_existingImages.isNotEmpty) ...[
                      Text(
                        'Ảnh hiện tại:',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _existingImages.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              children: [
                                Image.network(
                                  _existingImages[index],
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
                                      onPressed: () =>
                                          _removeExistingImage(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    if (_newImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Ảnh mới (${_newImages.length}):',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _newImages.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              children: [
                                Image.file(
                                  _newImages[index],
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
                                      onPressed: () => _removeNewImage(index),
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
                          'Cập nhật chương',
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
