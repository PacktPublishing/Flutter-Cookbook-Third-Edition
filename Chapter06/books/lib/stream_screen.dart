import 'package:flutter/material.dart';
import 'color_stream.dart';
import 'number_stream.dart';
import 'dart:async';
import 'dart:math';

class StreamScreen extends StatefulWidget {
  const StreamScreen({super.key});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  Color bgColor = Colors.blueGrey;
  ColorStream colorStream = ColorStream();
  int lastNumber = 0;
  late StreamController<int> numberStreamController;
  late NumberStream numberStream;

  @override
  void initState() {
    numberStream = NumberStream();
    numberStreamController = numberStream.controller;
    Stream stream = numberStreamController.stream;
    stream
        .listen((event) {
          setState(() {
            lastNumber = event;
          });
        })
        .onError((error) {
          setState(() {
            lastNumber = -1;
          });
        });

    super.initState();
  }

  void changeColor() async {
    // await for (var eventColor in colorStream.getColors()) {
    //   setState(() {
    //     bgColor = eventColor;
    //   });
    // }

    colorStream.getColors().listen((eventColor) {
      setState(() {
        bgColor = eventColor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stream')),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(lastNumber.toString(), style: TextStyle(fontSize: 48)),
            ElevatedButton(
              onPressed: () => addRandomNumber(),
              child: Text('New Random Number'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    numberStreamController.close();
    super.dispose();
  }

  void addRandomNumber() {
    Random random = Random();
    //int myNum = random.nextInt(10);
    //numberStream.addNumberToSink(myNum);
    numberStream.addError();
  }
}
