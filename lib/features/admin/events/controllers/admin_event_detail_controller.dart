import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/models/event_participant_model.dart';
import '../../../../data/models/user_profile_model.dart';

class AdminEventDetailController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxBool _isLoading = false.obs;
  final Rx<EventModel?> _event = Rx<EventModel?>(null);
  final RxList<EventParticipantModel> _participants =
      <EventParticipantModel>[].obs;
  final RxMap<String, UserProfileModel> _userProfiles =
      <String, UserProfileModel>{}.obs;

  bool get isLoading => _isLoading.value;
  EventModel? get event => _event.value;
  List<EventParticipantModel> get participants => _participants;

  List<EventParticipantModel> get pendingParticipants =>
      _participants.where((p) => p.status == 'pending').toList();
  List<EventParticipantModel> get approvedParticipants =>
      _participants.where((p) => p.status == 'approved').toList();
  List<EventParticipantModel> get rejectedParticipants =>
      _participants.where((p) => p.status == 'rejected').toList();

  UserProfileModel? getUserProfile(String userId) => _userProfiles[userId];

  @override
  void onInit() {
    super.onInit();
    // Extract event ID from route parameters or from the current route path
    String eventId = Get.parameters['id'] ?? '';

    // If param is empty or just the placeholder ':id', try to get from query params
    if (eventId.isEmpty || eventId == ':id') {
      final uri = Uri.parse(Get.currentRoute);
      if (uri.queryParameters.containsKey('id')) {
        eventId = uri.queryParameters['id']!;
      }
    }

    // Fallback to regex from path if still empty or placeholder
    if (eventId.isEmpty || eventId == ':id') {
      final currentRoute = Get.currentRoute;
      final match = RegExp(r'/admin/events/([^/?]+)').firstMatch(currentRoute);
      if (match != null) {
        final captured = match.group(1);
        if (captured != null && captured != ':id') {
          eventId = captured;
        }
      }
    }

    if (eventId.isNotEmpty && eventId != ':id') {
      loadEvent(eventId);
    } else {
      // Defer snackbar to avoid calling setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Event ID not found in route');
      });
    }
  }

  Future<void> loadEvent(String eventId) async {
    try {
      _isLoading.value = true;
      _event.value = null; // Clear previous event
      _participants.clear();
      _userProfiles.clear();

      final event = await _firebaseService.getEvent(eventId);
      _event.value = event;

      if (event != null) {
        await loadParticipants(eventId);
      } else {
        Get.snackbar('Error', 'Event not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load event: ${e.toString()}');
      _event.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadParticipants(String eventId) async {
    try {
      final participants = await _firebaseService.getEventParticipantsForAdmin(
        eventId,
      );
      _participants.value = participants;

      // Load user profiles
      final userIds = participants.map((p) => p.userId).toSet();
      for (final userId in userIds) {
        try {
          final profile = await _firebaseService.getUserProfile(userId);
          if (profile != null) {
            _userProfiles[userId] = profile;
          }
        } catch (e) {
          // Skip if profile not found
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load participants: ${e.toString()}');
    }
  }

  Future<void> updateParticipantStatus(
    String participantId,
    String status,
  ) async {
    try {
      await _firebaseService.updateParticipantStatus(participantId, status);

      final index = _participants.indexWhere((p) => p.id == participantId);
      if (index != -1) {
        _participants[index] = _participants[index].copyWith(status: status);
      }

      Get.snackbar('Success', 'Participant $status');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update participant: ${e.toString()}');
    }
  }

  void loadEventData() {
    if (_event.value != null) {
      loadEvent(_event.value!.id);
    }
  }
}
