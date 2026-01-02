import 'package:get/get.dart';
import '../../../data/network/remote/firebase_service.dart';
import '../../../data/models/user_profile_model.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  UserProfileModel? get userProfile => _authController.userProfile;

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      if (_authController.user == null) {
        throw Exception('User not authenticated');
      }

      await _firebaseService.updateUserProfile(
        _authController.user!.uid,
        updates,
      );

      await _authController.reloadUser();
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> uploadProfilePhoto(String imagePath) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      if (_authController.user == null) {
        throw Exception('User not authenticated');
      }

      final photoUrl = await _firebaseService.uploadProfilePhoto(
        _authController.user!.uid,
        imagePath,
      );

      await updateProfile({'photo': photoUrl});
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to upload photo: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
}

