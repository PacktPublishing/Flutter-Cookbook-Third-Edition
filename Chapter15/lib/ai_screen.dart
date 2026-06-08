import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final txtPrompt = TextEditingController();
  String result = '';
  bool isLoading = false;
  File? image;

  final schema = Schema.object(
    properties: {
      'date': Schema.string(),
      'items': Schema.array(
        items: Schema.object(
          properties: {
            'name': Schema.string(),
            'quantity': Schema.number(),
            'unitPrice': Schema.number(),
            'total': Schema.number(),
          },
        ),
      ),
      'total': Schema.number(),
    },
  );

  Future<void> sendPrompt() async {
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
      Content.multi([
        textPart,
        InlineDataPart('image/jpeg', imageBytes),
      ]),
    ]);

    final decodedJson = jsonDecode(response.text ?? '{}');

    setState(() {
      result = decodedJson.toString();
      isLoading = false;
    });
  }

  Future<void> getImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    setState(() {
      image = File(pickedImage.path);
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
                child: Image.file(image!, fit: BoxFit.cover),
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
