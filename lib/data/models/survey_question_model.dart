import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyQuestionModel {
  final String id;
  final String surveyId;
  final String questionText;
  final String questionType; // 'multiple_choice' or 'scale_1_10'
  final List<String>? options; // For multiple_choice
  final String? scaleLabelLow; // For scale_1_10
  final String? scaleLabelHigh; // For scale_1_10
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SurveyQuestionModel({
    required this.id,
    required this.surveyId,
    required this.questionText,
    required this.questionType,
    this.options,
    this.scaleLabelLow,
    this.scaleLabelHigh,
    required this.displayOrder,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionModel(
      id: json['id'] as String,
      surveyId: json['survey_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      scaleLabelLow: json['scale_label_low'] as String?,
      scaleLabelHigh: json['scale_label_high'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final json = {
      'survey_id': surveyId,
      'question_text': questionText,
      'question_type': questionType,
      'options': options,
      'scale_label_low': scaleLabelLow,
      'scale_label_high': scaleLabelHigh,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
    if (includeId) {
      json['id'] = id;
    }
    return json;
  }

  SurveyQuestionModel copyWith({
    String? id,
    String? surveyId,
    String? questionText,
    String? questionType,
    List<String>? options,
    String? scaleLabelLow,
    String? scaleLabelHigh,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurveyQuestionModel(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      scaleLabelLow: scaleLabelLow ?? this.scaleLabelLow,
      scaleLabelHigh: scaleLabelHigh ?? this.scaleLabelHigh,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

