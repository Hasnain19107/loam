import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'package:loam/data/models/survey_question_model.dart';
import 'package:loam/data/models/survey_response_model.dart';

import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/constants/country_codes.dart';
import '../../../../data/network/local/preferences/shared_preference.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final SharedPreferenceService _prefsService = SharedPreferenceService();
  final _picker = ImagePicker();

  // Auth observables
  final Rx<firebase_auth.User?> _user = Rx<firebase_auth.User?>(null);
  final Rx<UserProfileModel?> _userProfile = Rx<UserProfileModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingGoogle = false.obs;
  final RxBool _isLoadingApple = false.obs;

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
  final RxString _onboardingPhotoLocalPath = ''.obs;
  final RxBool _onboardingNotifications = true.obs;
  final RxBool _isOnboardingSubmitting = false.obs;
  final RxBool _isUploadingPhoto = false.obs;
  final RxMap<String, dynamic> _quizAnswers = <String, dynamic>{}.obs;
  final RxList<SurveyQuestionModel> _quizQuestionsCache =
      <SurveyQuestionModel>[].obs;

  // Getters
  firebase_auth.User? get user => _user.value;
  UserProfileModel? get userProfile => _userProfile.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingGoogle => _isLoadingGoogle.value;
  bool get isLoadingApple => _isLoadingApple.value;
  bool get isAuthenticated => _user.value != null;
  bool get isEmailVerified =>
      (_user.value?.emailVerified ?? false) ||
      (_user.value?.providerData.any(
            (p) => p.providerId == 'google' || p.providerId == 'apple',
          ) ??
          false);

  // Onboarding getters
  int get onboardingStep => _onboardingStep.value;
  int get totalOnboardingSteps => _totalOnboardingSteps;
  String get onboardingPhone => _onboardingPhone.value;
  CountryCode get onboardingCountryCode => _onboardingCountryCode.value;
  DateTime? get onboardingBirthdate => _onboardingBirthdate.value;
  String? get onboardingPhotoUrl => _onboardingPhotoUrl.value;
  String get onboardingPhotoLocalPath => _onboardingPhotoLocalPath.value;
  bool get onboardingNotifications => _onboardingNotifications.value;
  bool get isOnboardingSubmitting => _isOnboardingSubmitting.value;
  bool get isUploadingPhoto => _isUploadingPhoto.value;

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
      } else {
        _userProfile.value = null;
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _firebaseService.getUserProfile(userId);
      _userProfile.value = profile;
      if (profile != null) {
        // Check if user is shadow blocked
        if (profile.isShadowBlocked) {
          print('User is shadow blocked. Signing out...');
          await _firebaseService.signOut();
          await _prefsService.clearUser();
          _user.value = null;
          _userProfile.value = null;
          Get.offAllNamed(AppRoutes.landing);
          Get.snackbar(
            'Access Denied',
            'Your account has been suspended. Please contact support for assistance.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
            duration: const Duration(seconds: 5),
          );
          return;
        }

        await _prefsService.saveUser(profile);

        // Check and save admin status
        try {
          final isAdmin = await _firebaseService.isAdmin(userId);
          await _prefsService.setIsAdmin(isAdmin);
          print('Admin status saved to prefs: $isAdmin');
        } catch (e) {
          print('Error saving admin status: $e');
        }

        await _prefsService.setLoggedIn(true);
      }
    } catch (e) {
      print('Error loading user profile: $e');
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

  // Helper method to save quiz answers if they exist
  Future<void> _saveQuizAnswersIfExists() async {
    // If no user is populated yet, try reloading/waiting briefly
    if (_user.value == null) {
      print('User is null, waiting for auth...');
      await Future.delayed(const Duration(milliseconds: 1000));
      await reloadUser();
    }

    if (_user.value == null) {
      print('User still null after wait. Cannot save quiz answers.');
      return;
    }

    print(
      'Attempting to save quiz answers. Answers: ${_quizAnswers.length}, Questions in Cache: ${_quizQuestionsCache.length}',
    );

    if (_quizAnswers.isNotEmpty && _quizQuestionsCache.isNotEmpty) {
      try {
        final userId = user!.uid;
        print('Saving for userId: $userId');

        // 1. Save to User Profile (Legacy/Easy Access)
        try {
          await _firebaseService.updateUserProfile(userId, {
            'quiz_answers': _quizAnswers,
          });
          print('Saved to user profile successfully.');
        } catch (e) {
          print('Error saving to user profile: $e');
        }

        // 2. Create SurveyResponseModel objects
        final responses = <SurveyResponseModel>[];
        final now = DateTime.now();

        // Assuming all questions belong to the same survey (taken from first question)
        final surveyId = _quizQuestionsCache.first.surveyId;

        for (var question in _quizQuestionsCache) {
          if (_quizAnswers.containsKey(question.id)) {
            final answerVal = _quizAnswers[question.id].toString();

            responses.add(
              SurveyResponseModel(
                id: '', // Will be generated by Firebase
                userId: userId,
                surveyId: surveyId,
                questionId: question.id,
                questionTextSnapshot: question.questionText,
                questionTypeSnapshot: question.questionType,
                answerValue: answerVal,
                createdAt: now,
              ),
            );
          }
        }

        // 3. Batch save to survey_responses collection
        if (responses.isNotEmpty) {
          print(
            'Saving ${responses.length} responses to survey_responses collection...',
          );
          // Add a small delay to ensure Firestore user creation propagation
          await Future.delayed(const Duration(milliseconds: 500));
          await _firebaseService.saveSurveyResponses(responses);
          print('Successfully saved to survey_responses collection.');
        } else {
          print('No responses generated to save.');
        }

        print('Quiz responses saved process completed.');
      } catch (e) {
        print('CRITICAL Error saving quiz answers: $e');
        // Don't throw - quiz answers are not critical for sign-up completion
      }
    } else {
      print(
        'Skipping quiz save: Auth=${user != null}, Answers=${_quizAnswers.length}, Questions=${_quizQuestionsCache.length}',
      );
    }
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

      // Save quiz answers immediately after sign-up
      await _saveQuizAnswersIfExists();

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

      // Clear form controllers on success
      loginEmailController.clear();
      loginPasswordController.clear();

      if (_user.value != null) {
        final userId = _user.value!.uid;
        // Check and save admin status explicitly before redirect
        final isAdmin = await _firebaseService.isAdmin(userId);
        await _prefsService.setIsAdmin(isAdmin);
        await _prefsService.setLoggedIn(
          true,
        ); // Ensure logged in state is saved

        // Redirect based on role
        if (isAdmin) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid email or password');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading.value = true;
      await _firebaseService.sendPasswordResetEmail(email);
      Get.snackbar('Success', 'Password reset email sent');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reset email: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign up methods (for auth choice page - allow new users)
  Future<void> signUpWithGoogle() async {
    try {
      _isLoadingGoogle.value = true;
      final result = await _firebaseService.signUpWithGoogle();

      if (result == null || result == false) {
        _isLoadingGoogle.value = false;
        return; // User cancelled or failed
      }

      // Wait for user profile to load
      await reloadUser();

      // Save quiz answers immediately after sign-up
      await _saveQuizAnswersIfExists();

      if (_user.value != null) {
        final userId = _user.value!.uid;
        // Check and save admin status explicitly
        final isAdmin = await _firebaseService.isAdmin(userId);
        await _prefsService.setIsAdmin(isAdmin);
        await _prefsService.setLoggedIn(true);
      }

      // Check if profile is complete
      if (!isOnboardingComplete()) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      print('SignUpWithGoogle Error in Controller: $e');
      String errorMessage = 'Failed to sign up with Google';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorString.contains('id_token') ||
          errorString.contains('certificate')) {
        errorMessage =
            'Configuration error. Please ensure your SHA-1 certificate fingerprint is added to Firebase Console.';
      } else {
        errorMessage = 'Failed to sign up with Google: ${e.toString()}';
      }

      Get.snackbar('Error', errorMessage);
    } finally {
      _isLoadingGoogle.value = false;
    }
  }

  Future<void> signUpWithApple() async {
    // Check if running on Android - Apple Sign-In is only available on iOS
    if (Platform.isAndroid) {
      Get.snackbar(
        'Not Available',
        'Apple Sign-In is only available on iOS devices. Please use Google Sign-In or email sign-up instead.',
      );
      return;
    }

    try {
      _isLoadingApple.value = true;
      final result = await _firebaseService.signUpWithApple();

      if (result == null || result == false) {
        _isLoadingApple.value = false;
        return; // User cancelled or failed
      }

      // Wait for user profile to load
      await reloadUser();

      // Save quiz answers immediately after sign-up
      await _saveQuizAnswersIfExists();

      if (_user.value != null) {
        final userId = _user.value!.uid;
        // Check and save admin status explicitly
        final isAdmin = await _firebaseService.isAdmin(userId);
        await _prefsService.setIsAdmin(isAdmin);
        await _prefsService.setLoggedIn(true);
      }

      // Check if profile is complete
      if (!isOnboardingComplete()) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      print('SignUpWithApple Error in Controller: $e');
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('cancelled') ||
          errorString.contains('canceled')) {
        _isLoadingApple.value = false;
        return;
      }
      Get.snackbar('Error', 'Failed to sign up with Apple: ${e.toString()}');
    } finally {
      _isLoadingApple.value = false;
    }
  }

  // Sign in methods (for login page - only existing users)
  Future<void> signInWithGoogle() async {
    try {
      _isLoadingGoogle.value = true;
      final result = await _firebaseService.signInWithGoogle();

      // If null, user cancelled - handle silently
      if (result == null) {
        _isLoadingGoogle.value = false;
        return;
      }

      // If false, new user (account doesn't exist)
      if (result == false) {
        _isLoadingGoogle.value = false;
        Get.snackbar(
          'Account Not Found',
          'No account exists with this Google account. Please sign up first.',
        );
        return;
      }

      // If true, existing user - proceed with sign in
      // Wait for user profile to load
      await reloadUser();

      // Save quiz answers if they exist (for existing users who completed quiz)
      await _saveQuizAnswersIfExists();

      if (_user.value != null) {
        final userId = _user.value!.uid;
        // Check and save admin status explicitly
        final isAdmin = await _firebaseService.isAdmin(userId);
        await _prefsService.setIsAdmin(isAdmin);
        await _prefsService.setLoggedIn(true);

        // Check if profile is complete
        if (!isOnboardingComplete()) {
          Get.offAllNamed(AppRoutes.onboarding);
        } else {
          // Redirect based on role
          if (isAdmin) {
            Get.offAllNamed(AppRoutes.adminDashboard);
          } else {
            Get.offAllNamed(AppRoutes.main);
          }
        }
      }
    } catch (e) {
      print('SignInWithGoogle Error in Controller: $e');
      print('Error stack: ${StackTrace.current}');

      String errorMessage = 'Failed to sign in with Google';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorString.contains('sign_in_failed') ||
          errorString.contains('sign_in_cancelled') ||
          errorString.contains('12500')) {
        errorMessage =
            'Google Sign-In failed. Please check your Firebase configuration and ensure SHA-1 certificate is added.';
      } else if (errorString.contains('cancelled') ||
          errorString.contains('12501')) {
        // User cancelled, don't show error
        _isLoadingGoogle.value = false;
        return;
      } else if (errorString.contains('id_token') ||
          errorString.contains('certificate')) {
        errorMessage =
            'Configuration error. Please ensure your SHA-1 certificate fingerprint is added to Firebase Console.';
      } else {
        errorMessage = 'Failed to sign in with Google: ${e.toString()}';
      }

      Get.snackbar('Error', errorMessage);
    } finally {
      _isLoadingGoogle.value = false;
    }
  }

  Future<void> signInWithApple() async {
    // Check if running on Android - Apple Sign-In is only available on iOS
    if (Platform.isAndroid) {
      Get.snackbar(
        'Not Available',
        'Apple Sign-In is only available on iOS devices. Please use Google Sign-In or email login instead.',
      );
      return;
    }

    try {
      _isLoadingApple.value = true;
      final result = await _firebaseService.signInWithApple();

      // If false, new user (account doesn't exist)
      if (result == false) {
        _isLoadingApple.value = false;
        Get.snackbar(
          'Account Not Found',
          'No account exists with this Apple ID. Please sign up first.',
        );
        return;
      }

      // If true, existing user - proceed with sign in
      // Wait for user profile to load
      await reloadUser();

      // Save quiz answers if they exist (for existing users who completed quiz)
      await _saveQuizAnswersIfExists();

      if (_user.value != null) {
        final userId = _user.value!.uid;
        // Check and save admin status explicitly
        final isAdmin = await _firebaseService.isAdmin(userId);
        await _prefsService.setIsAdmin(isAdmin);
        await _prefsService.setLoggedIn(true);

        // Check if profile is complete
        if (!isOnboardingComplete()) {
          Get.offAllNamed(AppRoutes.onboarding);
        } else {
          // Redirect based on role
          if (isAdmin) {
            Get.offAllNamed(AppRoutes.adminDashboard);
          } else {
            Get.offAllNamed(AppRoutes.main);
          }
        }
      }
    } catch (e) {
      print('SignInWithApple Error in Controller: $e');
      // Check if it's a cancellation error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('cancelled') ||
          errorString.contains('canceled')) {
        // User cancelled, don't show error
        _isLoadingApple.value = false;
        return;
      }
      Get.snackbar('Error', 'Failed to sign in with Apple: ${e.toString()}');
    } finally {
      _isLoadingApple.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      await _prefsService.clearUser();

      // Clear controllers
      loginEmailController.clear();
      loginPasswordController.clear();

      _user.value = null;
      _userProfile.value = null;
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

  void setQuizAnswers(
    Map<String, dynamic> answers,
    List<SurveyQuestionModel> questions,
  ) {
    _quizAnswers.value = answers;
    _quizQuestionsCache.assignAll(questions);
  }

  // Quiz state
  // Quiz logic moved to QuizController

  // Quiz methods

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

  Future<void> handleOnboardingStepAction() async {
    if (_onboardingStep.value == 4) {
      await handleOnboardingBirthdateNext();
    } else {
      await handleOnboardingNext();
    }
  }

  Future<void> handleOnboardingBirthdateNext() async {
    if (_onboardingBirthdate.value == null || user == null) return;

    // Proceed to next step/submit regardless of age
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
          if (_onboardingPhotoUrl.value != null &&
              _onboardingPhotoUrl.value!.isNotEmpty)
            'avatar_url': _onboardingPhotoUrl.value,
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
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (user == null) {
          Get.snackbar('Error', 'User not authenticated');
          return;
        }

        _isUploadingPhoto.value = true;
        _onboardingPhotoLocalPath.value = image.path;

        // Upload to Firebase Storage
        final photoUrl = await _firebaseService.uploadProfilePhoto(
          user!.uid,
          image.path,
        );

        // Save photo URL to profile immediately so it persists
        await _firebaseService.updateUserProfile(user!.uid, {
          'avatar_url': photoUrl,
        });

        // Update local state
        _onboardingPhotoUrl.value = photoUrl;

        // Reload user profile to get the updated photo
        await reloadUser();

        Get.snackbar('Success', 'Photo uploaded successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload photo: ${e.toString()}');
      _onboardingPhotoLocalPath.value = '';
      _onboardingPhotoUrl.value = null;
    } finally {
      _isUploadingPhoto.value = false;
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
    _onboardingPhotoLocalPath.value = '';
    _onboardingNotifications.value = true;
    _isOnboardingSubmitting.value = false;
    _isUploadingPhoto.value = false;
    // Don't clear quiz answers in resetOnboarding - they should persist until saved to Firebase
    // Quiz answers are cleared only after successful save or when explicitly needed
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
