import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final int? capacity;
  final bool isUnlimitedCapacity;
  final bool requiresApproval;
  final bool showParticipants;
  final bool hideLocationUntilApproved;
  final String visibility; // 'public' or 'hidden'
  final String status; // 'draft', 'published', 'past'
  final String? hostId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.location,
    required this.startDate,
    this.endDate,
    this.capacity,
    this.isUnlimitedCapacity = true,
    this.requiresApproval = false,
    this.showParticipants = false,
    this.hideLocationUntilApproved = false,
    this.visibility = 'public',
    this.status = 'draft',
    this.hostId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      location: json['location'] as String?,
      startDate: (json['start_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['end_date'] as Timestamp?)?.toDate(),
      capacity: json['capacity'] as int?,
      isUnlimitedCapacity: json['is_unlimited_capacity'] as bool? ?? true,
      requiresApproval: json['requires_approval'] as bool? ?? false,
      showParticipants: json['show_participants'] as bool? ?? false,
      hideLocationUntilApproved: json['hide_location_until_approved'] as bool? ?? false,
      visibility: json['visibility'] as String? ?? 'public',
      status: json['status'] as String? ?? 'draft',
      hostId: json['host_id'] as String?,
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image_url': coverImageUrl,
      'location': location,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'capacity': capacity,
      'is_unlimited_capacity': isUnlimitedCapacity,
      'requires_approval': requiresApproval,
      'show_participants': showParticipants,
      'hide_location_until_approved': hideLocationUntilApproved,
      'visibility': visibility,
      'status': status,
      'host_id': hostId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isPast {
    final eventEnd = endDate ?? startDate;
    return eventEnd.isBefore(DateTime.now());
  }

  int? get spotsLeft {
    if (isUnlimitedCapacity) return null;
    if (capacity == null) return null;
    // This would need to be calculated with actual participant count
    return capacity;
  }

  EventModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? capacity,
    bool? isUnlimitedCapacity,
    bool? requiresApproval,
    bool? showParticipants,
    bool? hideLocationUntilApproved,
    String? visibility,
    String? status,
    String? hostId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      capacity: capacity ?? this.capacity,
      isUnlimitedCapacity: isUnlimitedCapacity ?? this.isUnlimitedCapacity,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      showParticipants: showParticipants ?? this.showParticipants,
      hideLocationUntilApproved: hideLocationUntilApproved ?? this.hideLocationUntilApproved,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      hostId: hostId ?? this.hostId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

