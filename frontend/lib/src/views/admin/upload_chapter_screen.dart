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
import 'package:http_parser/http_parser.dart';

class UploadChapterScreen extends StatefulWidget {
  final Novel novel;

  const UploadChapterScreen({Key? key, required this.novel}) : super(key: key);

  @override
  State<UploadChapterScreen> createState() => _UploadChapterScreenState();
}

class _UploadChapterScreenState extends State<UploadChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  List<XFile> _chapterImages = [];
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  Future<String> getToken() async {
    final state = context.read<SessionCubit>().state;
    if (state is! Authenticated) {
      throw Exception('Vui lòng đăng nhập');
    }
    return state.session.accessToken;
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _chapterImages.addAll(pickedFiles);
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

  Future<List<String>> uploadImages(List<XFile> images) async {
    if (images.isEmpty) {
      throw Exception('Vui lòng chọn ít nhất 1 ảnh');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.get('API_URL')}/cloudinary'),
      );

      final token = await getToken();
      request.headers['Authorization'] = 'Bearer $token';

      for (var image in images) {
        final bytes = await image.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response data: $responseData');

      if (response.statusCode == 201) {
        final data = json.decode(responseData);
        return List<String>.from(data['urls']);
      } else {
        throw Exception(
            'Upload failed with status ${response.statusCode}: $responseData');
      }
    } catch (e) {
      print('Error uploading images: $e');
      rethrow;
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<String> imageUrls = [];
        if (_chapterImages.isNotEmpty) {
          imageUrls = await uploadImages(_chapterImages);
        }

        final token = await getToken();
        final response = await http.post(
          Uri.parse('${dotenv.get('API_URL')}/chapters'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': _nameController.text,
            'content': imageUrls.join('\n'),
            'novelId': widget.novel.id,
          }),
        );

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm chương thành công')),
            );
            Navigator.pop(context);
          }
        } else {
          throw Exception(json.decode(response.body)['message']);
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
  }

  void _removeImage(int index) {
    setState(() {
      _chapterImages.removeAt(index);
    });
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
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _chapterImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_chapterImages[index].path),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () => _removeImage(index),
                                          constraints: const BoxConstraints(
                                            minWidth: 30,
                                            minHeight: 30,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                      onPressed: _handleSubmit,
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
