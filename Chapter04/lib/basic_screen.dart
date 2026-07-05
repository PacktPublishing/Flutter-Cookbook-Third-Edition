import 'package:flutter/material.dart';
import 'package:flutter_layout/like_button.dart';
import 'package:flutter_layout/text_layout.dart';

class BasicScreen extends StatefulWidget {
  const BasicScreen({super.key});

  @override
  State<BasicScreen> createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  bool showLikeButton = true;
  @override
  Widget build(BuildContext context) {
    debugPrint('Building BasicScreen');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Welcome to Flutter'),
        actions: [
          IconButton(
            icon: Icon(
              showLikeButton ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                showLikeButton = !showLikeButton;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.lightBlue,
          child: Center(child: Text("I'm a Drawer!")),
        ),
      ),
      body: Column(
        children: [
          Semantics(
            image: true,
            label: 'A beautiful beach',
            child: Image.asset('assets/beach.jpg'),
          ),
          if (showLikeButton) const LikeButton(),
          TextLayout(),
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                child: const Text('Open the drawer'),
              );
            },
          ),
        ],
      ),
    );
  }
}
