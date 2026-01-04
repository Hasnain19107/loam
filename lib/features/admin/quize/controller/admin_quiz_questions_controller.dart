import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/survey_model.dart';
import '../../../../data/models/survey_question_model.dart';

class AdminQuizQuestionsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxBool _isLoading = false.obs;
  final Rx<SurveyModel?> _survey = Rx<SurveyModel?>(null);
  final RxList<SurveyQuestionModel> _questions = <SurveyQuestionModel>[].obs;
  final RxBool _showForm = false.obs;
  final Rx<SurveyQuestionModel?> _editingQuestion = Rx<SurveyQuestionModel?>(
    null,
  );

  // Form state
  final RxString _questionText = ''.obs;
  final RxString _questionType = 'multiple_choice'.obs;
  final RxList<String> _options = <String>['', ''].obs;
  final RxString _scaleLabelLow = ''.obs;
  final RxString _scaleLabelHigh = ''.obs;

  bool get isLoading => _isLoading.value;
  SurveyModel? get survey => _survey.value;
  List<SurveyQuestionModel> get questions => _questions;
  bool get showForm => _showForm.value;
  SurveyQuestionModel? get editingQuestion => _editingQuestion.value;
  String get questionText => _questionText.value;
  String get questionType => _questionType.value;
  List<String> get options => _options;
  String get scaleLabelLow => _scaleLabelLow.value;
  String get scaleLabelHigh => _scaleLabelHigh.value;

  // Method to start loading immediately (sets loading state synchronously)
  void startLoading() {
    _isLoading.value = true;
  }

  Future<void> loadSurveyAndQuestions(String surveyId) async {
    try {
      _isLoading.value = true;
      final surveyData = await _firebaseService.getSurvey(surveyId);
      _survey.value = surveyData;

      if (surveyData != null) {
        final questionsList = await _firebaseService.getSurveyQuestions(
          surveyId,
        );
        _questions.value = questionsList;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load quiz: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void resetForm() {
    _questionText.value = '';
    _questionType.value = 'multiple_choice';
    _options.value = ['', ''];
    _scaleLabelLow.value = '';
    _scaleLabelHigh.value = '';
    _editingQuestion.value = null;
    _showForm.value = false;
  }

  void handleEdit(SurveyQuestionModel question) {
    _editingQuestion.value = question;
    _questionText.value = question.questionText;
    _questionType.value = question.questionType;
    _options.value = question.options ?? ['', ''];
    _scaleLabelLow.value = question.scaleLabelLow ?? '';
    _scaleLabelHigh.value = question.scaleLabelHigh ?? '';
    _showForm.value = true;
  }

  Future<void> handleSave() async {
    if (_questionText.value.trim().isEmpty) {
      Get.snackbar('Error', 'Question text is required');
      return;
    }

    if (_questionType.value == 'multiple_choice') {
      final validOptions = _options.where((o) => o.trim().isNotEmpty).toList();
      if (validOptions.length < 2) {
        Get.snackbar('Error', 'At least 2 options are required');
        return;
      }
    }

    try {
      final surveyId = _survey.value?.id ?? '';
      if (surveyId.isEmpty) {
        Get.snackbar('Error', 'Survey ID is missing');
        return;
      }

      final questionData = {
        'survey_id': surveyId,
        'question_text': _questionText.value.trim(),
        'question_type': _questionType.value,
        'options': _questionType.value == 'multiple_choice'
            ? _options.where((o) => o.trim().isNotEmpty).toList()
            : null,
        'scale_label_low': _questionType.value == 'scale_1_10'
            ? (_scaleLabelLow.value.trim().isEmpty
                  ? null
                  : _scaleLabelLow.value.trim())
            : null,
        'scale_label_high': _questionType.value == 'scale_1_10'
            ? (_scaleLabelHigh.value.trim().isEmpty
                  ? null
                  : _scaleLabelHigh.value.trim())
            : null,
        'display_order':
            _editingQuestion.value?.displayOrder ?? _questions.length + 1,
      };

      if (_editingQuestion.value != null) {
        await _firebaseService.updateSurveyQuestion(
          _editingQuestion.value!.id,
          questionData,
        );
        Get.snackbar('Success', 'Question updated');
      } else {
        // Generate UUID for the new question
        const uuid = Uuid();
        final questionId = uuid.v4();

        final newQuestion = SurveyQuestionModel(
          id: questionId,
          surveyId: surveyId,
          questionText: _questionText.value.trim(),
          questionType: _questionType.value,
          options: _questionType.value == 'multiple_choice'
              ? _options.where((o) => o.trim().isNotEmpty).toList()
              : null,
          scaleLabelLow: _questionType.value == 'scale_1_10'
              ? (_scaleLabelLow.value.trim().isEmpty
                    ? null
                    : _scaleLabelLow.value.trim())
              : null,
          scaleLabelHigh: _questionType.value == 'scale_1_10'
              ? (_scaleLabelHigh.value.trim().isEmpty
                    ? null
                    : _scaleLabelHigh.value.trim())
              : null,
          displayOrder: _questions.length + 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firebaseService.createSurveyQuestion(newQuestion);
        Get.snackbar('Success', 'Question added');
      }

      resetForm();
      await loadSurveyAndQuestions(surveyId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save question: ${e.toString()}');
    }
  }

  Future<void> handleDelete(String questionId) async {
    try {
      await _firebaseService.deleteSurveyQuestion(questionId);
      Get.snackbar('Success', 'Question deleted');
      final surveyId = _survey.value?.id ?? '';
      if (surveyId.isNotEmpty) {
        await loadSurveyAndQuestions(surveyId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete question: ${e.toString()}');
    }
  }

  void addOption() {
    _options.add('');
  }

  void removeOption(int index) {
    if (_options.length > 2) {
      _options.removeAt(index);
    }
  }

  void updateOption(int index, String value) {
    if (index < _options.length) {
      _options[index] = value;
      _options.refresh();
    }
  }

  void setQuestionText(String value) => _questionText.value = value;
  void setQuestionType(String value) => _questionType.value = value;
  void setScaleLabelLow(String value) => _scaleLabelLow.value = value;
  void setScaleLabelHigh(String value) => _scaleLabelHigh.value = value;
  void setShowForm(bool value) => _showForm.value = value;
}
