import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_profile_model.dart';

class SharedPreferenceService {
  static const String _userKey = 'user_profile';
  static const String _isLoggedInKey = 'is_logged_in';

  static final SharedPreferenceService _instance =
      SharedPreferenceService._internal();

  factory SharedPreferenceService() {
    return _instance;
  }

  SharedPreferenceService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth State
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs?.setBool(_isLoggedInKey, isLoggedIn);
  }

  bool get isLoggedIn => _prefs?.getBool(_isLoggedInKey) ?? false;
  
  static const String _isAdminKey = 'is_admin';
  Future<void> setIsAdmin(bool isAdmin) async {
    await _prefs?.setBool(_isAdminKey, isAdmin);
  }
  
  bool get isAdmin => _prefs?.getBool(_isAdminKey) ?? false;

  // User Profile
  Future<void> saveUser(UserProfileModel user) async {
    final map = user.toJson();
    // Convert timestamps to milliseconds for storage to avoid serialization issues
    if (map['created_at'] is Timestamp) {
      map['created_at'] =
          (map['created_at'] as Timestamp).millisecondsSinceEpoch;
    }
    if (map['updated_at'] is Timestamp) {
      map['updated_at'] =
          (map['updated_at'] as Timestamp).millisecondsSinceEpoch;
    }

    await _prefs?.setString(_userKey, jsonEncode(map));
  }

  UserProfileModel? getUser() {
    final userStr = _prefs?.getString(_userKey);
    if (userStr == null) return null;

    try {
      final map = jsonDecode(userStr);
      // Convert milliseconds back to Timestamp for the model
      if (map['created_at'] is int) {
        map['created_at'] = Timestamp.fromMillisecondsSinceEpoch(
          map['created_at'],
        );
      }
      if (map['updated_at'] is int) {
        map['updated_at'] = Timestamp.fromMillisecondsSinceEpoch(
          map['updated_at'],
        );
      }

      return UserProfileModel.fromJson(map);
    } catch (e) {
      print('Error decoding user profile from prefs: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs?.remove(_userKey);
    await _prefs?.remove(_isLoggedInKey);
  }
}
