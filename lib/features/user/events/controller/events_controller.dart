import 'package:get/get.dart';
import '../../../../data/models/event_model.dart';

import '../../../../data/network/remote/firebase_service.dart';

class EventsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxList<EventModel> _events = <EventModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxMap<String, int> _eventApprovedCounts =
      <String, int>{}.obs; // Track approved counts

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;

  // Get approved count for a specific event
  int getApprovedCount(String eventId) => _eventApprovedCounts[eventId] ?? 0;

  // Calculate spots left for an event
  int? getSpotsLeft(EventModel event) {
    if (event.isUnlimitedCapacity) return null;
    if (event.capacity == null) return null;
    final approvedCount = getApprovedCount(event.id);
    final spots = event.capacity! - approvedCount;
    return spots > 0 ? spots : 0;
  }

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      _firebaseService.getAllEventsStream().listen(
        (events) async {
          _events.value = events;

          // Load approved counts for each event
          for (final event in events) {
            try {
              final approvedCount = await _firebaseService
                  .getEventApprovedCount(event.id);
              _eventApprovedCounts[event.id] = approvedCount;
            } catch (e) {
              print('Error loading approved count for event ${event.id}: $e');
              _eventApprovedCounts[event.id] = 0;
            }
          }

          _isLoading.value = false;
        },
        onError: (e) {
          _error.value = e.toString();
          _isLoading.value = false;
        },
      );
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
    }
  }

  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) {
      final eventEnd = event.endDate ?? event.startDate;
      return eventEnd.isAfter(now);
    }).toList();
  }

  List<EventModel> get pastEvents {
    final now = DateTime.now();
    return _events.where((event) {
      final eventEnd = event.endDate ?? event.startDate;
      return eventEnd.isBefore(now);
    }).toList();
  }
}
