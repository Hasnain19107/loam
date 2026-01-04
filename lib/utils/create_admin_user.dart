/// Complete script to create an admin user from scratch
/// 
/// This script will:
/// 1. Create a user in Firebase Authentication
/// 2. Create a profile in Firestore
/// 3. Assign super_admin role
/// 
/// Usage:
/// 1. Update email and password below
/// 2. Run: flutter run lib/utils/create_admin_user.dart

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ⚠️ UPDATE THESE VALUES
  const adminEmail = 'admin@example.com'; // Change this!
  const adminPassword = 'SecurePassword123!'; // Change this!
  const adminName = 'Admin User'; // Change this!

  final auth = firebase_auth.FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  try {
    print('🔧 Creating admin user...\n');

    // Step 1: Create user in Firebase Authentication
    print('Step 1: Creating user in Firebase Authentication...');
    firebase_auth.UserCredential userCredential;
    
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      print('✅ User created in Authentication');
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('⚠️ User already exists, signing in...');
        userCredential = await auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        print('✅ Signed in to existing user');
      } else {
        rethrow;
      }
    }

    final userId = userCredential.user!.uid;
    print('   User ID: $userId\n');

    // Step 2: Create profile in Firestore
    print('Step 2: Creating profile in Firestore...');
    final profileRef = firestore.collection(AppConstants.profilesCollection).doc(userId);
    
    final profileExists = await profileRef.get();
    if (profileExists.exists) {
      print('   ⚠️ Profile already exists, updating...');
      await profileRef.update({
        'email': adminEmail,
        'first_name': adminName,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } else {
      await profileRef.set({
        'id': userId,
        'email': adminEmail,
        'first_name': adminName,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    print('✅ Profile created/updated\n');

    // Step 3: Assign super_admin role
    print('Step 3: Assigning super_admin role...');
    final userRolesRef = firestore.collection(AppConstants.userRolesCollection);
    
    // Check if role already exists
    final existingRole = await userRolesRef
        .where('user_id', isEqualTo: userId)
        .where('role', isEqualTo: AppConstants.roleSuperAdmin)
        .get();

    if (existingRole.docs.isEmpty) {
      await userRolesRef.add({
        'user_id': userId,
        'role': AppConstants.roleSuperAdmin,
        'created_at': FieldValue.serverTimestamp(),
      });
      print('✅ Super admin role assigned\n');
    } else {
      print('   ⚠️ User already has super_admin role\n');
    }

    print('✅ Admin user setup complete!');
    print('\n📋 Summary:');
    print('   Email: $adminEmail');
    print('   User ID: $userId');
    print('   Role: super_admin');
    print('\n✅ You can now log in at /admin/login');

  } catch (e) {
    print('❌ Error: $e');
    print('\nTroubleshooting:');
    print('1. Check Firebase configuration');
    print('2. Ensure Firestore is enabled in Firebase Console');
    print('3. Check that email format is valid');
    print('4. Ensure password meets requirements (min 6 characters)');
  }
}

