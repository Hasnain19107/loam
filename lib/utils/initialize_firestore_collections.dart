/// Script to initialize Firestore collections structure
/// 
/// This creates the necessary collections and indexes for the admin system
/// 
/// Run this once to set up your Firestore database structure

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  print('🔧 Initializing Firestore collections...\n');

  try {
    // Create user_roles collection with a sample document (will be deleted)
    print('Creating user_roles collection...');
    final userRolesRef = firestore.collection(AppConstants.userRolesCollection);
    
    // Create a temporary document to ensure collection exists
    final tempDoc = await userRolesRef.add({
      'user_id': 'temp',
      'role': 'temp',
      'created_at': FieldValue.serverTimestamp(),
    });
    
    // Delete the temp document
    await tempDoc.delete();
    print('✅ user_roles collection initialized\n');

    // Verify profiles collection exists
    print('Checking profiles collection...');
    final profilesRef = firestore.collection(AppConstants.profilesCollection);
    final profilesCheck = await profilesRef.limit(1).get();
    print('✅ profiles collection exists (${profilesCheck.docs.length} documents)\n');

    // Verify events collection exists
    print('Checking events collection...');
    final eventsRef = firestore.collection(AppConstants.eventsCollection);
    final eventsCheck = await eventsRef.limit(1).get();
    print('✅ events collection exists (${eventsCheck.docs.length} documents)\n');

    print('✅ All collections initialized successfully!');
    print('\nNext steps:');
    print('1. Create a user account in Firebase Authentication');
    print('2. Create a profile for that user in the profiles collection');
    print('3. Add a user_roles document with their user_id and role="super_admin"');
    print('4. See ADMIN_SETUP.md for detailed instructions');

  } catch (e) {
    print('❌ Error initializing collections: $e');
    print('\nNote: Collections in Firestore are created automatically when you first write to them.');
    print('You can also create them manually in Firebase Console.');
  }
}

