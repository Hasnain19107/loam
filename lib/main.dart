import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/controller/auth_controller.dart';
import 'data/network/local/preferences/shared_preference.dart';

import 'data/models/user_profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize Shared Preferences
  final prefs = SharedPreferenceService();
  await prefs.init();

  // Initialize Auth Controller
  Get.put(AuthController(), permanent: true);

  // Determine initial route
  String initialRoute = AppRoutes.landing;
  if (prefs.isLoggedIn) {
     if (prefs.isAdmin) {
       initialRoute = AppRoutes.adminDashboard;
     } else {
       // Check if profile is complete
       final user = prefs.getUser();
       if (isProfileComplete(user)) {
         initialRoute = AppRoutes.main;
       } else {
         initialRoute = AppRoutes.onboarding;
       }
     }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

bool isProfileComplete(UserProfileModel? user) {
  if (user == null) return false;
  return user.firstName != null &&
      user.firstName!.isNotEmpty &&
      user.phone != null &&
      user.phone!.isNotEmpty &&
      user.dateOfBirth != null &&
      user.dateOfBirth!.isNotEmpty &&
      user.gender != null &&
      user.gender!.isNotEmpty;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Loam Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.routes,

      // Use default transition to avoid animation initialization issues
      // defaultTransition: Transition.fade,
      // transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
