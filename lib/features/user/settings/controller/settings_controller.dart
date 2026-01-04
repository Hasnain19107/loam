import 'package:get/get.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../auth/controller/auth_controller.dart';

class SettingsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  
  // Settings data
  List<String> get cities => ['Singapore'];
  List<String> get languages => ['English'];
  
  String get currentCity => _authController.userProfile?.city ?? 'Singapore';
  String get currentLanguage => _authController.userProfile?.language ?? 'English';
  bool get notificationsEnabled => _authController.userProfile?.notificationsEnabled ?? true;

  Future<void> updateNotificationSettings(bool enabled) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      if (_authController.user == null) {
        throw Exception('User not authenticated');
      }

      await _firebaseService.updateUserProfile(
        _authController.user!.uid,
        {'notifications_enabled': enabled},
      );

      await _authController.reloadUser();
      Get.snackbar('Success', 'Notification settings updated');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update settings: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      if (_authController.user == null) {
        throw Exception('User not authenticated');
      }

      await _firebaseService.updateUserProfile(
        _authController.user!.uid,
        {'language': language},
      );

      await _authController.reloadUser();
      Get.snackbar('Success', 'Language updated');
      Get.back();
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update language: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateCity(String city) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      if (_authController.user == null) {
        throw Exception('User not authenticated');
      }

      await _firebaseService.updateUserProfile(
        _authController.user!.uid,
        {'city': city},
      );

      await _authController.reloadUser();
      Get.snackbar('Success', 'City updated');
      Get.back();
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update city: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> handleCitySelect(String city) async {
    await updateCity(city);
  }

  Future<void> handleLanguageSelect(String language) async {
    await updateLanguage(language);
  }

  Future<void> handleNotificationToggle(bool value) async {
    await updateNotificationSettings(value);
  }
}

