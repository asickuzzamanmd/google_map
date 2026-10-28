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

  // শুরুর ডিফল্ট লোকেশন
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
    _setMarkerAndPolyline(_currentLatLng);
    _initTracker();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initTracker() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // প্রতি ১০ সেকেন্ড পর পর নতুন লোকেশন চেক
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        _updateLocationOnMap(LatLng(position.latitude, position.longitude));
      } catch (e) {
        debugPrint("Location update check: $e");
      }
    });
  }

  void _updateLocationOnMap(LatLng newLatLng) {
    if (!mounted) return;

    setState(() {
      _currentLatLng = newLatLng;
      _polylineCoordinates.add(newLatLng);
      _setMarkerAndPolyline(newLatLng);
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: newLatLng, zoom: 16.5),
      ),
    );
  }

  void _setMarkerAndPolyline(LatLng latLng) {
    // মার্কার আপডেট (Info Window সহ)
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: latLng,
        infoWindow: InfoWindow(
          title: 'My current location',
          snippet: '${latLng.latitude}, ${latLng.longitude}',
        ),
      ),
    );

    // পলিলিন আপডেট
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('track_line'),
        points: List.from(_polylineCoordinates),
        color: Colors.blueAccent,
        width: 5,
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
        zoomControlsEnabled: true,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}