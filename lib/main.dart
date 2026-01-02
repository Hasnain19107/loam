import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'data/network/local/preferences/shared_preference.dart';
import 'features/auth/controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured - app will work but Firebase features won't
    debugPrint('Firebase initialization error: $e');
    debugPrint('Please add google-services.json to android/app/');
  }

  // Initialize GetX controllers
  Get.put(AuthController(), permanent: true);

  // Check auth state
  final prefs = SharedPreferenceService();
  await prefs.init();
  final String initialRoute = prefs.isLoggedIn
      ? AppRoutes.main
      : AppRoutes.landing;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Loam',
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
