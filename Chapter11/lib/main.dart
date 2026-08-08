import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyMap());
  }
}

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late LatLng userPosition;
  late Future<LatLng> _userLocationFuture;

  @override
  initState() {
    super.initState();
    _userLocationFuture = findUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Map')),
      body: FutureBuilder<LatLng>(
        future: _userLocationFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: snapshot.data!,
                zoom: 8,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading map'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }


  Future<LatLng> findUserLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return const LatLng(51.5285582, -0.24167);
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return const LatLng(51.5285582, -0.24167);
      }
    }

    if (permissionGranted == PermissionStatus.deniedForever) {
      return const LatLng(51.5285582, -0.24167);
    }

    final userLocation = await location.getLocation();
    return LatLng(userLocation.latitude!, userLocation.longitude!);
  }
}
