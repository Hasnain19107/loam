import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/user_profile_model.dart';
import '../../models/event_model.dart';
import '../../models/event_participant_model.dart';
import '../../../core/constants/app_constants.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  firebase_auth.User? get currentUser => _auth.currentUser;
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // User Profile Methods
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.profilesCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserProfileModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.profilesCollection)
          .doc(userId);

      // Check if document exists
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, update it
        await docRef.update({
          ...data,
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        // Document doesn't exist, create it with initial data
        final user = _auth.currentUser;
        await docRef.set({
          'id': userId,
          'email': user?.email,
          ...data,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  Future<void> createUserProfile(UserProfileModel profile) async {
    try {
      await _firestore
          .collection(AppConstants.profilesCollection)
          .doc(profile.id)
          .set(profile.toJson());
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  // Event Methods
  Stream<List<EventModel>> getPublishedEvents() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('status', isEqualTo: AppConstants.eventStatusPublished)
        .where('visibility', isEqualTo: AppConstants.eventVisibilityPublic)
        .orderBy('start_date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  Future<EventModel?> getEvent(String eventId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .get();
      if (doc.exists) {
        return EventModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  Future<List<EventModel>> getUserEvents(String userId) async {
    try {
      final participantsSnapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: AppConstants.participationStatusApproved)
          .get();

      if (participantsSnapshot.docs.isEmpty) {
        return [];
      }

      final eventIds = participantsSnapshot.docs
          .map((doc) => doc.data()['event_id'] as String)
          .toList();

      final eventsSnapshot = await _firestore
          .collection(AppConstants.eventsCollection)
          .where(FieldPath.documentId, whereIn: eventIds)
          .get();

      return eventsSnapshot.docs
          .map((doc) => EventModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Error fetching user events: $e');
    }
  }

  // Event Participant Methods
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .add({
            'event_id': eventId,
            'user_id': userId,
            'status': AppConstants.participationStatusPending,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error registering for event: $e');
    }
  }

  Future<EventParticipantModel?> getEventParticipation(
    String eventId,
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('event_id', isEqualTo: eventId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return EventParticipantModel.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching event participation: $e');
    }
  }

  Future<List<UserProfileModel>> getEventParticipants(String eventId) async {
    try {
      final participantsSnapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('event_id', isEqualTo: eventId)
          .where('status', isEqualTo: AppConstants.participationStatusApproved)
          .get();

      if (participantsSnapshot.docs.isEmpty) {
        return [];
      }

      final userIds = participantsSnapshot.docs
          .map((doc) => doc.data()['user_id'] as String)
          .toList();

      final profilesSnapshot = await _firestore
          .collection(AppConstants.profilesCollection)
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      return profilesSnapshot.docs
          .map(
            (doc) => UserProfileModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Error fetching event participants: $e');
    }
  }

  // Storage Methods
  Future<String> uploadImage(String path, List<int> imageBytes) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putData(Uint8List.fromList(imageBytes));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<String> uploadProfilePhoto(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final imageBytes = await file.readAsBytes();
      final storagePath = 'profiles/$userId/profile_photo.jpg';

      return await uploadImage(storagePath, imageBytes);
    } catch (e) {
      throw Exception('Error uploading profile photo: $e');
    }
  }

  // User Roles
  Future<List<String>> getUserRoles(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.userRolesCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()['role'] as String).toList();
    } catch (e) {
      throw Exception('Error fetching user roles: $e');
    }
  }

  Future<bool> isAdmin(String userId) async {
    final roles = await getUserRoles(userId);
    return roles.contains(AppConstants.roleSuperAdmin) ||
        roles.contains(AppConstants.roleEventHost);
  }

  // App Settings
  Future<dynamic> getAppSetting(String key) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.appSettingsCollection)
          .doc(key)
          .get();
      if (doc.exists) {
        return doc.data()?['value'];
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching app setting: $e');
    }
  }
}
