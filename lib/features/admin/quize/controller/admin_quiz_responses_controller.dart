import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/survey_model.dart';
import '../../../../data/models/survey_response_model.dart';
import '../../../../data/models/user_profile_model.dart';

class AdminQuizResponsesController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxBool _isLoading = false.obs;
  final RxList<SurveyModel> _surveys = <SurveyModel>[].obs;
  final RxMap<String, int> _responseCounts = <String, int>{}.obs;
  final RxString _downloadingSurveyId = ''.obs;

  bool get isLoading => _isLoading.value;
  List<SurveyModel> get surveys => _surveys;
  Map<String, int> get responseCounts => _responseCounts;
  bool isDownloading(String surveyId) => _downloadingSurveyId.value == surveyId;

  @override
  void onInit() {
    super.onInit();
    loadSurveysWithCounts();
  }

  Future<void> loadSurveysWithCounts() async {
    try {
      _isLoading.value = true;
      final surveysList = await _firebaseService.getAllSurveys();
      _surveys.value = surveysList;

      final counts = await _firebaseService.getSurveyResponseCounts();
      _responseCounts.value = counts;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load quizzes: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> downloadCSV(SurveyModel survey) async {
    if (_downloadingSurveyId.value.isNotEmpty) return;
    _downloadingSurveyId.value = survey.id;

    try {
      final exportData = await _prepareExportData(survey);
      if (exportData == null) return;

      final headers = exportData['headers'] as List<String>;
      final rows = exportData['rows'] as List<List<String>>;

      // Convert to CSV string
      final csvContent = [
        headers.map(_escapeCSV).join(','),
        ...rows.map((row) => row.map(_escapeCSV).join(',')),
      ].join('\n');

      final filename =
          'quiz_responses_${survey.title.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      await _saveAndOpenFile(filename, csvContent);
    } catch (e) {
      _showErrorSnackbar('CSV', e);
    } finally {
      _downloadingSurveyId.value = '';
    }
  }

  Future<void> downloadExcel(SurveyModel survey) async {
    if (_downloadingSurveyId.value.isNotEmpty) return;
    _downloadingSurveyId.value = survey.id;

    try {
      final exportData = await _prepareExportData(survey);
      if (exportData == null) return;

      final headers = exportData['headers'] as List<String>;
      final rows = exportData['rows'] as List<List<String>>;

      // Generate HTML Table for Excel
      final buffer = StringBuffer();
      buffer.writeln('<html><head><meta charset="UTF-8"></head><body>');
      buffer.writeln('<table border="1">');

      // Header
      buffer.writeln('<thead><tr>');
      for (final header in headers) {
        buffer.writeln(
          '<th style="background-color: #f0f0f0;">${_escapeHtml(header)}</th>',
        );
      }
      buffer.writeln('</tr></thead>');

      // Body
      buffer.writeln('<tbody>');
      for (final row in rows) {
        buffer.writeln('<tr>');
        for (final cell in row) {
          buffer.writeln('<td>${_escapeHtml(cell)}</td>');
        }
        buffer.writeln('</tr>');
      }
      buffer.writeln('</tbody></table></body></html>');

      final filename =
          'quiz_responses_${survey.title.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xls';
      await _saveAndOpenFile(filename, buffer.toString());
    } catch (e) {
      _showErrorSnackbar('Excel', e);
    } finally {
      _downloadingSurveyId.value = '';
    }
  }

  Future<void> _saveAndOpenFile(String filename, String content) async {
    try {
      final directory = await getTemporaryDirectory();
      final f = File('${directory.path}/$filename');
      await f.writeAsString(content);

      final result = await OpenFilex.open(f.path);

      if (result.type != ResultType.done) {
        Get.snackbar(
          'Message',
          'File saved at ${f.path}. Could not open automatically: ${result.message}',
          duration: const Duration(seconds: 5),
        );
      } else {
        // Success
      }
    } catch (e) {
      throw Exception('Could not save file: $e');
    }
  }

  Future<Map<String, dynamic>?> _prepareExportData(SurveyModel survey) async {
    try {
      // First, get all questions from the survey to ensure correct order
      final allQuestions = await _firebaseService.getSurveyQuestions(survey.id);
      
      if (allQuestions.isEmpty) {
        Get.snackbar('Error', 'No questions found for this survey');
        return null;
      }

      // Create question order and texts from survey questions (ensures correct order)
      final questionOrder = <String>[];
      final questionTexts = <String, String>{};
      for (final question in allQuestions) {
        if (question.isActive) {
          questionOrder.add(question.id);
          questionTexts[question.id] = question.questionText;
        }
      }

      // Fetch all responses for this survey
      final responses = await _firebaseService.getSurveyResponses(survey.id);
      
      print('Fetched ${responses.length} responses for survey ${survey.id}');

      if (responses.isEmpty) {
        Get.snackbar('Error', 'No responses to export');
        return null;
      }
      
      // Debug: Print response details
      print('Response details:');
      for (var resp in responses.take(3)) {
        print('  User: ${resp.userId}, Question: ${resp.questionId}, Answer: ${resp.answerValue}');
      }

      // Get unique user IDs from responses
      final userIds = responses
          .map((r) => r.userId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      // Get user profiles in parallel
      final profiles = <String, UserProfileModel>{};
      const chunkSize = 10;
      for (var i = 0; i < userIds.length; i += chunkSize) {
        final end = (i + chunkSize < userIds.length)
            ? i + chunkSize
            : userIds.length;
        final batch = userIds.sublist(i, end);
        final batchFutures = batch.map(
          (uid) => _firebaseService.getUserProfile(uid),
        );
        final batchResults = await Future.wait(batchFutures);

        for (var j = 0; j < batch.length; j++) {
          if (batchResults[j] != null) {
            profiles[batch[j]] = batchResults[j]!;
          }
        }
      }

      // Group responses by user
      final userResponses = <String, List<SurveyResponseModel>>{};
      for (final response in responses) {
        if (!userResponses.containsKey(response.userId)) {
          userResponses[response.userId] = [];
        }
        userResponses[response.userId]!.add(response);
      }

      // Build headers using question order from survey
      final headers = [
        'User Email',
        'User Name',
        'Submission Date',
        ...questionOrder.map((qId) => questionTexts[qId] ?? 'Question'),
      ];

      // Build rows - ensure all questions are included
      final rows = <List<String>>[];
      userResponses.forEach((userId, userResps) {
        final profile = profiles[userId];
        final submissionDate = userResps.isNotEmpty
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(userResps.first.createdAt)
            : '';

        // Create answer map from user responses
        final answerMap = <String, String>{};
        for (final resp in userResps) {
          answerMap[resp.questionId] = resp.answerValue;
        }

        // Build row with all questions in order (empty string if not answered)
        final row = [
          profile?.email ?? userId,
          profile?.firstName ?? '',
          submissionDate,
          ...questionOrder.map((qId) => answerMap[qId] ?? ''),
        ];
        rows.add(row);
      });

      print('Export data prepared: ${rows.length} users, ${questionOrder.length} questions');
      
      return {'headers': headers, 'rows': rows};
    } catch (e) {
      print('Error preparing export data: $e');
      Get.snackbar('Error', 'Failed to prepare export data: ${e.toString()}');
      return null;
    }
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  void _showErrorSnackbar(String type, dynamic error) {
    Get.snackbar('Error', 'Failed to generate $type: ${error.toString()}');
    print('$type generation error: $error');
  }

  Future<void> refresh() async {
    await loadSurveysWithCounts();
  }
}
