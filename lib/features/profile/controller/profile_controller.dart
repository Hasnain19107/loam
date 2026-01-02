import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/network/remote/firebase_service.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../core/routes/app_routes.dart';
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

  // Edit Profile State
  final firstNameController = TextEditingController();
  final phoneController = TextEditingController();
  final workIndustryController = TextEditingController();
  final countryOfBirthController = TextEditingController();
  final RxString _relationshipStatus = 'single'.obs;
  final RxBool _hasChildren = false.obs;

  // Getters
  bool get isAdmin => _authController.isAdmin;
  String get relationshipStatus => _relationshipStatus.value;
  bool get hasChildren => _hasChildren.value;

  @override
  void onClose() {
    firstNameController.dispose();
    phoneController.dispose();
    workIndustryController.dispose();
    countryOfBirthController.dispose();
    super.onClose();
  }

  void initEditProfile() {
    final profile = userProfile;
    firstNameController.text = profile?.firstName ?? '';
    phoneController.text = profile?.phone ?? '';
    workIndustryController.text = profile?.workIndustry ?? '';
    countryOfBirthController.text = profile?.countryOfBirth ?? '';
    _relationshipStatus.value = profile?.relationshipStatus ?? 'single';
    _hasChildren.value = profile?.hasChildren ?? false;
  }

  void setRelationshipStatus(String status) {
    _relationshipStatus.value = status;
  }

  void setHasChildren(bool value) {
    _hasChildren.value = value;
  }

  Future<void> saveProfile() async {
    try {
      await updateProfile({
        'first_name': firstNameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'relationship_status': _relationshipStatus.value,
        'children': _hasChildren.value ? 'yes' : 'no',
        'work_industry': workIndustryController.text.trim(),
        'country_of_birth': countryOfBirthController.text.trim(),
      });
      Get.back();
    } catch (e) {
      // Error handled in updateProfile
    }
  }

  Future<void> signOut() async {
    await _authController.signOut();
  }

  void navigateToAdminDashboard() {
    Get.toNamed(AppRoutes.adminDashboard);
  }

  void navigateToAdminSettings() {
    Get.toNamed(AppRoutes.adminSettings);
  }
}
