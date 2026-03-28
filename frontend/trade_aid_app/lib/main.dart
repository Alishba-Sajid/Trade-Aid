// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/cart_provider.dart';

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
import 'screens/products/product_listing.dart';
import 'screens/products/product_details.dart';
import 'screens/resources_screens/resource_listing.dart';
import 'screens/resources_screens/resource_details.dart';
import 'screens/resources_screens/booking_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/products/product_post.dart';
import 'screens/resources_screens/resource_post.dart';
import 'screens/profile/profile.dart';
import 'screens/profile/personaldetailsprofile.dart';
import 'screens/profile/changepassword.dart';
import 'screens/profile/blocked_user.dart';
import 'screens/help&support.dart';
import 'screens/wish_request/wish_request.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/profile/terms&conditions.dart';
import 'screens/welcomeT&C.dart';
import 'screens/profile/history_screen.dart';
import 'screens/forgotpass/forget_pass_screen.dart';
import 'screens/forgotpass/newpass_screen.dart';

// models
import 'models/product.dart';
import 'models/resource.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gidxrziissmkkavoaolj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpZHhyemlpc3Nta2thdm9hb2xqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwMDUzOTYsImV4cCI6MjA4NzU4MTM5Nn0.5_6Ywl7je00tB8uGVKnf3_sZ3-USoghGJfTGS7iJBhE',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const TradeAidApp(),
    ),
  );
}

class TradeAidApp extends StatefulWidget {
  const TradeAidApp({super.key});

  @override
  State<TradeAidApp> createState() => _TradeAidAppState();
}

class _TradeAidAppState extends State<TradeAidApp> {
  // ✅ CENTRAL ROUTING FUNCTION
  Future<void> _handleUserRouting() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final supabase = Supabase.instance.client;

    try {
      // 1️⃣ Profile check
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile == null) {
        navigatorKey.currentState?.pushNamed('/create_profile');
        return;
      }

      // 2️⃣ Community membership
      final membership = await supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (membership != null) {
        navigatorKey.currentState?.pushNamed('/dashboard');
        return;
      }

      // 3️⃣ Pending request
      final pending = await supabase
          .from('community_join_requests')
          .select()
          .eq('requester_id', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (pending != null) {
        navigatorKey.currentState?.pushNamed('/waiting_approval');
        return;
      }

      // 4️⃣ Otherwise → location
      navigatorKey.currentState?.pushNamed('/location_permission');
    } catch (e) {
      print("Routing error: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ Handle app restart
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      Future.microtask(() => _handleUserRouting());
    }

    // ✅ Auth state listener
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.pushNamed('/new-password');
        return;
      }

      if (event == AuthChangeEvent.signedIn) {
        final provider = data.session?.user.appMetadata['provider'];

        if (provider == 'google') {
          _handleUserRouting();
        }
      }

      if (event == AuthChangeEvent.signedOut) {
        navigatorKey.currentState?.pushNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Trade & Aid',
      debugShowCheckedModeBanner: false,

      // ✅ Prevent flicker
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const SizedBox());
      },

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
        '/cart': (_) => const CartScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/personal_details': (_) => const PersonalDetailsScreen(),
        '/change_password': (_) => const ChangePasswordScreen(),
        '/terms_conditions': (_) => const TermsAndConditionsScreen(),
        '/welcome_terms': (_) => const WelcomeTermsScreen(),
        '/history': (_) => const HistoryScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/new-password': (_) => const NewPasswordScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/blocked_users': (_) => const BlockedUsersScreen(),
        '/help_support': (_) => const HelpSupportScreen(),
        '/chat_list': (_) => const ChatListScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/product_post') {
          final raw = settings.arguments;
          final Map<String, dynamic> args = raw is Map<String, dynamic>
              ? raw
              : (raw is String ? {'communityId': raw} : <String, dynamic>{});

          return MaterialPageRoute(
            builder: (_) => ProductPostScreen(
              communityId: (args['communityId'] as String?) ?? '',
              wishId: args['wishId'] as String?,
              makePublicAfter48Hours: args['makePublicAfter48Hours'] as bool?,
              requesterId: args['requesterId'] as String?,
            ),
            settings: settings,
          );
        }

        if (settings.name == '/product_listing') {
          final communityId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => ProductListingScreen(communityId: communityId),
            settings: settings,
          );
        }

        if (settings.name == '/product_details') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(product: args['product'] as Product),
            settings: settings,
          );
        }

        if (settings.name == '/resource_post') {
          final communityId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => ResourcePostScreen(communityId: communityId),
            settings: settings,
          );
        }

        if (settings.name == '/resource_listing') {
          final communityId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => ResourceListingScreen(communityId: communityId),
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

        if (settings.name == '/wish_request') {
          final communityId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => WishRequestsScreen(communityId: communityId),
            settings: settings,
          );
        }

        if (settings.name == '/booking') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              resourceId: args['resourceId'],
              resourceName: args['resourceName'],
              ownerId: args['ownerId'] as String,
              startTimeLimit: args['startTimeLimit'],
              endTimeLimit: args['endTimeLimit'],
            ),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}
