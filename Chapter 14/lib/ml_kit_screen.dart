import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MLKitScreen extends StatefulWidget {
  const MLKitScreen({super.key});

  @override
  State<MLKitScreen> createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen> {
  File? image;
  String result = '';
  bool isProcessing = false;
  late final TextRecognizer textRecognizer;
  late final ImageLabeler imageLabeler;
  late final FaceDetector faceDetector;

  Future<void> getImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );

    if (pickedImage == null) return;

    setState(() {
      image = File(pickedImage.path);
    });
  }

  Future<String> textFromImage(File image) async {
    final InputImage inputImage = InputImage.fromFile(image);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    return recognizedText.text;
  }

  Future<String> labelImage(File image) async {
    String result = '';
    final InputImage inputImage = InputImage.fromFile(image);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      result += '$index: $text - ${confidence * 100}% \n';
    }
    return result;
  }

  Future<String> detectFace(File image) async {
    String result = '';
    final InputImage inputImage = InputImage.fromFile(image);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    result = 'There are ${faces.length} face(s) in your picture. \n';
    for (int i = 0; i < faces.length; i++) {
      final Face face = faces[i];
      result += 'Face ${i + 1}\n';
      result += 'Bounding box: ${face.boundingBox}\n';
      final smiling = face.smilingProbability;
      final leftEyeOpen = face.leftEyeOpenProbability;
      final rightEyeOpen = face.rightEyeOpenProbability;
      if (smiling != null) {
        result += 'Smiling: ${(smiling * 100).toStringAsFixed(1)}%\n';
      }
      if (leftEyeOpen != null) {
        result += 'Left eye open: ${(leftEyeOpen * 100).toStringAsFixed(1)}%\n';
      }
      if (rightEyeOpen != null) {
        result +=
            'Right eye open: ${(rightEyeOpen * 100).toStringAsFixed(1)}%\n';
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer();
    imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.7),
    );
    final faceDetectorOptions = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableClassification: true,
    );
    faceDetector = FaceDetector(options: faceDetectorOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ML Kit Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => getImage(ImageSource.camera),
                    child: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => getImage(ImageSource.gallery),
                    child: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (image != null)
              SizedBox(
                height: 300,
                child: Image.file(image!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (image == null || isProcessing) return;
                isProcessing = true;
                final text = await textFromImage(image!);
                setState(() {
                  result = text;
                  isProcessing = false;
                });
              },
              child: const Text('Text Recognition'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (image == null || isProcessing) return;
                isProcessing = true;
                final labels = await labelImage(image!);
                setState(() {
                  result = labels;
                  isProcessing = false;
                });
              },
              child: const Text('Image Labeling'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (image == null || isProcessing) return;
                isProcessing = true;  
                final faces = await detectFace(image!);
                setState(() {
                  result = faces;
                  isProcessing = false;
                });
              },
              child: const Text('Face Detection'),
            ),
            const SizedBox(height: 16),
            Text(result),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textRecognizer.close();
    imageLabeler.close();
    faceDetector.close();
    super.dispose();
  }
}
