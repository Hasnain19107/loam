import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../bottom_navigation/controller/main_navigation_controller.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isUploadingPhoto = false.obs;
  final Rxn<String> _localPhotoPath = Rxn<String>();
  final _picker = ImagePicker();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isUploadingPhoto => _isUploadingPhoto.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  UserProfileModel? get userProfile => _authController.userProfile;
  String? get localPhotoPath => _localPhotoPath.value;

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
      rethrow; // Re-throw so saveProfile can catch it and not navigate
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> uploadProfilePhoto(String imagePath) async {
    try {
      _isUploadingPhoto.value = true;
      _error.value = '';

      if (_authController.user == null) {
        throw Exception('User not authenticated');
      }

      final photoUrl = await _firebaseService.uploadProfilePhoto(
        _authController.user!.uid,
        imagePath,
      );

      await updateProfile({'avatar_url': photoUrl});
      _localPhotoPath.value = null; // Clear local path after successful upload
      Get.snackbar('Success', 'Profile photo updated successfully');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to upload photo: ${e.toString()}');
    } finally {
      _isUploadingPhoto.value = false;
    }
  }

  Future<void> handlePhotoUpload() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _localPhotoPath.value = image.path;
        await uploadProfilePhoto(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  // Edit Profile State
  final firstNameController = TextEditingController();
  final phoneController = TextEditingController();
  final workIndustryController = TextEditingController();
  final countryOfBirthController = TextEditingController();
  final RxString _relationshipStatus = 'single'.obs;
  final RxBool _hasChildren = false.obs;
  final RxString _gender = ''.obs;

  // Getters
  String get relationshipStatus => _relationshipStatus.value;
  bool get hasChildren => _hasChildren.value;
  String get gender => _gender.value;

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
    _gender.value = profile?.gender ?? '';
  }

  void setRelationshipStatus(String status) {
    _relationshipStatus.value = status;
  }

  void setHasChildren(bool value) {
    _hasChildren.value = value;
  }

  void setGender(String value) {
    _gender.value = value;
  }

  Future<void> saveProfile() async {
    try {
      await updateProfile({
        'first_name': firstNameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'relationship_status': _relationshipStatus.value,
        'children': _hasChildren.value ? 'yes' : 'no',
        'gender': _gender.value,
        'work_industry': workIndustryController.text.trim(),
        'country_of_birth': countryOfBirthController.text.trim(),
      });
      // Navigate to main navigation and set to profile tab (index 3, which is the 4th tab)
      final navController = Get.find<MainNavigationController>();
      navController.changePage(3); // Profile tab is at index 3
      Get.offNamed(AppRoutes.main);
    } catch (e) {
      // Error handled in updateProfile
    }
  }

  Future<void> signOut() async {
    await _authController.signOut();
  }

  // Helper method to get quiz answers from user profile
  Future<Map<String, dynamic>?> getQuizAnswers() async {
    if (_authController.user == null) return null;
    
    try {
      final profileDoc = await _firebaseService.getUserProfileDocument(_authController.user!.uid);
      if (profileDoc != null && profileDoc.containsKey('quiz_answers')) {
        final quizAnswers = profileDoc['quiz_answers'];
        if (quizAnswers is Map) {
          return Map<String, dynamic>.from(quizAnswers);
        }
      }
      return null;
    } catch (e) {
      print('Error getting quiz answers: $e');
      return null;
    }
  }

  // Get gender from quiz answers (question ID '3')
  Future<String?> getGenderFromQuiz() async {
    final quizAnswers = await getQuizAnswers();
    if (quizAnswers != null && quizAnswers.containsKey('3')) {
      final answer = quizAnswers['3'];
      if (answer is String) {
        // Answer is either 'Woman' or 'Man'
        return answer;
      }
    }
    return null;
  }
}
