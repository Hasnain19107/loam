import 'package:get/get.dart';
import 'firebase_service.dart';

/// Service to manage app-wide settings with caching
class AppSettingsService extends GetxService {
  final FirebaseService _firebaseService = FirebaseService();

  // Cached settings
  final RxBool _quizOnboardingEnabled = true.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;

  bool get quizOnboardingEnabled => _quizOnboardingEnabled.value;
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize settings when service is created
    initializeSettings();
  }

  /// Initialize and load app settings
  Future<void> initializeSettings() async {
    if (_isInitialized.value) return;

    try {
      _isLoading.value = true;
      await loadQuizOnboardingSetting();
      _isInitialized.value = true;
    } catch (e) {
      print('Error initializing app settings: $e');
      // Default to enabled if there's an error
      _quizOnboardingEnabled.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load quiz onboarding setting from Firebase
  Future<void> loadQuizOnboardingSetting() async {
    try {
      final value = await _firebaseService.getAppSetting('quiz_onboarding_enabled');
      if (value != null) {
        _quizOnboardingEnabled.value = value == true;
      } else {
        // Default to enabled if setting doesn't exist
        _quizOnboardingEnabled.value = true;
      }
    } catch (e) {
      print('Error loading quiz onboarding setting: $e');
      // Default to enabled on error
      _quizOnboardingEnabled.value = true;
    }
  }

  /// Refresh settings from Firebase (useful after admin changes)
  Future<void> refreshSettings() async {
    await loadQuizOnboardingSetting();
  }

  /// Check if quiz onboarding is enabled (with fallback to true)
  bool shouldShowQuiz() {
    return _quizOnboardingEnabled.value;
  }
}

