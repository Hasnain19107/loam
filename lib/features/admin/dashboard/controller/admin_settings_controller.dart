import 'package:get/get.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/network/remote/app_settings_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../../core/routes/app_routes.dart';

class AdminSettingsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  // State
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingInvites = false.obs;
  final RxBool _isSavingQuizSetting = false.obs;
  final RxList<Map<String, dynamic>> _admins = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _invites = <Map<String, dynamic>>[].obs;
  final RxString _email = ''.obs;
  final RxString _emailError = ''.obs;
  final RxBool _isAddingAdmin = false.obs;
  final RxString _addAdminSuccessMessage = ''.obs;
  final RxBool _quizOnboardingEnabled = true.obs;
  final RxBool _isSuperAdmin = false.obs;
  final RxBool _approvalRequired = true.obs;
  final RxBool _revealLocationAfterApproval = true.obs;
  final RxBool _isSavingApprovalRequired = false.obs;
  final RxBool _isSavingRevealLocation = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingInvites => _isLoadingInvites.value;
  bool get isSavingQuizSetting => _isSavingQuizSetting.value;
  bool get isSavingApprovalRequired => _isSavingApprovalRequired.value;
  bool get isSavingRevealLocation => _isSavingRevealLocation.value;
  List<Map<String, dynamic>> get admins => _admins;
  List<Map<String, dynamic>> get invites => _invites;
  String get email => _email.value;
  String? get emailError => _emailError.value.isEmpty ? null : _emailError.value;
  bool get isAddingAdmin => _isAddingAdmin.value;
  String? get addAdminSuccessMessage => _addAdminSuccessMessage.value.isEmpty ? null : _addAdminSuccessMessage.value;
  bool get quizOnboardingEnabled => _quizOnboardingEnabled.value;
  bool get isSuperAdmin => _isSuperAdmin.value;
  bool get approvalRequired => _approvalRequired.value;
  bool get revealLocationAfterApproval => _revealLocationAfterApproval.value;
  String? get currentUserId => _authController.user?.uid;

  @override
  void onInit() {
    super.onInit();
    _checkSuperAdminStatus();
    loadData();
  }

  Future<void> _checkSuperAdminStatus() async {
    try {
      final userId = _authController.user?.uid;
      if (userId != null) {
        _isSuperAdmin.value = await _firebaseService.isSuperAdmin(userId);
      }
    } catch (e) {
      print('Error checking super admin status: $e');
    }
  }

  Future<void> loadData() async {
    await Future.wait([
      loadAdmins(),
      loadInvites(),
      loadQuizOnboardingSetting(),
      loadEventDefaults(),
    ]);
  }

  Future<void> loadAdmins() async {
    try {
      _isLoading.value = true;
      final adminsList = await _firebaseService.getAdmins();
      _admins.value = adminsList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load admins: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadInvites() async {
    try {
      _isLoadingInvites.value = true;
      final invitesList = await _firebaseService.getAdminInvites();
      _invites.value = invitesList;
    } catch (e) {
      // Silently fail - just set empty list and log error
      print('Error loading invites: $e');
      _invites.value = [];
    } finally {
      _isLoadingInvites.value = false;
    }
  }

  Future<void> loadQuizOnboardingSetting() async {
    try {
      final value = await _firebaseService.getAppSetting('quiz_onboarding_enabled');
      if (value != null) {
        _quizOnboardingEnabled.value = value == true;
      }
    } catch (e) {
      print('Error loading quiz onboarding setting: $e');
    }
  }

  Future<void> loadEventDefaults() async {
    try {
      final approvalValue = await _firebaseService.getAppSetting('event_default_requires_approval');
      if (approvalValue != null) {
        _approvalRequired.value = approvalValue == true;
      }

      final locationValue = await _firebaseService.getAppSetting('event_default_reveal_location_after_approval');
      if (locationValue != null) {
        _revealLocationAfterApproval.value = locationValue == true;
      }
    } catch (e) {
      print('Error loading event defaults: $e');
    }
  }

  void setEmail(String value) {
    _email.value = value;
    _emailError.value = '';
    _addAdminSuccessMessage.value = ''; // Clear success message when user types
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> addAdmin() async {
    final emailValue = _email.value.trim();
    
    if (emailValue.isEmpty) {
      _emailError.value = 'Email is required';
      return;
    }

    if (!_validateEmail(emailValue)) {
      _emailError.value = 'Please enter a valid email address';
      return;
    }

    try {
      _isAddingAdmin.value = true;
      _emailError.value = '';
      
      await _firebaseService.createAdminInvite(
        emailValue,
        AppConstants.roleEventHost,
      );
      
      _addAdminSuccessMessage.value = 'Admin added successfully';
      _email.value = '';
      // Reload both admins and invites since user might have been added directly
      await Future.wait([loadAdmins(), loadInvites()]);
      
      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _addAdminSuccessMessage.value = '';
      });
      
      Get.snackbar('Success', 'Admin added successfully');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('already been invited')) {
        _emailError.value = 'This email has already been invited';
      } else {
        Get.snackbar('Error', 'Failed to add admin: ${e.toString()}');
      }
    } finally {
      _isAddingAdmin.value = false;
    }
  }

  Future<void> removeAdmin(String roleId, String userId) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == userId) {
      Get.snackbar('Error', 'You cannot remove yourself');
      return;
    }

    try {
      await _firebaseService.removeAdmin(roleId);
      Get.snackbar('Success', 'Admin removed');
      await loadAdmins();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove admin: ${e.toString()}');
    }
  }

  Future<void> removeInvite(String inviteId) async {
    try {
      await _firebaseService.removeAdminInvite(inviteId);
      Get.snackbar('Success', 'Invite removed');
      await loadInvites();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove invite: ${e.toString()}');
    }
  }

  Future<void> toggleQuizOnboarding(bool enabled) async {
    try {
      _isSavingQuizSetting.value = true;
      await _firebaseService.setAppSetting('quiz_onboarding_enabled', enabled);
      _quizOnboardingEnabled.value = enabled;
      
      // Refresh the app-wide settings service so changes take effect immediately
      if (Get.isRegistered<AppSettingsService>()) {
        final settingsService = Get.find<AppSettingsService>();
        await settingsService.refreshSettings();
      }
      
      Get.snackbar(
        'Success',
        enabled ? 'Quiz onboarding enabled' : 'Quiz onboarding disabled',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update setting: ${e.toString()}');
    } finally {
      _isSavingQuizSetting.value = false;
    }
  }

  Future<void> toggleApprovalRequired(bool enabled) async {
    try {
      _isSavingApprovalRequired.value = true;
      await _firebaseService.setAppSetting('event_default_requires_approval', enabled);
      _approvalRequired.value = enabled;
      
      // If approval is disabled, also disable reveal location after approval
      if (!enabled) {
        await _firebaseService.setAppSetting('event_default_reveal_location_after_approval', false);
        _revealLocationAfterApproval.value = false;
      }
      
      Get.snackbar(
        'Success',
        enabled ? 'Approval required enabled' : 'Approval required disabled',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update setting: ${e.toString()}');
    } finally {
      _isSavingApprovalRequired.value = false;
    }
  }

  Future<void> toggleRevealLocationAfterApproval(bool enabled) async {
    try {
      _isSavingRevealLocation.value = true;
      await _firebaseService.setAppSetting('event_default_reveal_location_after_approval', enabled);
      _revealLocationAfterApproval.value = enabled;
      Get.snackbar(
        'Success',
        enabled ? 'Reveal location after approval enabled' : 'Reveal location after approval disabled',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update setting: ${e.toString()}');
    } finally {
      _isSavingRevealLocation.value = false;
    }
  }

  void navigateToBlockedUsers() {
    Get.toNamed('${AppRoutes.adminUsers}?filter=blocked');
  }
}

