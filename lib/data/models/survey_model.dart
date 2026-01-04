import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyModel {
  final String id;
  final String title;
  final String status; // 'draft', 'active', 'archived'
  final DateTime createdAt;
  final DateTime updatedAt;

  SurveyModel({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String? ?? 'draft',
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final json = {
      'title': title,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
    if (includeId) {
      json['id'] = id;
    }
    return json;
  }

  SurveyModel copyWith({
    String? id,
    String? title,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurveyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

