import 'package:get/get.dart';
import 'firebase_service.dart';

/// Service to manage app-wide settings with caching
class AppSettingsService extends GetxService {
  final FirebaseService _firebaseService = FirebaseService();

  // Cached settings
  final RxBool _quizOnboardingEnabled = true.obs;
  final RxBool _alphacodeRequired = false.obs;
  final RxString _alphacodeValue = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;

  bool get quizOnboardingEnabled => _quizOnboardingEnabled.value;
  bool get alphacodeRequired => _alphacodeRequired.value;
  String get alphacodeValue => _alphacodeValue.value;
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
      await Future.wait([
        loadQuizOnboardingSetting(),
        loadAlphacodeSettings(),
      ]);
      _isInitialized.value = true;
    } catch (e) {
      print('Error initializing app settings: $e');
      _quizOnboardingEnabled.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load alphacode settings from Firebase
  Future<void> loadAlphacodeSettings() async {
    try {
      final required = await _firebaseService.getAppSetting('alphacode_required');
      final value = await _firebaseService.getAppSetting('alphacode_value');
      _alphacodeRequired.value = required == true;
      _alphacodeValue.value = value is String ? value : '';
    } catch (e) {
      print('Error loading alphacode settings: $e');
      _alphacodeRequired.value = false;
      _alphacodeValue.value = '';
    }
  }

  /// Check if access code matches the configured value (case-insensitive trim)
  bool validateAccessCode(String input) {
    final trimmed = _alphacodeValue.value.trim();
    if (trimmed.isEmpty) return false;
    return input.trim().toLowerCase() == trimmed.toLowerCase();
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
    await Future.wait([
      loadQuizOnboardingSetting(),
      loadAlphacodeSettings(),
    ]);
  }

  /// Check if quiz onboarding is enabled (with fallback to true)
  bool shouldShowQuiz() {
    return _quizOnboardingEnabled.value;
  }
}

