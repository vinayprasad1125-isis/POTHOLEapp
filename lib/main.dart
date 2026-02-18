import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'pothole.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final PotholeDetector detector = PotholeDetector();

  LatLng? _currentPosition;
  final Set<Marker> _markers = {};

  double ax = 0, ay = 0, az = 0;
  bool potholeDetected = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();

    detector.startListening(
      (x, y, z) {
        setState(() {
          ax = x;
          ay = y;
          az = z;
        });
      },
      _showPotholeAlert,
    );
  }

  void _showPotholeAlert() {
    setState(() {
      potholeDetected = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        potholeDetected = false;
      });
    });
  }

  @override
  void dispose() {
    detector.stopListening();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    var permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();

    final userLatLng = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _currentPosition = userLatLng;
      _markers
        ..clear()
        ..add(Marker(markerId: const MarkerId('me'), position: userLatLng));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
          ),

          // 📊 Sensor values
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                "X: ${ax.toStringAsFixed(2)}\n"
                "Y: ${ay.toStringAsFixed(2)}\n"
                "Z: ${az.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // 🚧 Pothole alert
          if (potholeDetected)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.red.withOpacity(0.8),
                child: const Text(
                  "🚧 POTHOLE DETECTED!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}