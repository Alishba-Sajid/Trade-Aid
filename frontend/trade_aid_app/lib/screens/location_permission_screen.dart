// lib/location_permission.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'select_community.dart';
import 'create_community.dart';

const Color kPrimaryTeal = Color(0xFF004D40);

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;
  String? _statusMessage;

  // Timeout durations
  static const Duration gpsTimeout = Duration(seconds: 12);
  static const Duration lowAccuracyTimeout = Duration(seconds: 6);

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // 1️⃣ Check if service enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Please enable location services (GPS) and try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      // 2️⃣ Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Location permission denied';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Permission permanently denied. Enable location permission from app settings.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Permission permanently denied. Enable in settings.')),
        );
        return;
      }

      // 3️⃣ Try last known position first (fast)
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _goToSelect(position);
        return;
      }

      // 4️⃣ High-accuracy GPS fix
      try {
        position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .timeout(gpsTimeout);
        _goToSelect(position);
        return;
      } on TimeoutException {
        print('High accuracy GPS timed out');
      }

      // 5️⃣ Lower-accuracy attempt
      try {
        position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.medium)
            .timeout(lowAccuracyTimeout);
        _goToSelect(position);
        return;
      } on TimeoutException {
        print('Medium accuracy GPS timed out');
      }

      // 6️⃣ Fallback: stream
      position = await _getFirstPositionFromStream(Duration(seconds: 5));
      if (position != null) {
        _goToSelect(position);
        return;
      }

      // 7️⃣ Nothing worked
      setState(() {
        _isLoading = false;
        _statusMessage =
            'Unable to acquire location automatically. Please enter manually.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get location. Try again.')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Location error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e')),
      );
    }
  }

  Future<Position?> _getFirstPositionFromStream(Duration duration) async {
    final completer = Completer<Position?>();
    StreamSubscription<Position>? sub;
    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((pos) {
      if (!completer.isCompleted) {
        completer.complete(pos);
        sub?.cancel();
      }
    }, onError: (_) {
      if (!completer.isCompleted) completer.complete(null);
      sub?.cancel();
    });

    Future.delayed(duration).then((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
        sub?.cancel();
      }
    });

    return completer.future;
  }

  // ✅ Fetch nearby communities and navigate
  void _goToSelect(Position position) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // ⚠️ Use your LAN IP, not localhost
      final url = Uri.parse(
          'http://192.168.18.29:5000/api/communities?lat=${position.latitude}&lon=${position.longitude}');
      print('Fetching nearby communities: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          // Nearby communities found → show select screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCommunityScreen(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            ),
          );
        } else {
          // No communities → show create screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateCommunityScreen(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            ),
          );
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching communities: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateCommunityScreen(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Location Access"),
        backgroundColor: kPrimaryTeal,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: kPrimaryTeal, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Enable Location Access",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _statusMessage ??
                  "We need your location to find nearby communities.",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: kPrimaryTeal)
                : ElevatedButton(
                    onPressed: _requestLocationPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: const Text(
                      "Allow Location Access",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectCommunityScreen(
                      latitude: 0,
                      longitude: 0,
                    ),
                  ),
                );
              },
              child: const Text('Enter location manually (fallback)'),
            ),
          ],
        ),
      ),
    );
  }
}
