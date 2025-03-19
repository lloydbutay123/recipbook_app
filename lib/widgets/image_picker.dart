import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyImagePicker extends StatelessWidget {
  const MyImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _pickImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Return a widget that displays the selected image
            return Image.file(snapshot.data!);
          } else {
            // Return a widget that displays a loading indicator or an error message
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<File?> _pickImage() async {
    final ImagePicker _picker =
        ImagePicker(); // Renamed the instance to _picker
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
