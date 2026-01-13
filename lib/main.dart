
import 'package:admin_module/Frontend/screens/notification.dart';
import 'package:flutter/material.dart';

import 'Frontend/screens/register_admin_screen.dart';
import 'Frontend/screens/login_screen.dart';
import 'Frontend/screens/forgotpassword.dart';
import 'Frontend/screens/dashboard.dart';
import 'Frontend/screens/usermanagement.dart';
import 'Frontend/screens/report_details.dart';
import 'Frontend/screens/managecommunity.dart';
import 'Frontend/screens/viewcommunitydetails.dart';
import 'Frontend/screens/escalated_cases.dart';
import 'Frontend/screens/productresourcescreen.dart';
import 'Frontend/screens/resource_screen.dart';
import 'Frontend/screens/admin_rotation.dart';
import 'Frontend/screens/community_election.dart';
//import 'Frontend/screens/dispute_details.dart';




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
      initialRoute: '/register',

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
        '/escalatedcases': (context) => const EscalatedCasesScreen(),
        '/productresource': (context) => const ProductResource(),
        '/resource': (context) => const ResourceSharing(),
        '/notification': (context) => const NotificationsScreen(),
        '/adminrotation': (context) => const AdminRotationScreen(),
        '/communityelection': (context) => const CommunityElectionHistoryScreen(),
        '/reportdetail': (context) => const ReportDetailsPage(),
        

        // 👈 Added this line
      },
    );
  }
}
