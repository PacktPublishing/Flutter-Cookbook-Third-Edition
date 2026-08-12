import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import './receipt.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final txtPrompt = TextEditingController();
  String result = '';
  bool isLoading = false;
  XFile? image;
  Uint8List? imageBytes;

  final schema = Schema.object(
    properties: {
      'date': Schema.string(),
      'items': Schema.array(
        items: Schema.object(
          properties: {
            'name': Schema.string(),
            'quantity': Schema.integer(),
            'unitPrice': Schema.number(),
            'total': Schema.number(),
          },
        ),
      ),
      'total': Schema.number(),
    },
  );

  Future<void> sendPrompt() async {
    // setState(() {
    //   isLoading = true;
    //   result = '';
    // });
    // try {
    //   final model = FirebaseAI.googleAI().generativeModel(
    //     model: 'gemini-flash-lite-latest',
    //   );
    //   final response = await model.generateContent([
    //     Content.text(txtPrompt.text),
    //   ]);
    //   if (!mounted) return;
    //   setState(() {
    //     result = response.text ?? 'No response';
    //   });
    // } catch (e) {
    //   if (!mounted) return;
    //   setState(() {
    //     result = 'Error: $e';
    //   });
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       isLoading = false;
    //     });
    //   }
    // }

    setState(() {
      isLoading = true;
      result = '';
    });
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-flash-lite-latest',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    if (image == null) {
      setState(() {
        result = 'Please select an image.';
        isLoading = false;
      });
      return;
    }

    final imageBytes = await image!.readAsBytes();

    final TextPart textPart = TextPart('''
    You are an expert at analyzing receipts.
    Analyze the receipt in the image and extract the following data:
    - purchase date
    - purchased items
    - quantity for each item
    - price of each item
    - total of each item
    - final general total

    Only return valid JSON.

    ''');

    final response = await model.generateContent([
      Content.multi([textPart, InlineDataPart('image/jpeg', imageBytes)]),
    ]);

    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      setState(() {
        result = 'No response from the model.';
        isLoading = false;
      });
      return;
    }

    final decodedJson = jsonDecode(response.text!);
    final receipt = Receipt.fromJson(decodedJson);
    setState(() {
      result =
          '''
      Date: ${receipt.date}
      Items: ${receipt.items.length}
      Total: ${receipt.total} ''';
      isLoading = false;
    });
  }

  Future<void> getImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    final fileName = pickedImage.name.toLowerCase();
    if (!fileName.endsWith('.jpg') && !fileName.endsWith('.jpeg')) {
      if (!mounted) return;
      setState(() {
        result = 'Please select a JPEG image.';
      });
      return;
    }

    final bytes = await pickedImage.readAsBytes();
    if (!mounted) return;

    setState(() {
      image = pickedImage;
      imageBytes = bytes;
      result = '';
    });
  }

  @override
  void dispose() {
    txtPrompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Choose Image'),
            ),
            const SizedBox(height: 16),
            if (image != null)
              SizedBox(
                height: 250,
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            // TextField(
            //   controller: txtPrompt,
            //   decoration: const InputDecoration(
            //     labelText: 'Enter prompt',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            // const SizedBox(height: 16),
            ElevatedButton(
              onPressed: image == null || isLoading ? null : sendPrompt,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Send'),
            ),
            const SizedBox(height: 16),
            Text(result),
          ],
        ),
      ),
    );
  }
}
