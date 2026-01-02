import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';

import '../../../data/network/remote/firebase_service.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/country_codes.dart';
import '../../../data/network/local/preferences/shared_preference.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final SharedPreferenceService _prefsService = SharedPreferenceService();
  final _picker = ImagePicker();

  // Auth observables
  final Rx<firebase_auth.User?> _user = Rx<firebase_auth.User?>(null);
  final Rx<UserProfileModel?> _userProfile = Rx<UserProfileModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isAdmin = false.obs;
  final RxBool _isSuperAdmin = false.obs;

  // Login/Signup form controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController =
      TextEditingController();

  // Onboarding state
  final RxInt _onboardingStep = 1.obs;
  final int _totalOnboardingSteps = 6;
  final RxString _onboardingPhone = ''.obs;
  final Rx<CountryCode> _onboardingCountryCode = defaultCountry.obs;
  final TextEditingController onboardingFirstNameController =
      TextEditingController();
  final TextEditingController onboardingLastNameController =
      TextEditingController();
  final TextEditingController onboardingPhoneController =
      TextEditingController();
  final RxString _onboardingFirstName = ''.obs;
  final RxString _onboardingLastName = ''.obs;
  final Rx<DateTime?> _onboardingBirthdate = Rx<DateTime?>(null);
  final Rxn<String> _onboardingPhotoUrl = Rxn<String>();
  final RxBool _onboardingNotifications = true.obs;
  final RxBool _isOnboardingSubmitting = false.obs;
  final RxMap<String, dynamic> _quizAnswers = <String, dynamic>{}.obs;

  // Getters
  firebase_auth.User? get user => _user.value;
  UserProfileModel? get userProfile => _userProfile.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _user.value != null;
  bool get isEmailVerified =>
      (_user.value?.emailVerified ?? false) ||
      (_user.value?.providerData.any(
            (p) => p.providerId == 'google' || p.providerId == 'apple',
          ) ??
          false);
  bool get isAdmin => _isAdmin.value;
  bool get isSuperAdmin => _isSuperAdmin.value;

  // Onboarding getters
  int get onboardingStep => _onboardingStep.value;
  int get totalOnboardingSteps => _totalOnboardingSteps;
  String get onboardingPhone => _onboardingPhone.value;
  CountryCode get onboardingCountryCode => _onboardingCountryCode.value;
  DateTime? get onboardingBirthdate => _onboardingBirthdate.value;
  String? get onboardingPhotoUrl => _onboardingPhotoUrl.value;
  bool get onboardingNotifications => _onboardingNotifications.value;
  bool get isOnboardingSubmitting => _isOnboardingSubmitting.value;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    _listenToAuthChanges();
    _setupOnboardingListeners();
  }

  Future<void> _initPrefs() async {
    await _prefsService.init();
    if (_prefsService.isLoggedIn) {
      final localProfile = _prefsService.getUser();
      if (localProfile != null) {
        _userProfile.value = localProfile;
      }
    }
  }

  void _setupOnboardingListeners() {
    onboardingFirstNameController.addListener(() {
      _onboardingFirstName.value = onboardingFirstNameController.text;
    });
    onboardingLastNameController.addListener(() {
      _onboardingLastName.value = onboardingLastNameController.text;
    });
    onboardingPhoneController.addListener(() {
      _onboardingPhone.value = onboardingPhoneController.text;
    });
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    onboardingFirstNameController.dispose();
    onboardingLastNameController.dispose();
    onboardingPhoneController.dispose();
    super.onClose();
  }

  void _listenToAuthChanges() {
    _firebaseService.authStateChanges.listen((firebaseUser) {
      _user.value = firebaseUser;
      if (firebaseUser != null) {
        _loadUserProfile(firebaseUser.uid);
        _checkAdminStatus(firebaseUser.uid);
      } else {
        _userProfile.value = null;
        _isAdmin.value = false;
        _isSuperAdmin.value = false;
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _firebaseService.getUserProfile(userId);
      _userProfile.value = profile;
      if (profile != null) {
        await _prefsService.saveUser(profile);
        await _prefsService.setLoggedIn(true);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _checkAdminStatus(String userId) async {
    try {
      final roles = await _firebaseService.getUserRoles(userId);
      _isSuperAdmin.value = roles.contains(AppConstants.roleSuperAdmin);
      _isAdmin.value =
          _isSuperAdmin.value || roles.contains(AppConstants.roleEventHost);
    } catch (e) {
      print('Error checking admin status: $e');
    }
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value, {bool isSignup = false}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (isSignup && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Auth methods
  Future<void> signUp() async {
    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text;

    if (validateEmail(email) != null ||
        validatePassword(password, isSignup: true) != null) {
      return;
    }

    try {
      _isLoading.value = true;
      await _firebaseService.signUp(email, password);

      // Wait for user profile to load
      await reloadUser();

      if (!isOnboardingComplete()) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signIn() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (validateEmail(email) != null || validatePassword(password) != null) {
      return;
    }

    try {
      _isLoading.value = true;
      await _firebaseService.signIn(email, password);

      // Wait for user profile to load
      await reloadUser();

      // Redirect to home after successful login
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar('Error', 'Invalid email or password');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      await _prefsService.clearUser();
      _user.value = null;
      _userProfile.value = null;
      _isAdmin.value = false;
      _isSuperAdmin.value = false;
      Get.offAllNamed(AppRoutes.landing);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  Future<void> reloadUser() async {
    try {
      await _firebaseService.reloadUser();
      if (_user.value != null) {
        await _loadUserProfile(_user.value!.uid);
        await _checkAdminStatus(_user.value!.uid);
      }
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  // Onboarding methods
  void setOnboardingCountryCode(CountryCode code) {
    _onboardingCountryCode.value = code;
  }

  void setOnboardingPhone(String phone) {
    _onboardingPhone.value = phone;
  }

  void setOnboardingBirthdate(DateTime? date) {
    _onboardingBirthdate.value = date;
  }

  void setOnboardingNotifications(bool value) {
    _onboardingNotifications.value = value;
  }

  void setQuizAnswers(Map<String, dynamic> answers) {
    _quizAnswers.value = answers;
  }

  // Quiz state
  final RxInt _quizStep = 0.obs;
  final RxList<Map<String, dynamic>> _quizQuestions =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, String> _quizAnswersMap = <String, String>{}.obs;
  final RxnInt _quizScaleValue = RxnInt();
  final RxBool _isQuizLoading = true.obs;

  // Quiz getters
  int get quizStep => _quizStep.value;
  List<Map<String, dynamic>> get quizQuestions => _quizQuestions;
  Map<String, String> get quizAnswersMap => _quizAnswersMap;
  int? get quizScaleValue => _quizScaleValue.value;
  bool get isQuizLoading => _isQuizLoading.value;

  // Quiz methods
  void setQuizLoading(bool loading) {
    _isQuizLoading.value = loading;
  }

  void assignQuizQuestions(List<Map<String, dynamic>> questions) {
    _quizQuestions.assignAll(questions);
  }

  void setQuizScaleValue(int? value) {
    _quizScaleValue.value = value;
  }

  void handleQuizAnswer(String answer) {
    final question = _quizQuestions[_quizStep.value];
    _quizAnswersMap[question['id']] = answer;

    if (_quizStep.value < _quizQuestions.length - 1) {
      _quizStep.value++;
      _quizScaleValue.value = null;
    } else {
      // Save answers and navigate
      setQuizAnswers(Map<String, dynamic>.from(_quizAnswersMap));
      Get.toNamed(AppRoutes.authChoice);
    }
  }

  void handleQuizBack() {
    if (_quizStep.value > 0) {
      _quizStep.value--;

      // Restore scale value if previous question was scale type
      final prevQuestion = _quizQuestions[_quizStep.value];
      if (_quizAnswersMap.containsKey(prevQuestion['id'])) {
        if (prevQuestion['question_type'] == 'scale_1_10') {
          _quizScaleValue.value = int.tryParse(
            _quizAnswersMap[prevQuestion['id']] ?? '',
          );
        } else {
          _quizScaleValue.value = null;
        }
      } else {
        _quizScaleValue.value = null;
      }
    } else {
      Get.back();
    }
  }

  void resetQuiz() {
    _quizStep.value = 0;
    _quizAnswersMap.clear();
    _quizScaleValue.value = null;
    _isQuizLoading.value = true;
    _quizQuestions.clear();
  }

  bool canProceedOnboarding() {
    switch (_onboardingStep.value) {
      case 1:
        return _onboardingPhone.value.trim().isNotEmpty;
      case 2:
        return _onboardingFirstName.value.trim().isNotEmpty;
      case 3:
        return _onboardingLastName.value.trim().isNotEmpty;
      case 4:
        return _onboardingBirthdate.value != null;
      case 5:
      case 6:
        return true;
      default:
        return false;
    }
  }

  String getOnboardingButtonText() {
    switch (_onboardingStep.value) {
      case 4:
        return 'Continue';
      case 5:
        return _onboardingPhotoUrl.value != null &&
                _onboardingPhotoUrl.value!.isNotEmpty
            ? 'Next'
            : 'Skip for now';
      case 6:
        if (_isOnboardingSubmitting.value) {
          return 'Saving...';
        }
        return _onboardingNotifications.value
            ? 'Enable notifications'
            : 'Continue without';
      default:
        return 'Next';
    }
  }

  int _calculateAge(DateTime birthdate) {
    final today = DateTime.now();
    int age = today.year - birthdate.year;
    final monthDiff = today.month - birthdate.month;
    if (monthDiff < 0 || (monthDiff == 0 && today.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  Future<void> handleOnboardingStepAction() async {
    if (_onboardingStep.value == 4) {
      await handleOnboardingBirthdateNext();
    } else {
      await handleOnboardingNext();
    }
  }

  Future<void> handleOnboardingBirthdateNext() async {
    if (_onboardingBirthdate.value == null || user == null) return;

    final age = _calculateAge(_onboardingBirthdate.value!);

    if (age < AppConstants.minimumAge) {
      _isOnboardingSubmitting.value = true;

      final dateString =
          '${_onboardingBirthdate.value!.year}-${_onboardingBirthdate.value!.month.toString().padLeft(2, '0')}-${_onboardingBirthdate.value!.day.toString().padLeft(2, '0')}';

      await _firebaseService.updateUserProfile(user!.uid, {
        'date_of_birth': dateString,
        'is_shadow_blocked': true,
      });

      _isOnboardingSubmitting.value = false;
      Get.offAllNamed(AppRoutes.blocked);
      return;
    }

    // User is 21+, proceed to next step/submit
    // Since we reduced steps to 4, we call handleOnboardingNext which will see
    // step 4 matches total steps (or close to it) and handle submission logic.
    await handleOnboardingNext();
  }

  Future<void> handleOnboardingNext() async {
    if (_onboardingStep.value < _totalOnboardingSteps) {
      _onboardingStep.value++;
    } else {
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      _isOnboardingSubmitting.value = true;

      try {
        final fullPhone =
            '${_onboardingCountryCode.value.code} ${_onboardingPhone.value}';
        final dateString = _onboardingBirthdate.value != null
            ? '${_onboardingBirthdate.value!.year}-${_onboardingBirthdate.value!.month.toString().padLeft(2, '0')}-${_onboardingBirthdate.value!.day.toString().padLeft(2, '0')}'
            : '';

        await _firebaseService.updateUserProfile(user!.uid, {
          'first_name': onboardingFirstNameController.text.trim(),
          'last_name': onboardingLastNameController.text.trim(),
          'phone_number': fullPhone,
          'date_of_birth': dateString,
          'notifications_enabled': _onboardingNotifications.value,
          // Avatar URL excluded as per request to prevent upload issues
          if (_quizAnswers.isNotEmpty) 'quiz_answers': _quizAnswers,
        });

        await reloadUser();

        Get.offAllNamed(AppRoutes.main);
      } catch (e) {
        print('Error completing onboarding: $e');
        Get.snackbar('Error', 'Failed to save profile: ${e.toString()}');
      } finally {
        _isOnboardingSubmitting.value = false;
      }
    }
  }

  Future<void> handleOnboardingPhotoUpload() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // TODO: Upload to Firebase Storage and get URL
      _onboardingPhotoUrl.value =
          image.path; // Temporary, should be Firebase URL
    }
  }

  void resetOnboarding() {
    _onboardingStep.value = 1;
    _onboardingPhone.value = '';
    _onboardingCountryCode.value = defaultCountry;
    onboardingFirstNameController.clear();
    onboardingLastNameController.clear();
    onboardingPhoneController.clear();
    _onboardingBirthdate.value = null;
    _onboardingPhotoUrl.value = null;
    _onboardingNotifications.value = true;
    _isOnboardingSubmitting.value = false;
    _quizAnswers.clear();
  }

  bool isBlocked() {
    return _userProfile.value?.isShadowBlocked ?? false;
  }

  bool isOnboardingComplete() {
    final profile = _userProfile.value;
    if (profile == null) return false;
    // Check if user has completed all onboarding steps:
    // Step 1: Phone number
    // Step 2: First name
    // Step 3: Last name (optional, but we check if onboarding was completed)
    // Step 4: Date of birth
    // Step 5: Photo (optional - not required)
    // Step 6: Notifications (always set, defaults to true)
    return profile.firstName != null &&
        profile.firstName!.isNotEmpty &&
        profile.phone != null &&
        profile.phone!.isNotEmpty &&
        profile.dateOfBirth != null &&
        profile.dateOfBirth!.isNotEmpty &&
        profile.notificationsEnabled != null;
  }
}
