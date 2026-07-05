import 'package:flutter/material.dart';
import 'dart:math' as math;

class ImmutableWidget extends StatelessWidget {
  const ImmutableWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.greenAccent),
        foregroundDecoration: const BoxDecoration(
          backgroundBlendMode: BlendMode.colorBurn,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.greenAccent, Color(0x00000000), Colors.green],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(64),
          child: Transform.rotate(
            angle: 180 / math.pi,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.brown,
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withAlpha(120),
                    spreadRadius: 4,
                    blurRadius: 15,
                    offset: Offset.fromDirection(1.0, 30),
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: ShinyCircle(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShinyCircle extends StatelessWidget {
  const ShinyCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
          center: Alignment(-0.3, -0.5),
        ),
        boxShadow: [BoxShadow(blurRadius: 20)],
      ),
    );
  }
}
