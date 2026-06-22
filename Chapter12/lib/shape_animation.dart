import 'package:flutter/material.dart';

class ShapeAnimation extends StatefulWidget {
  const ShapeAnimation({super.key});

  @override
  State<ShapeAnimation> createState() => _ShapeAnimationState();
}

class _ShapeAnimationState extends State<ShapeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  double pos = 0;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0, end: 200).animate(controller)
      ..addListener(() {
        moveBall();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Controller'),
        actions: [
          IconButton(
            onPressed: () {
              controller.forward(from: 0);
            },
            icon: const Icon(Icons.run_circle),
          ),
        ],
      ),

      body: Stack(
        children: [Positioned(left: pos, top: pos, child: const Ball())],
      ),
    );
  }

  void moveBall() {
    setState(() {
      pos = animation.value;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Ball extends StatelessWidget {
  const Ball({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
    );
  }
}
