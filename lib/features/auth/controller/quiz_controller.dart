import 'package:get/get.dart';
import '../../../data/network/remote/firebase_service.dart';
import '../../../data/models/survey_question_model.dart';
import '../../../core/routes/app_routes.dart';
import 'auth_controller.dart';

class QuizController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = true.obs;
  final RxList<SurveyQuestionModel> _questions = <SurveyQuestionModel>[].obs;
  final RxInt _currentStep = 0.obs;
  final RxMap<String, dynamic> _answers = <String, dynamic>{}.obs;
  final RxnInt _scaleValue = RxnInt();

  bool get isLoading => _isLoading.value;
  List<SurveyQuestionModel> get questions => _questions;
  int get currentStep => _currentStep.value;
  int? get scaleValue => _scaleValue.value;
  Map<String, dynamic> get answers => _answers;

  @override
  void onInit() {
    super.onInit();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    try {
      _isLoading.value = true;
      final activeSurvey = await _firebaseService.getActiveSurvey();

      if (activeSurvey != null) {
        final surveyQuestions = await _firebaseService.getSurveyQuestions(
          activeSurvey.id,
        );
        _questions.assignAll(surveyQuestions);
      }
    } catch (e) {
      print('Failed to load quiz: ${e.toString()}');
      // Using print instead of snackbar to avoid UI noise on auto-load
    } finally {
      _isLoading.value = false;
    }
  }

  void setScaleValue(int value) {
    _scaleValue.value = value;
  }

  void handleAnswer(dynamic answer) {
    if (_questions.isEmpty) return;

    final currentQuestion = _questions[_currentStep.value];
    _answers[currentQuestion.id] = answer;

    if (_currentStep.value < _questions.length - 1) {
      _currentStep.value++;
      _scaleValue.value = null; // Reset for next question

      // Restore previous answer if exists
      final nextQuestion = _questions[_currentStep.value];
      if (_answers.containsKey(nextQuestion.id) &&
          nextQuestion.questionType == 'scale_1_10') {
        _scaleValue.value = int.tryParse(_answers[nextQuestion.id].toString());
      }
    } else {
      completeQuiz();
    }
  }

  void handleBack() {
    if (_currentStep.value > 0) {
      _currentStep.value--;

      final prevQuestion = _questions[_currentStep.value];
      if (_answers.containsKey(prevQuestion.id) &&
          prevQuestion.questionType == 'scale_1_10') {
        _scaleValue.value = int.tryParse(_answers[prevQuestion.id].toString());
      } else {
        _scaleValue.value = null;
      }
    } else {
      Get.back();
    }
  }

  void completeQuiz() {
    // Save answers to AuthController and navigate
    _authController.setQuizAnswers(_answers, _questions);
    Get.toNamed(AppRoutes.authChoice);
  }
}
