import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyResponseModel {
  final String id;
  final String userId;
  final String surveyId;
  final String questionId;
  final String questionTextSnapshot;
  final String questionTypeSnapshot;
  final String answerValue;
  final DateTime createdAt;

  SurveyResponseModel({
    required this.id,
    required this.userId,
    required this.surveyId,
    required this.questionId,
    required this.questionTextSnapshot,
    required this.questionTypeSnapshot,
    required this.answerValue,
    required this.createdAt,
  });

  factory SurveyResponseModel.fromJson(Map<String, dynamic> json) {
    return SurveyResponseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      surveyId: json['survey_id'] as String? ?? '',
      questionId: json['question_id'] as String,
      questionTextSnapshot: json['question_text_snapshot'] as String,
      questionTypeSnapshot: json['question_type_snapshot'] as String,
      answerValue: json['answer_value'] as String,
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'survey_id': surveyId,
      'question_id': questionId,
      'question_text_snapshot': questionTextSnapshot,
      'question_type_snapshot': questionTypeSnapshot,
      'answer_value': answerValue,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

