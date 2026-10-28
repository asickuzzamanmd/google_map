import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RealTimeLocationTracker(),
    );
  }
}

class RealTimeLocationTracker extends StatefulWidget {
  const RealTimeLocationTracker({super.key});

  @override
  State<RealTimeLocationTracker> createState() => _RealTimeLocationTrackerState();
}

class _RealTimeLocationTrackerState extends State<RealTimeLocationTracker> {
  GoogleMapController? _mapController;
  Timer? _timer;

  // Initial Default fallback location (Dhaka)
  LatLng _currentLatLng = const LatLng(23.7216, 90.4165);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(23.7216, 90.4165),
    zoom: 16.0,
  );

  @override
  void initState() {
    super.initState();
    _polylineCoordinates.add(_currentLatLng);
    _updateUiComponents(_currentLatLng);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTrackingProcess();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startTrackingProcess() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // Initial Fetch
      await _fetchLocationSafely();

      // Fetch location every 10 seconds
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _fetchLocationSafely();
      });
    } catch (e) {
      debugPrint("Location initialization error: $e");
    }
  }

  Future<void> _fetchLocationSafely() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      LatLng newLatLng = LatLng(position.latitude, position.longitude);
      _updateUiComponents(newLatLng);
    } catch (e) {
      debugPrint("Location fetch timeout or error: $e");
    }
  }

  void _updateUiComponents(LatLng newLatLng) {
    if (!mounted) return;

    setState(() {
      _currentLatLng = newLatLng;
      if (!_polylineCoordinates.contains(newLatLng)) {
        _polylineCoordinates.add(newLatLng);
      }

      // Marker Update with Info Window
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location_marker'),
          position: newLatLng,
          infoWindow: InfoWindow(
            title: 'My current location',
            snippet: '${newLatLng.latitude}, ${newLatLng.longitude}',
          ),
        ),
      );

      // Polyline Update
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('tracking_polyline'),
          points: List.from(_polylineCoordinates),
          color: Colors.blueAccent,
          width: 5,
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: newLatLng, zoom: 16.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real-Time Location Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}