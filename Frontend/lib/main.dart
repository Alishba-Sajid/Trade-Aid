
import 'package:flutter/material.dart';

import 'package:admin_module/screens/notification.dart';
import 'package:admin_module/screens/register_admin_screen.dart';
import 'package:admin_module/screens/login_screen.dart';
import 'package:admin_module/screens/forgotpassword.dart';
import 'package:admin_module/screens/dashboard.dart';
import 'package:admin_module/screens/usermanagement.dart';
import 'package:admin_module/screens/report_details.dart';
import 'package:admin_module/screens/managecommunity.dart';
import 'package:admin_module/screens/viewcommunitydetails.dart';
import 'package:admin_module/screens/escalated_cases.dart';
import 'package:admin_module/screens/productresourcescreen.dart';
import 'package:admin_module/screens/resource_screen.dart';
import 'package:admin_module/screens/admin_rotation.dart';
import 'package:admin_module/screens/community_election.dart';
import 'package:admin_module/screens/settings.dart';






 // make sure this file exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trade&Aid Admin',

      // 👇 This decides which screen appears first
      initialRoute: '/dashboard',

      // 👇 Register all your app screens here
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterAdminScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/usermanagement': (context) => const UserManagementScreen(), 
        //'/userprofile': (context) => const UserProfileScreen(), 
        '/communitymanagement': (context) => const ManageCommunityScreen(),
        '/communitydetails': (context) => const CommunityDetails(),
        '/escalatedcases': (context) => const EscalatedCases(),
        '/productresource': (context) => const ProductResource(),
        '/resource': (context) => const ResourceSharing(),
        '/notification': (context) => const NotificationsScreen(),
        '/adminrotation': (context) => const AdminRotationScreen(),
        '/communityelection': (context) => const CommunityElectionHistoryScreen(),
        
        '/reportdetail': (context) => const ReportDetailsPage(),
        '/settings': (context) => const SettingsScreen(),
        

        // 👈 Added this line
      },
    );
  }
}
