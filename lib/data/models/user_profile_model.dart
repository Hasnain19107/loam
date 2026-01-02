import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? photo;
  final String? gender;
  final String? relationshipStatus;
  final bool? hasChildren;
  final String? workIndustry;
  final String? countryOfBirth;
  final String? dateOfBirth;
  final int? defaultAvatarIndex;
  final bool? notificationsEnabled;
  final String? language;
  final String? city;
  final bool isShadowBlocked;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.photo,
    this.gender,
    this.relationshipStatus,
    this.hasChildren,
    this.workIndustry,
    this.countryOfBirth,
    this.dateOfBirth,
    this.defaultAvatarIndex,
    this.notificationsEnabled,
    this.language,
    this.city,
    this.isShadowBlocked = false,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone_number'] as String?,
      email: json['email'] as String?,
      photo: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      relationshipStatus: json['relationship_status'] as String?,
      hasChildren: json['children'] == 'yes' || json['has_children'] == true,
      workIndustry: json['work_industry'] as String?,
      countryOfBirth: json['country_of_birth'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      defaultAvatarIndex: json['default_avatar_index'] as int?,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      language: json['language'] as String?,
      city: json['city'] as String?,
      isShadowBlocked: json['is_shadow_blocked'] as bool? ?? false,
      adminNotes: json['admin_notes'] as String?,
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phone,
      'email': email,
      'avatar_url': photo,
      'gender': gender,
      'relationship_status': relationshipStatus,
      'children': hasChildren == true ? 'yes' : 'no',
      'work_industry': workIndustry,
      'country_of_birth': countryOfBirth,
      'date_of_birth': dateOfBirth,
      'default_avatar_index': defaultAvatarIndex,
      'notifications_enabled': notificationsEnabled,
      'language': language,
      'city': city,
      'is_shadow_blocked': isShadowBlocked,
      'admin_notes': adminNotes,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? photo,
    String? gender,
    String? relationshipStatus,
    bool? hasChildren,
    String? workIndustry,
    String? countryOfBirth,
    String? dateOfBirth,
    int? defaultAvatarIndex,
    bool? notificationsEnabled,
    String? language,
    String? city,
    bool? isShadowBlocked,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      gender: gender ?? this.gender,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      hasChildren: hasChildren ?? this.hasChildren,
      workIndustry: workIndustry ?? this.workIndustry,
      countryOfBirth: countryOfBirth ?? this.countryOfBirth,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      defaultAvatarIndex: defaultAvatarIndex ?? this.defaultAvatarIndex,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      city: city ?? this.city,
      isShadowBlocked: isShadowBlocked ?? this.isShadowBlocked,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

