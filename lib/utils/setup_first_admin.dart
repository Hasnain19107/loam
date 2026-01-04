/// Quick setup script to create the first admin user
/// 
/// Usage:
/// 1. Update the email below with your admin email
/// 2. Run: flutter run lib/utils/setup_first_admin.dart
/// 
/// Note: This requires Firebase to be initialized and the user to exist

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loam/utils/admin_setup_helper.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ⚠️ UPDATE THIS EMAIL with your admin email
  const adminEmail = 'admin@example.com'; // Change this!

  final helper = AdminSetupHelper();

  try {
    print('🔧 Setting up admin user: $adminEmail');
    await helper.setSuperAdminByEmail(adminEmail);
    print('✅ Admin setup complete!');
    print('You can now log in at /admin/login');
  } catch (e) {
    print('❌ Error: $e');
    print('\nTroubleshooting:');
    print('1. Make sure the user exists in Firebase Authentication');
    print('2. Make sure the user has a profile in Firestore (profiles collection)');
    print('3. Check that Firebase is properly configured');
  }
}

