import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:frontend/models/session.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
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
  double _uploadProgress = 0.0;

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

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    return File(result?.path ?? file.path);
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

      // Nén tất cả ảnh
      setState(() {
        _uploadProgress = 0.1;
      });

      List<File> compressedImages = [];
      for (var i = 0; i < _chapterImages.length; i++) {
        final compressed = await _compressImage(_chapterImages[i]);
        compressedImages.add(compressed);
        setState(() {
          _uploadProgress = 0.1 + (0.3 * (i + 1) / _chapterImages.length);
        });
      }

      // Tạo form data với nhiều file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.get('API_URL')}/cloudinary'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Thêm tất cả ảnh vào request
      for (var i = 0; i < compressedImages.length; i++) {
        final file = compressedImages[i];
        request.files.add(
          await http.MultipartFile.fromPath('image', file.path),
        );
        setState(() {
          _uploadProgress = 0.4 + (0.5 * (i + 1) / compressedImages.length);
        });
      }

      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        if (data['urls'] != null) {
          uploadedUrls = List<String>.from(data['urls']);
        }
      } else {
        print('Upload failed with status ${response.statusCode}');
        print('Error response: ${response.body}');
        throw Exception('Lỗi khi tải ảnh lên: ${response.body}');
      }

      setState(() {
        _uploadProgress = 1.0;
      });

      // Xóa các file đã nén
      for (var file in compressedImages) {
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error in _uploadImages: $e');
      rethrow;
    }

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
      _uploadProgress = 0.0;
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
          'novelId': int.parse(widget.novel.id.toString()),
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
          SnackBar(content: Text('Có lỗi xảy ra: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 0.0;
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải lên... ${(_uploadProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                            key: _formKey,
                            child: TextFormField(
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
                              'Ảnh đã chọn (${_chapterImages.length}):',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              _chapterImages.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _chapterImages[index],
                                          width: double.infinity,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.red,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 20,
                                            icon: const Icon(Icons.close,
                                                color: Colors.white),
                                            onPressed: () =>
                                                _removeImage(index),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A57),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Thêm chương',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
