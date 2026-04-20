import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:admin_module/screens/notification.dart';
import 'package:admin_module/screens/register_admin_screen.dart';
import 'package:admin_module/screens/login_screen.dart';
import 'package:admin_module/screens/forgotpassword.dart';
import 'package:admin_module/screens/dashboard.dart';
import 'package:admin_module/screens/usermanagement.dart';

import 'package:admin_module/screens/managecommunity.dart';
//import 'package:admin_module/screens/viewcommunitydetails.dart';
import 'package:admin_module/screens/escalated_cases.dart';
import 'package:admin_module/screens/productresourcescreen.dart';
import 'package:admin_module/screens/resource_screen.dart';

import 'package:admin_module/screens/community_election.dart';
import 'package:admin_module/screens/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔹 Initialize Supabase
  await Supabase.initialize(
    url: 'https://gidxrziissmkkavoaolj.supabase.co',
    anonKey: 'sb_publishable_bQXqf2cS0ylSFz5wO4jfuA_bKxnoObW',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trade&Aid Admin',

      /// 👇 First screen
      initialRoute: '/dashboard',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterAdminScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/usermanagement': (context) => const UserManagementScreen(),
        '/communitymanagement': (context) => const ManageCommunityScreen(),
        //'/communitydetails': (context) => const CommunityDetails(),
        '/escalatedcases': (context) => const EscalatedCases(),
        '/productresource': (context) => const ProductResource(),
        '/resource': (context) => const ResourceSharing(),
        '/notification': (context) => const NotificationsScreen(),
        '/communityelection': (context) => const CommunityElectionHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}