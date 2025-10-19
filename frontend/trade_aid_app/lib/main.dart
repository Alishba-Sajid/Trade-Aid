// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_profile.dart';
import 'screens/location_permission_screen.dart';
import 'screens/select_community.dart';
import 'screens/create_account.dart';
import 'screens/dashboard.dart';
import 'screens/product_listing.dart';
import 'screens/product_details.dart';
import 'screens/resource_listing.dart';
import 'screens/resource_details.dart';
import 'screens/booking_screen.dart';
import 'screens/book_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/product_post.dart';
import 'screens/resource_post.dart';
// models
import 'models/product.dart';
import 'models/resource.dart';

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
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const CreateAccountScreen(),
        '/create_profile': (context) => const CreateProfileScreen(),
        '/location_permission': (context) => const LocationAccessScreen(),
        '/select_community': (context) => const SelectCommunityScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/products': (context) => const ProductListingScreen(),
        '/resources': (context) => const ResourceListingScreen(),
        '/books': (context) => const BookScreen(),
        '/cart': (context) => const CartScreen(),
        // <-- added posting routes
        '/product_post': (context) => const ProductPostScreen(),
        '/resource_post': (context) => const ResourcePostScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_details') {
          final args = settings.arguments as Map<String, dynamic>;
          final product = args['product'] as Product;
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
            settings: settings,
          );
        }

        if (settings.name == '/resource_details') {
          final args = settings.arguments as Map<String, dynamic>;
          final resource = args['resource'] as Resource;
          return MaterialPageRoute(
            builder: (_) => ResourceDetailsScreen(resource: resource),
            settings: settings,
          );
        }

        if (settings.name == '/booking') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              resourceId: args['resourceId'],
              resourceName: args['resourceName'],
            ),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}