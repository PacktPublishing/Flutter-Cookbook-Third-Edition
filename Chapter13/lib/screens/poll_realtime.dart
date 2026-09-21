import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PollRealtimeScreen extends StatefulWidget {
  const PollRealtimeScreen({super.key});

  @override
  State<PollRealtimeScreen> createState() => _PollRealtimeScreenState();
}

class _PollRealtimeScreenState extends State<PollRealtimeScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('poll');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poll (Realtime DB)')),
      body: Center(
        child: StreamBuilder(
          stream: ref.onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.data!.snapshot.value == null) {
              return const CircularProgressIndicator();
            }

            final data =
                snapshot.data!.snapshot.value as Map;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ice-cream: ${data['icecream']}'),
                Text('Pizza: ${data['pizza']}'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.icecream),
                  label: const Text('Ice-cream'),
                  onPressed: () => vote(false),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_pizza),
                  label: const Text('Pizza'),
                  onPressed: () => vote(true),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> vote(bool voteForPizza) async {
    final String field = voteForPizza ? 'pizza' : 'icecream';

    await ref.child(field).runTransaction((value) {
      final current = (value as int?) ?? 0;
      return Transaction.success(current + 1);
    });
  }
}
