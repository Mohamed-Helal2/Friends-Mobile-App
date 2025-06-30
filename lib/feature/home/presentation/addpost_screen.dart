import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test1/feature/home/logic/cubit/home_cubit.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateButtonState);
    _contentController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _hasContent =>
      _contentController.text.trim().isNotEmpty || _selectedImage != null;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _submitPost(BuildContext context) {
    final content = _contentController.text.trim();
    context.read<HomeCubit>().addPost(content, _selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeSuccess) {
            _contentController.clear();
            _selectedImage = null;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Post published successfully"),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is HomeError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Failed to publish post}")));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed:
                              _hasContent && state is! HomeLoading
                                  ? () => _submitPost(context)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _hasContent ? Colors.green : Colors.grey,
                          ),
                          child: Text("Add Post"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage != null) ...[
                        Stack(
                          children: [
                            Image.file(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton.icon(
                        onPressed: state is HomeLoading ? null : _pickImage,
                        icon: const Icon(
                          Icons.add_a_photo_sharp,
                          color: Color.fromARGB(255, 1, 85, 4),
                        ),
                        label: const Text('Add Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            114,
                            159,
                            233,
                          ),
                          foregroundColor: const Color.fromARGB(255, 31, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state is HomeLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
