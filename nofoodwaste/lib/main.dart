import 'package:flutter/material.dart';
import 'package:nofoodwaste/firebase_options.dart';
import 'package:nofoodwaste/pages/donorDashboard.dart';
import 'package:nofoodwaste/pages/donorSignUp.dart';
import 'package:nofoodwaste/pages/employeeDashboard.dart';
import 'package:nofoodwaste/pages/food_acceptance_page.dart';
import 'package:nofoodwaste/pages/food_details_form_page.dart';
import 'package:nofoodwaste/pages/login.dart';
import 'package:nofoodwaste/pages/volunteerDashboard.dart' hide FoodDetailsFormPage;
import 'package:nofoodwaste/pages/volunteer_profile_screen.dart';
import 'package:nofoodwaste/pages/DonarRequestForm.dart';
import 'package:nofoodwaste/pages/DonationHistoryPage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? initialRoute = '/login';

  if (isLoggedIn) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email!)
          .get();

      if (doc.exists) {
        final role = doc['role'];
        switch (role) {
          case 'donor':
            initialRoute = '/donorDashboard';
            break;
          case 'employee':
            initialRoute = '/employeeDashboard';
            break;
          case 'volunteer':
            initialRoute = '/volunteerDashboard';
            break;
          default:
            initialRoute = '/login';
        }
      } else {
        initialRoute = '/donorSignUp';
      }
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Food Waste',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const Login(),
        '/donorSignUp': (context) => const DonorSignUp(),
        '/donorDashboard': (context) => const Donordashboard(),
        '/employeeDashboard': (context) => const EmployeeDashboard(),
        '/volunteerDashboard': (context) => const Volunteerdashboard(),
        '/DonarRequestForm': (context) => const DonarRequestForm(),
        '/donarRequest': (context) => const DonarRequestForm(), // quick fix
        '/profile': (context) => const VolunteerProfileScreen(),
        '/foodAcceptancePage': (context) => const FoodAcceptancePage(location: '',),
        '/foodDetailsFormPage': (context) => const FoodDetailsFormPage(location: '',),
        '/DonationHistoryPage': (context) => const DonationHistoryPage(),
      },
    );
  }
}
