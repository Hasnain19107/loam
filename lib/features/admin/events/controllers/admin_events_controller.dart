import 'package:get/get.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/event_model.dart';

class AdminEventsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxBool _isLoading = false.obs;
  final RxList<EventModel> _events = <EventModel>[].obs;
  final RxMap<String, int> _eventSignupCounts =
      <String, int>{}.obs; // Track signup counts per event

  bool get isLoading => _isLoading.value;
  List<EventModel> get events => _events;

  // Get signup count for a specific event
  int getSignupCount(String eventId) => _eventSignupCounts[eventId] ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      _isLoading.value = true;
      final eventsList = await _firebaseService.getAllEvents();

      // Load signup counts for each event
      for (final event in eventsList) {
        try {
          final approvedCount = await _firebaseService.getEventApprovedCount(
            event.id,
          );
          _eventSignupCounts[event.id] = approvedCount;
        } catch (e) {
          print('Error loading signup count for event ${event.id}: $e');
          _eventSignupCounts[event.id] = 0;
        }
      }

      _events.value = eventsList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firebaseService.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      _eventSignupCounts.remove(eventId);
      Get.snackbar('Success', 'Event deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    await loadEvents();
  }
}
