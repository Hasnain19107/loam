import 'package:get/get.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/network/remote/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/controller/auth_controller.dart';

class MyEventItem {
  final EventModel event;
  final String status; // 'pending', 'approved', 'rejected'

  MyEventItem({required this.event, required this.status});
}

class MyEventsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<MyEventItem> _allMyEvents = <MyEventItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<MyEventItem> get allEvents => _allMyEvents;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;

  @override
  void onInit() {
    super.onInit();
    loadMyEvents();
  }

  Future<void> loadMyEvents() async {
    // Use FirebaseAuth directly to ensure we have the user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error.value = 'User not logged in';
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      // 1. Get all participations for the user
      final participations = await _firebaseService.getUserParticipations(user.uid);
      print('DEBUG: Fetched ${participations.length} participations for user ${user.uid}');
      for (var p in participations) {
        print('DEBUG: Participation: eventId=${p.eventId}, status=${p.status}');
      }

      if (participations.isEmpty) {
        _allMyEvents.clear();
        _isLoading.value = false;
        return;
      }

      // 2. Extract unique event IDs
      final eventIds = participations.map((p) => p.eventId).toSet().toList();
      print('DEBUG: Event IDs to fetch: $eventIds');

      // 3. Fetch event details
      final List<EventModel> events = [];
      
      // Chunking for whereIn limit of 10
      for (var i = 0; i < eventIds.length; i += 10) {
        final end = (i + 10 < eventIds.length) ? i + 10 : eventIds.length;
        final chunk = eventIds.sublist(i, end);
        
        final snapshot = await _firebaseService.getEventsByIds(chunk);
        events.addAll(snapshot);
      }
      print('DEBUG: Fetched ${events.length} event details');

      // 4. Map events to status
      final List<MyEventItem> items = [];
      for (final participation in participations) {
        final event = events.firstWhereOrNull((e) => e.id == participation.eventId);
        if (event != null) {
          items.add(MyEventItem(event: event, status: participation.status));
          print('DEBUG: Added item: ${event.name} (Status: ${participation.status})');
        } else {
          print('DEBUG: Event not found for participation: ${participation.eventId}');
        }
      }

      _allMyEvents.value = items;
      _isLoading.value = false;
    } catch (e) {
      print('DEBUG: Error loading my events: $e');
      _error.value = e.toString();
      _isLoading.value = false;
    }
  }

  // Helper getters for UI
  List<MyEventItem> get upcomingEvents {
    final now = DateTime.now();
    return _allMyEvents.where((item) {
      final eventEnd = item.event.endDate ?? item.event.startDate;
      return !eventEnd.isBefore(now);
    }).toList();
  }

  List<MyEventItem> get pastEvents {
    final now = DateTime.now();
    return _allMyEvents.where((item) {
      final eventEnd = item.event.endDate ?? item.event.startDate;
      return eventEnd.isBefore(now);
    }).toList();
  }
}
