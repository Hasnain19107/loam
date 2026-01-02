import 'package:get/get.dart';
import '../../../data/models/event_model.dart';
import '../../../data/mock_events.dart';
// import '../../../data/network/remote/firebase_service.dart';

class EventsController extends GetxController {
  // final FirebaseService _firebaseService = FirebaseService();

  final RxList<EventModel> _events = <EventModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // Use mock events for now
      _events.value = mockEvents;
      _isLoading.value = false;

      // Uncomment below to use Firebase events instead
      // _firebaseService.getPublishedEvents().listen((events) {
      //   _events.value = events;
      //   _isLoading.value = false;
      // });
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

