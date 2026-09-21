import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  Future<void> vote(bool voteForPizza) async {
    final db = FirebaseFirestore.instance;
    final collection = db.collection('poll');

    final query = await collection
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return;
    }

    final docRef = query.docs.first.reference;

    await docRef.update({
      voteForPizza ? 'pizza' : 'icecream': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poll')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.icecream),
              label: const Text('Ice-cream'),
              onPressed: () {
                vote(false);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_pizza),
              label: const Text('Pizza'),
              onPressed: () {
                vote(true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
