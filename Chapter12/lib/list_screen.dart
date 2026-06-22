import 'package:flutter/material.dart';
import 'detail_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  final List<String> drinks = const ['Coffee', 'Tea', 'Cappuccino', 'Espresso'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Animation')),
      body: ListView.builder(
        itemCount: drinks.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Hero(
              tag: 'cup$index',
              child: const Icon(Icons.free_breakfast),
            ),
            title: Text(drinks[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailScreen(index: index, drink: drinks[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
