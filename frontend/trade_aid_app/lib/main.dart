import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_profile.dart';
import 'screens/location_permission_screen.dart';
import 'screens/select_community.dart';
import 'screens/create_account.dart';

void main() {
  runApp(const TradeAidApp());
}

class TradeAidApp extends StatelessWidget {
  const TradeAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trade & Aid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // start from the splash explicitly
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const CreateAccountScreen(),
        '/create_profile': (context) => const CreateProfileScreen(),
        '/location_permission': (context) => const LocationAccessScreen(),
        '/select_community': (context) => const SelectCommunityScreen(),
        '/home': (context) =>
            const SelectCommunityScreen(), // change later if you add a real home
      },
    );
  }
}
