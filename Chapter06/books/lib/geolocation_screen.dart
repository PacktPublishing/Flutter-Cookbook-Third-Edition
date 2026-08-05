import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocationScreen extends StatefulWidget {
  const GeoLocationScreen({super.key});

  @override
  State<GeoLocationScreen> createState() => _GeoLocationScreenState();
}

class _GeoLocationScreenState extends State<GeoLocationScreen> {
  late final Future<Position> _positionFuture;
  @override
  void initState() {
    super.initState();
    _positionFuture = getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Current Location')),
      body: Center(
        child: FutureBuilder(
          future: _positionFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Something terrible happened!');
              }
              return Text(snapshot.data.toString());
            } else {
              return const Text('');
            }
          },
        ),
      ),
    );
  }

  Future<Position> getPosition() async {
    await Geolocator.requestPermission();
    await Geolocator.isLocationServiceEnabled();
    Position? position = await Geolocator.getCurrentPosition();
    return position;
  }
}
