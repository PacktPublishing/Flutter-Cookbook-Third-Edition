import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  File? _image;
  String _message = '';
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload to Firebase Storage')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                getImage();
              },
              child: const Text('Choose Image'),
            ),
            SizedBox(
              height: 200,
              child: _image == null
                  ? const Center(child: Icon(Icons.image, size: 48))
                  : Image.file(_image!),
            ),
            ElevatedButton(
              onPressed: () {
                uploadImage();
              },
              child: const Text('Upload Image'),
            ),
            Text(_message),
          ],
        ),
      ),
    );
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    } else {
      debugPrint('No image selected.');
    }
  }

  Future<void> uploadImage() async {
    if (_image != null) {
      final String fileName = basename(_image!.path);
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference ref = storage.ref().child(fileName);

      setState(() {
        _message = 'Uploading file. Please wait...';
      });
      try {
        final TaskSnapshot result = await ref.putFile(_image!);
        if (!mounted) return;
        setState(() {
          _message = result.state == TaskState.success
              ? 'File uploaded successfully'
              : 'Error uploading file';
        });
      } on FirebaseException catch (e) {
        if (!mounted) return;
        setState(() {
          _message = 'Error uploading file: ${e.message}';
        });
      }
    }
  }
}
