import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final File? initialImage;
  final ValueChanged<File?> onImageSelected;
  final bool enabled;
  final double size;

  const ImagePickerWidget({
    super.key,
    this.initialImage,
    required this.onImageSelected,
    this.enabled = true,
    this.size = 120,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.onImageSelected(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _pickImage : null,
      child:
          _image != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _image!,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.cover,
                ),
              )
              : Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
    );
  }
}
