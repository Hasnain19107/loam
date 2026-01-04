import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../models/user_profile_model.dart';
import '../../models/event_model.dart';
import '../../models/event_participant_model.dart';
import '../../models/survey_model.dart';
import '../../models/survey_question_model.dart';
import '../../models/survey_response_model.dart';
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

  Future<bool?> signInWithGoogle() async {
    try {
      // Configure GoogleSignIn - it will use the default configuration from google-services.json
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out any existing session first to ensure clean state
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in - return null to indicate cancellation
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Failed to get ID token from Google. Please check your Firebase configuration and SHA-1 certificate fingerprint.',
        );
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user - if so, sign them out and return false
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _auth.signOut();
        await googleSignIn.signOut();
        return false; // New user, account doesn't exist
      }

      return true; // Existing user, sign in successful
    } catch (e) {
      print('Google Sign-In Error: $e');
      print('Error type: ${e.runtimeType}');
      if (e is Exception) {
        print('Exception details: ${e.toString()}');
      }
      // Re-throw with more context
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  Future<bool> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com')
          .credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode,
          );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Check if this is a new user - if so, sign them out and return false
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _auth.signOut();
        return false; // New user, account doesn't exist
      }

      return true; // Existing user, sign in successful
    } catch (e) {
      throw Exception('Error signing in with Apple: $e');
    }
  }

  // Sign up methods (allow new users)
  Future<bool?> signUpWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return false; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Failed to get ID token from Google. Please check your Firebase configuration and SHA-1 certificate fingerprint.',
        );
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // For sign-up, allow both new and existing users
      // If new user, create initial profile with Google info
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final user = userCredential.user;
        if (user != null) {
          String? firstName;
          String? lastName;
          if (user.displayName != null) {
            final nameParts = user.displayName!.split(' ');
            firstName = nameParts.isNotEmpty ? nameParts.first : null;
            lastName = nameParts.length > 1
                ? nameParts.sublist(1).join(' ')
                : null;
          }

          await updateUserProfile(user.uid, {
            if (firstName != null) 'first_name': firstName,
            if (lastName != null) 'last_name': lastName,
            'email': user.email,
          });
        }
      }

      return true; // Sign up successful (new or existing user)
    } catch (e) {
      print('Google Sign-Up Error: $e');
      throw Exception('Google Sign-Up failed: ${e.toString()}');
    }
  }

  Future<bool?> signUpWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com')
          .credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode,
          );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // For sign-up, allow both new and existing users
      // If new user, create initial profile with Apple info
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final user = userCredential.user;
        if (user != null) {
          final profileData = <String, dynamic>{'email': user.email};

          if (appleCredential.givenName != null) {
            profileData['first_name'] = appleCredential.givenName;
          }
          if (appleCredential.familyName != null) {
            profileData['last_name'] = appleCredential.familyName;
          }

          await updateUserProfile(user.uid, profileData);
        }
      }

      return true; // Sign up successful (new or existing user)
    } catch (e) {
      // Check if it's a cancellation
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('cancelled') ||
          errorString.contains('canceled')) {
        return null; // User cancelled
      }
      throw Exception('Error signing up with Apple: $e');
    }
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
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

  // Get raw user profile document (includes quiz_answers)
  Future<Map<String, dynamic>?> getUserProfileDocument(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.profilesCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user profile document: $e');
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
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => EventModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

          // Client-side sort to avoid composite index requirement
          events.sort((a, b) => a.startDate.compareTo(b.startDate));

          return events;
        });
  }

  // Stream of ALL events (for testing/admin-like view on user side if requested)
  Stream<List<EventModel>> getAllEventsStream() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        // No filters on status/visibility
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => EventModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

          // Client-side sort
          events.sort((a, b) => a.startDate.compareTo(b.startDate));

          return events;
        });
  }

  Future<List<EventModel>> getEventsByIds(List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    try {
      final eventsSnapshot = await _firestore
          .collection(AppConstants.eventsCollection)
          .where(FieldPath.documentId, whereIn: eventIds)
          .get();

      return eventsSnapshot.docs
          .map((doc) => EventModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error fetching events by IDs: $e');
    }
  }

  Future<EventModel?> getEvent(String eventId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .get();
      if (doc.exists) {
        return EventModel.fromJson({...doc.data()!, 'id': doc.id});
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
          .map((doc) => EventModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error fetching user events: $e');
    }
  }

  Future<List<EventParticipantModel>> getUserParticipations(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final participations = snapshot.docs
          .map(
            (doc) =>
                EventParticipantModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();

      participations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return participations;
    } catch (e) {
      throw Exception('Error fetching user participations: $e');
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

  Future<String> uploadEventImage(String eventId, String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final imageBytes = await file.readAsBytes();
      // Use timestamp to make filename unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath =
          '${AppConstants.eventImagesStoragePath}/$eventId/cover_$timestamp.jpg';

      return await uploadImage(storagePath, imageBytes);
    } catch (e) {
      throw Exception('Error uploading event image: $e');
    }
  }

  Future<String> uploadEventImageForNewEvent(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final imageBytes = await file.readAsBytes();
      // Use timestamp to make filename unique for new events
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath =
          '${AppConstants.eventImagesStoragePath}/temp/cover_$timestamp.jpg';

      return await uploadImage(storagePath, imageBytes);
    } catch (e) {
      throw Exception('Error uploading event image: $e');
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

  // Assign role to user
  Future<void> assignUserRole(String userId, String role) async {
    try {
      // Check if role already exists
      final existingRoles = await getUserRoles(userId);
      if (existingRoles.contains(role)) {
        return; // Role already assigned
      }

      // Add the role
      await _firestore.collection(AppConstants.userRolesCollection).add({
        'user_id': userId,
        'role': role,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error assigning user role: $e');
    }
  }

  // Remove role from user
  Future<void> removeUserRole(String userId, String role) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.userRolesCollection)
          .where('user_id', isEqualTo: userId)
          .where('role', isEqualTo: role)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error removing user role: $e');
    }
  }

  // Set user as super admin
  Future<void> setSuperAdmin(String userId) async {
    await assignUserRole(userId, AppConstants.roleSuperAdmin);
  }

  // Set user as event host
  Future<void> setEventHost(String userId) async {
    await assignUserRole(userId, AppConstants.roleEventHost);
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

  Future<void> setAppSetting(String key, dynamic value) async {
    try {
      await _firestore
          .collection(AppConstants.appSettingsCollection)
          .doc(key)
          .set({'value': value}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error setting app setting: $e');
    }
  }

  // Admin Methods
  Future<List<UserProfileModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.profilesCollection)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => UserProfileModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Error fetching all users: $e');
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventsCollection)
          .orderBy('start_date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error fetching all events: $e');
    }
  }

  Future<int> getTotalUsersCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.profilesCollection)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      // Fallback to getting all and counting
      final all = await getAllUsers();
      return all.length;
    }
  }

  Future<int> getActiveUsersCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.profilesCollection)
          .where('is_shadow_blocked', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      // Fallback
      final all = await getAllUsers();
      return all.where((u) => !u.isShadowBlocked).length;
    }
  }

  Future<int> getUpcomingEventsCount() async {
    try {
      final now = DateTime.now();
      // Use client-side filtering to avoid index requirements for this specific query
      final all = await getAllEvents();
      return all.where((e) {
        return e.status == AppConstants.eventStatusPublished &&
            e.startDate.isAfter(now);
      }).length;
    } catch (e) {
      // Return 0 if robust fallback also fails
      return 0;
    }
  }

  Future<int> getPendingApprovalsCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('status', isEqualTo: AppConstants.participationStatusPending)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      // Fallback: This is expensive but ensures accuracy if index is missing
      try {
        final snapshot = await _firestore
            .collection(AppConstants.eventParticipantsCollection)
            .where('status', isEqualTo: AppConstants.participationStatusPending)
            .get();
        return snapshot.docs.length;
      } catch (_) {
        return 0;
      }
    }
  }

  Future<void> updateUserShadowBlock(String userId, bool isBlocked) async {
    try {
      await _firestore
          .collection(AppConstants.profilesCollection)
          .doc(userId)
          .update({
            'is_shadow_blocked': isBlocked,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error updating user shadow block: $e');
    }
  }

  Future<void> updateUserAdminNotes(String userId, String notes) async {
    try {
      await _firestore
          .collection(AppConstants.profilesCollection)
          .doc(userId)
          .update({
            'admin_notes': notes,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error updating admin notes: $e');
    }
  }

  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.eventsCollection)
          .add(event.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      // Convert DateTime to Timestamp
      final updatedData = <String, dynamic>{...data};
      if (updatedData['start_date'] is DateTime) {
        updatedData['start_date'] = Timestamp.fromDate(
          updatedData['start_date'] as DateTime,
        );
      }
      if (updatedData['end_date'] is DateTime) {
        updatedData['end_date'] = Timestamp.fromDate(
          updatedData['end_date'] as DateTime,
        );
      }

      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .update({...updatedData, 'updated_at': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  Future<List<EventParticipantModel>> getEventParticipantsForAdmin(
    String eventId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('event_id', isEqualTo: eventId)
          .get();

      final participants = snapshot.docs
          .map(
            (doc) =>
                EventParticipantModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();

      // Client-side sort to avoid composite index requirement
      participants.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return participants;
    } catch (e) {
      throw Exception('Error fetching event participants: $e');
    }
  }

  Future<void> updateParticipantStatus(
    String participantId,
    String status,
  ) async {
    try {
      // If approving, check capacity first
      if (status == AppConstants.participationStatusApproved) {
        // Get the participant to find the event ID
        final participantDoc = await _firestore
            .collection(AppConstants.eventParticipantsCollection)
            .doc(participantId)
            .get();

        if (!participantDoc.exists) {
          throw Exception('Participant not found');
        }

        final eventId = participantDoc.data()?['event_id'] as String?;
        if (eventId == null) {
          throw Exception('Event ID not found for participant');
        }

        // Get the event to check capacity
        final eventDoc = await _firestore
            .collection(AppConstants.eventsCollection)
            .doc(eventId)
            .get();

        if (!eventDoc.exists) {
          throw Exception('Event not found');
        }

        final eventData = eventDoc.data()!;
        final isUnlimitedCapacity =
            eventData['is_unlimited_capacity'] as bool? ?? true;
        final capacity = eventData['capacity'] as int?;

        // Only check capacity if it's not unlimited
        if (!isUnlimitedCapacity && capacity != null) {
          // Get current approved count
          final approvedCount = await getEventApprovedCount(eventId);

          // Check if event is at capacity
          if (approvedCount >= capacity) {
            throw Exception(
              'Event is at full capacity ($capacity/$capacity). Cannot approve more participants.',
            );
          }
        }
      }

      // Update the participant status
      await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .doc(participantId)
          .update({
            'status': status,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error updating participant status: $e');
    }
  }

  Future<List<EventModel>> getEventsRequiringApproval() async {
    try {
      // Removed orderBy in query to avoid needing a composite index
      // We will sort client-side instead
      final snapshot = await _firestore
          .collection(AppConstants.eventsCollection)
          .where('requires_approval', isEqualTo: true)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Sort by start date (ascending)
      events.sort((a, b) => a.startDate.compareTo(b.startDate));

      return events;
    } catch (e) {
      throw Exception('Error fetching events requiring approval: $e');
    }
  }

  Future<int> getEventPendingCount(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('event_id', isEqualTo: eventId)
          .where('status', isEqualTo: AppConstants.participationStatusPending)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getEventApprovedCount(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventParticipantsCollection)
          .where('event_id', isEqualTo: eventId)
          .where('status', isEqualTo: AppConstants.participationStatusApproved)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Survey/Quiz Methods
  Future<List<SurveyModel>> getAllSurveys() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.surveysCollection)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SurveyModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Error fetching surveys: $e');
    }
  }

  Future<SurveyModel?> getSurvey(String surveyId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.surveysCollection)
          .doc(surveyId)
          .get();
      if (doc.exists) {
        return SurveyModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching survey: $e');
    }
  }

  Future<SurveyModel?> getActiveSurvey() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.surveysCollection)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return SurveyModel.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching active survey: $e');
    }
  }

  Future<String> createSurvey(SurveyModel survey) async {
    try {
      // Generate UUID for the survey ID if not provided
      final surveyId = survey.id.isNotEmpty
          ? survey.id
          : _firestore.collection(AppConstants.surveysCollection).doc().id;

      // Create survey with the generated ID (don't include 'id' in document data)
      await _firestore
          .collection(AppConstants.surveysCollection)
          .doc(surveyId)
          .set(survey.copyWith(id: surveyId).toJson(includeId: false));

      return surveyId;
    } catch (e) {
      throw Exception('Error creating survey: $e');
    }
  }

  Future<void> updateSurvey(String surveyId, Map<String, dynamic> data) async {
    try {
      final updatedData = <String, dynamic>{...data};
      if (updatedData['created_at'] is DateTime) {
        updatedData['created_at'] = Timestamp.fromDate(
          updatedData['created_at'] as DateTime,
        );
      }
      if (updatedData['updated_at'] is DateTime) {
        updatedData['updated_at'] = Timestamp.fromDate(
          updatedData['updated_at'] as DateTime,
        );
      }

      await _firestore
          .collection(AppConstants.surveysCollection)
          .doc(surveyId)
          .update({...updatedData, 'updated_at': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Error updating survey: $e');
    }
  }

  Future<void> deleteSurvey(String surveyId) async {
    try {
      // First delete all questions
      final questionsSnapshot = await _firestore
          .collection(AppConstants.surveyQuestionsCollection)
          .where('survey_id', isEqualTo: surveyId)
          .get();

      for (var doc in questionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the survey
      await _firestore
          .collection(AppConstants.surveysCollection)
          .doc(surveyId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting survey: $e');
    }
  }

  Future<void> archiveAllActiveSurveysExcept(String excludeSurveyId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.surveysCollection)
          .where('status', isEqualTo: 'active')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        if (doc.id != excludeSurveyId) {
          batch.update(doc.reference, {
            'status': 'archived',
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error archiving surveys: $e');
    }
  }

  Future<List<SurveyQuestionModel>> getSurveyQuestions(String surveyId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.surveyQuestionsCollection)
          .where('survey_id', isEqualTo: surveyId)
          .get();

      final questions = snapshot.docs
          .map(
            (doc) =>
                SurveyQuestionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();

      // Client-side sort to avoid composite index requirement
      questions.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      return questions;
    } catch (e) {
      throw Exception('Error fetching survey questions: $e');
    }
  }

  Future<String> createSurveyQuestion(SurveyQuestionModel question) async {
    try {
      // Generate ID if not provided
      final questionId = question.id.isNotEmpty
          ? question.id
          : _firestore
                .collection(AppConstants.surveyQuestionsCollection)
                .doc()
                .id;

      // Create question with the generated ID (don't include 'id' in document data)
      await _firestore
          .collection(AppConstants.surveyQuestionsCollection)
          .doc(questionId)
          .set(question.copyWith(id: questionId).toJson(includeId: false));

      return questionId;
    } catch (e) {
      throw Exception('Error creating survey question: $e');
    }
  }

  Future<void> updateSurveyQuestion(
    String questionId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.surveyQuestionsCollection)
          .doc(questionId)
          .update({...data, 'updated_at': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Error updating survey question: $e');
    }
  }

  Future<void> deleteSurveyQuestion(String questionId) async {
    try {
      await _firestore
          .collection(AppConstants.surveyQuestionsCollection)
          .doc(questionId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting survey question: $e');
    }
  }

  Future<List<SurveyResponseModel>> getSurveyResponses(String surveyId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.surveyResponsesCollection)
          .where('survey_id', isEqualTo: surveyId)
          .get();

      print(
        'Found ${snapshot.docs.length} response documents for survey $surveyId',
      );

      final responses = <SurveyResponseModel>[];

      // Convert new format (one doc per user with all answers) to old format (one per question)
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final answers = data['answers'] as Map<String, dynamic>? ?? {};
        final questionsSnapshot =
            data['questions_snapshot'] as Map<String, dynamic>? ?? {};
        final userId = data['user_id'] as String? ?? '';
        final createdAt =
            (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

        // Handle both new format (with answers map) and old format (direct fields)
        if (answers.isNotEmpty) {
          // New format: one document with all answers
          answers.forEach((questionId, answerValue) {
            final questionData =
                questionsSnapshot[questionId] as Map<String, dynamic>? ?? {};
            responses.add(
              SurveyResponseModel(
                id: doc.id,
                userId: userId,
                surveyId: surveyId,
                questionId: questionId,
                questionTextSnapshot:
                    questionData['question_text'] as String? ?? '',
                questionTypeSnapshot:
                    questionData['question_type'] as String? ?? '',
                answerValue: answerValue.toString(),
                createdAt: createdAt,
              ),
            );
          });
        } else {
          // Old format: one document per question (backward compatibility)
          final questionId = data['question_id'] as String? ?? '';
          if (questionId.isNotEmpty) {
            responses.add(
              SurveyResponseModel.fromJson({'id': doc.id, ...data}),
            );
          }
        }
      }

      print('Converted to ${responses.length} response models');

      // Sort client-side
      responses.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return responses;
    } catch (e) {
      print('Error fetching survey responses: $e');
      throw Exception('Error fetching survey responses: $e');
    }
  }

  Future<void> saveSurveyResponses(List<SurveyResponseModel> responses) async {
    try {
      if (responses.isEmpty) return;

      // Group responses by user_id and survey_id to create one document per user per survey
      final groupedResponses = <String, List<SurveyResponseModel>>{};
      for (var response in responses) {
        final key = '${response.userId}_${response.surveyId}';
        if (!groupedResponses.containsKey(key)) {
          groupedResponses[key] = [];
        }
        groupedResponses[key]!.add(response);
      }

      final batch = _firestore.batch();
      final collection = _firestore.collection(
        AppConstants.surveyResponsesCollection,
      );

      // Create one document per user per survey with all answers
      groupedResponses.forEach((key, userResponses) {
        if (userResponses.isEmpty) return;

        final firstResponse = userResponses.first;
        final docRef = collection.doc(); // Auto-ID

        // Build answers map: question_id -> answer_value
        final answers = <String, String>{};
        final questionsSnapshot = <String, Map<String, String>>{};

        for (var response in userResponses) {
          answers[response.questionId] = response.answerValue;
          questionsSnapshot[response.questionId] = {
            'question_text': response.questionTextSnapshot,
            'question_type': response.questionTypeSnapshot,
          };
        }

        // Create single document with all answers
        final data = {
          'id': docRef.id,
          'user_id': firstResponse.userId,
          'survey_id': firstResponse.surveyId,
          'answers': answers, // Map of question_id -> answer_value
          'questions_snapshot':
              questionsSnapshot, // Map of question_id -> {text, type}
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        batch.set(docRef, data);
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Error saving survey responses: $e');
    }
  }

  Future<Map<String, int>> getSurveyResponseCounts() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.surveyResponsesCollection)
          .get();

      final counts = <String, Set<String>>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final surveyId = data['survey_id'] as String? ?? '';
        final userId = data['user_id'] as String? ?? '';

        // Count unique users per survey (one document per user per survey)
        if (surveyId.isNotEmpty && userId.isNotEmpty) {
          if (!counts.containsKey(surveyId)) {
            counts[surveyId] = <String>{};
          }
          counts[surveyId]!.add(userId);
        }
      }

      return counts.map((key, value) => MapEntry(key, value.length));
    } catch (e) {
      throw Exception('Error fetching survey response counts: $e');
    }
  }
}
