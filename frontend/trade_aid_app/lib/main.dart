// lib/main.dart
import 'package:flutter/material.dart';

// screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_profile.dart';
import 'screens/location_permission_screen.dart';
import 'screens/select_community.dart';
import 'screens/create_account.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/dashboard/notification_screen.dart';
import 'screens/product_listing.dart';
import 'screens/product_details.dart';
import 'screens/resource_listing.dart';
import 'screens/resource_details.dart';
import 'screens/booking_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/product_post.dart';
import 'screens/resource_post.dart';
import 'screens/profile/profile.dart';
import 'screens/profile/personaldetailsprofile.dart';
import 'screens/profile/changepassword.dart';
import 'screens/profile/blocked_user.dart';
import 'screens/help&support.dart';
import 'screens/wish_request.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/profile/terms&conditions.dart';
import 'screens/welcomeT&C.dart';
import 'screens/profile/history_screen.dart';
import 'screens/forgotpass/forget_pass_screen.dart';
import 'screens/forgotpass/verifycode_screen.dart';
import 'screens/forgotpass/newpass_screen.dart';
import 'screens/chat/chat_screen.dart';

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
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const CreateAccountScreen(),
        '/create_profile': (_) => const CreateProfileScreen(),
        '/location_permission': (_) => const LocationPermissionScreen(),
        '/select_community': (_) => const SelectCommunityScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/products': (_) => const ProductListingScreen(),
        '/resources': (_) => const ResourceListingScreen(),
         '/cart': (_) => const CartScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/personal_details': (_) => const PersonalDetailsScreen(),
        '/change_password': (_) => const ChangePasswordScreen(),
        '/terms_conditions': (_) => const TermsAndConditionsScreen(),
        '/welcome_terms': (_) => const WelcomeTermsScreen(),
        '/history': (_) => const HistoryScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/verify-code': (_) => const VerifyCodeScreen(),
        '/new-password': (_) => const NewPasswordScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/product_post': (_) => const ProductPostScreen(),
        '/resource_post': (_) => const ResourcePostScreen(),
        '/blocked_users': (_) => const BlockedUsersScreen(),
        '/help_support': (_) => const HelpSupportScreen(),
        '/wish_request': (_) => const WishRequestsScreen(),
        '/chat_list': (_) => const ChatListScreen(),
        '/chat_screen': (_) => const ChatScreen( sellerName: 'Seller'),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(product: args['product'] as Product),
            settings: settings,
          );
        }

        if (settings.name == '/resource_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) =>
                ResourceDetailsScreen(resource: args['resource'] as Resource),
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
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}