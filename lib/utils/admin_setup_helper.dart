import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../core/constants/app_constants.dart';

/// Helper utility to set up admin users
/// 
/// Usage:
/// 1. Get the user's email from Firebase Authentication
/// 2. Find their user ID (UID)
/// 3. Run this helper to assign admin role
class AdminSetupHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  /// Set a user as super admin by email
  /// 
  /// This will:
  /// 1. Find the user by email
  /// 2. Assign 'super_admin' role to them
  Future<void> setSuperAdminByEmail(String email) async {
    try {
      // Find user by email in Firebase Auth
      final userRecord = await _auth.fetchSignInMethodsForEmail(email);
      if (userRecord.isEmpty) {
        throw Exception('User with email $email not found');
      }

      // Get user ID - we need to sign in or use Admin SDK
      // For Flutter, we'll need to get the user ID from profiles collection
      final profilesSnapshot = await _firestore
          .collection(AppConstants.profilesCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (profilesSnapshot.docs.isEmpty) {
        throw Exception('User profile not found for email $email');
      }

      final userId = profilesSnapshot.docs.first.id;
      await setSuperAdminByUserId(userId);
      
      print('✅ Successfully set $email as super admin');
    } catch (e) {
      print('❌ Error setting super admin: $e');
      rethrow;
    }
  }

  /// Set a user as super admin by user ID
  Future<void> setSuperAdminByUserId(String userId) async {
    try {
      // Check if role already exists
      final existingRoles = await _firestore
          .collection(AppConstants.userRolesCollection)
          .where('user_id', isEqualTo: userId)
          .where('role', isEqualTo: AppConstants.roleSuperAdmin)
          .get();

      if (existingRoles.docs.isNotEmpty) {
        print('⚠️ User already has super_admin role');
        return;
      }

      // Add the role
      await _firestore.collection(AppConstants.userRolesCollection).add({
        'user_id': userId,
        'role': AppConstants.roleSuperAdmin,
        'created_at': FieldValue.serverTimestamp(),
      });

      print('✅ Successfully assigned super_admin role to user $userId');
    } catch (e) {
      print('❌ Error assigning super admin role: $e');
      rethrow;
    }
  }

  /// Set a user as event host by email
  Future<void> setEventHostByEmail(String email) async {
    try {
      final profilesSnapshot = await _firestore
          .collection(AppConstants.profilesCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (profilesSnapshot.docs.isEmpty) {
        throw Exception('User profile not found for email $email');
      }

      final userId = profilesSnapshot.docs.first.id;
      await setEventHostByUserId(userId);
      
      print('✅ Successfully set $email as event host');
    } catch (e) {
      print('❌ Error setting event host: $e');
      rethrow;
    }
  }

  /// Set a user as event host by user ID
  Future<void> setEventHostByUserId(String userId) async {
    try {
      // Check if role already exists
      final existingRoles = await _firestore
          .collection(AppConstants.userRolesCollection)
          .where('user_id', isEqualTo: userId)
          .where('role', isEqualTo: AppConstants.roleEventHost)
          .get();

      if (existingRoles.docs.isNotEmpty) {
        print('⚠️ User already has event_host role');
        return;
      }

      // Add the role
      await _firestore.collection(AppConstants.userRolesCollection).add({
        'user_id': userId,
        'role': AppConstants.roleEventHost,
        'created_at': FieldValue.serverTimestamp(),
      });

      print('✅ Successfully assigned event_host role to user $userId');
    } catch (e) {
      print('❌ Error assigning event host role: $e');
      rethrow;
    }
  }
}

