import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:async/async.dart';
import 'dart:async';


class FutureScreen extends StatefulWidget {
  const FutureScreen({super.key});

  @override
  State<FutureScreen> createState() => _FutureScreenState();
}

class _FutureScreenState extends State<FutureScreen> {
  String result = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back from the Future')),
      body: Center(
        child: ListView(
          children: [
            ElevatedButton(
              child: const Text('GO!'),
              onPressed: () {
                
              },
            ),

            result == ''
                ? Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : Text(result),
          ],
        ),
      ),
    );
  }
}