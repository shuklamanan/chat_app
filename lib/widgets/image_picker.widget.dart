import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) onpickimage;

  const UserImagePicker({super.key, required this.onpickimage});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedimageFile;

  void _pickimage() async {
    final pickedimage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pickedimage == null) {
      return;
    }
    setState(() {
      _pickedimageFile = File(pickedimage.path);
    });

    widget.onpickimage(_pickedimageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedimageFile != null
              ? FileImage(_pickedimageFile!)
              : null, //here FileImage uses instead of Image.file because image.file generates widget while foregroundimage wants imageprovider
        ),
        TextButton.icon(
            onPressed: _pickimage,
            icon: const Icon(Icons.image),
            label: Text(
              'Add Image',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            )),
      ],
    );
  }
}
