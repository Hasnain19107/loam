import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/survey_model.dart';
import '../../../../data/models/survey_question_model.dart';

class AdminQuizBuilderController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxBool _isLoading = false.obs;
  final RxList<SurveyModel> _surveys = <SurveyModel>[].obs;
  final RxBool _showForm = false.obs;
  final Rx<SurveyModel?> _editingSurvey = Rx<SurveyModel?>(null);

  // Form state
  final RxString _title = ''.obs;
  final RxString _status = 'draft'.obs;

  bool get isLoading => _isLoading.value;
  List<SurveyModel> get surveys => _surveys;
  bool get showForm => _showForm.value;
  SurveyModel? get editingSurvey => _editingSurvey.value;
  String get title => _title.value;
  String get status => _status.value;

  @override
  void onInit() {
    super.onInit();
    loadSurveys();
  }

  Future<void> loadSurveys() async {
    try {
      _isLoading.value = true;
      final surveysList = await _firebaseService.getAllSurveys();
      _surveys.value = surveysList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load quizzes: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  String getDefaultTitle() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  void resetForm() {
    _title.value = '';
    _status.value = 'draft';
    _editingSurvey.value = null;
    _showForm.value = false;
  }

  void handleCreate() {
    _title.value = getDefaultTitle();
    _status.value = 'draft';
    _editingSurvey.value = null;
    _showForm.value = true;
  }

  void handleEdit(SurveyModel survey) {
    _editingSurvey.value = survey;
    _title.value = survey.title;
    _status.value = survey.status;
    _showForm.value = true;
  }

  Future<void> handleSave() async {
    if (_title.value.trim().isEmpty) {
      Get.snackbar('Error', 'Quiz title is required');
      return;
    }

    try {
      // If setting to active, archive ALL other surveys first
      if (_status.value == 'active') {
        await _firebaseService.archiveAllActiveSurveysExcept(
          _editingSurvey.value?.id ?? '',
        );
      }

      if (_editingSurvey.value != null) {
        await _firebaseService.updateSurvey(_editingSurvey.value!.id, {
          'title': _title.value.trim(),
          'status': _status.value,
        });
        Get.snackbar('Success', 'Quiz updated');
      } else {
        // Generate UUID for the new survey
        const uuid = Uuid();
        final surveyId = uuid.v4();

        final newSurvey = SurveyModel(
          id: surveyId,
          title: _title.value.trim(),
          status: _status.value,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firebaseService.createSurvey(newSurvey);
        Get.snackbar('Success', 'Quiz created');
      }

      resetForm();
      await loadSurveys();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save quiz: ${e.toString()}');
    }
  }

  Future<void> handleDuplicate(SurveyModel survey) async {
    try {
      // Create new survey
      final newSurvey = SurveyModel(
        id: '',
        title: '${survey.title} (Copy)',
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final newSurveyId = await _firebaseService.createSurvey(newSurvey);

      // Copy questions
      const uuid = Uuid();
      final questions = await _firebaseService.getSurveyQuestions(survey.id);
      for (final question in questions) {
        final questionId = uuid.v4();
        final newQuestion = SurveyQuestionModel(
          id: questionId,
          surveyId: newSurveyId,
          questionText: question.questionText,
          questionType: question.questionType,
          options: question.options,
          scaleLabelLow: question.scaleLabelLow,
          scaleLabelHigh: question.scaleLabelHigh,
          displayOrder: question.displayOrder,
          isActive: question.isActive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firebaseService.createSurveyQuestion(newQuestion);
      }

      Get.snackbar('Success', 'Quiz duplicated');
      await loadSurveys();
    } catch (e) {
      Get.snackbar('Error', 'Failed to duplicate quiz: ${e.toString()}');
    }
  }

  Future<void> handleArchive(SurveyModel survey) async {
    try {
      await _firebaseService.updateSurvey(survey.id, {'status': 'archived'});
      Get.snackbar('Success', 'Quiz archived');
      await loadSurveys();
    } catch (e) {
      Get.snackbar('Error', 'Failed to archive quiz: ${e.toString()}');
    }
  }

  Future<void> handleDelete(String surveyId) async {
    try {
      await _firebaseService.deleteSurvey(surveyId);
      Get.snackbar('Success', 'Quiz deleted');
      await loadSurveys();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete quiz: ${e.toString()}');
    }
  }

  void setTitle(String value) => _title.value = value;
  void setStatus(String value) => _status.value = value;
  void setShowForm(bool value) => _showForm.value = value;
}
