import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool fromChangeLocation = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      fromChangeLocation = args['fromChangeLocation'] ?? false;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Custom SnackBar
  void _showSnackBar(String message, {Color backgroundColor = Colors.teal}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar(
        'Please enable location services',
        backgroundColor: Colors.redAccent,
      );
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showSnackBar(
        'Location permission denied',
        backgroundColor: Colors.redAccent,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
        'Permission permanently denied. Enable in settings.',
        backgroundColor: const Color.fromARGB(255, 80, 188, 173),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Get new location
    Position newLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distanceInMeters = 0.0;

    if (fromChangeLocation) {
      // Only calculate distance if changing location
      final double prevLat = 33.6844; // replace with saved previous location
      final double prevLon = 73.0479;

      distanceInMeters = Geolocator.distanceBetween(
        prevLat,
        prevLon,
        newLocation.latitude,
        newLocation.longitude,
      );

      // Determine message and color
      final bool within2km = distanceInMeters <= 2000;
      final String distanceMessage = within2km
          ? 'You are within 2 km of your previous location. Previous communities are accessible.'
          : 'You are more than 2 km away from your previous location. Previous communities may not be accessible.';

      final Color snackBarColor = within2km ? Colors.teal : Colors.amber[700]!;

      // Show beautiful SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  within2km ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    distanceMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: snackBarColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    setState(() => _isLoading = false);

    // Navigate to SelectCommunityScreen
    Navigator.pushReplacementNamed(
      context,
      '/select_community',
      arguments: {
        'distance': distanceInMeters,
        'newLocation': newLocation,
        'fromChangeLocation': fromChangeLocation,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 290,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 15, 119, 124),
                    Color.fromARGB(255, 17, 158, 144),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Center(
                    child: Image.asset(
                      'assets/whitenamelogo.png',
                      height: 130,
                      width: 130,
                    ),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  transform: Matrix4.translationValues(0, -60, 0),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Location Access 📍",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "We need your location to provide relevant data nearby.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Image.asset(
                          'assets/location.png',
                          height: 230,
                          width: 230,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              17,
                              158,
                              144,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Allow Location Access",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
