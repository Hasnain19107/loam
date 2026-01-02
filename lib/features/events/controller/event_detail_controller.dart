import 'package:get/get.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/event_participant_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/mock_events.dart';
// import '../../../data/network/remote/firebase_service.dart';
import '../../auth/controller/auth_controller.dart';

class EventDetailController extends GetxController {
  // final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<EventModel?> _event = Rx<EventModel?>(null);
  final RxList<UserProfileModel> _participants = <UserProfileModel>[].obs;
  final Rx<EventParticipantModel?> _participation = Rx<EventParticipantModel?>(null);
  final RxBool _isLoading = true.obs;
  final RxBool _isSubmitting = false.obs;
  final RxBool _showConfirmation = false.obs;

  // Getters
  EventModel? get event => _event.value;
  List<UserProfileModel> get participants => _participants;
  EventParticipantModel? get participation => _participation.value;
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  bool get showConfirmation => _showConfirmation.value;

  bool get isApproved => _participation.value?.isApproved ?? false;
  bool get isRejected => _participation.value?.isRejected ?? false;
  bool get isSignedUp => _participation.value != null;
  bool get isPast => _event.value?.isPast ?? false;

  String get eventId => Get.parameters['id'] ?? Get.arguments as String? ?? '';

  @override
  void onInit() {
    super.onInit();
    if (eventId.isNotEmpty) {
      loadEventData();
    } else {
      _isLoading.value = false;
    }
  }

  Future<void> loadEventData() async {
    if (eventId.isEmpty) {
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;
      
      // Use mock events data
      final mockEventsList = mockEvents;
      final event = mockEventsList.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );
      
      _event.value = event;

      // For mock data, no participation or participants
      // Uncomment below to use Firebase data instead
      // Load participation status
      // if (_authController.user != null) {
      //   final participation = await _firebaseService.getEventParticipation(
      //     eventId,
      //     _authController.user!.uid,
      //   );
      //   _participation.value = participation;
      // }

      // Load participants if event shows them
      // if (event.showParticipants) {
      //   final participants = await _firebaseService.getEventParticipants(eventId);
      //   _participants.value = participants;
      // }
    } catch (e) {
      print('Error loading event: $e');
      Get.snackbar('Error', 'Failed to load event');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerForEvent() async {
    if (eventId.isEmpty || _authController.user == null) return;

    _isSubmitting.value = true;

    try {
      // For mock data, just show confirmation
      // Uncomment below to use Firebase registration
      // await _firebaseService.registerForEvent(
      //   eventId,
      //   _authController.user!.uid,
      // );
      
      _showConfirmation.value = true;
      
      // For mock data, simulate participation status
      // In real implementation, reload would get updated participation
      // await loadEventData();
    } catch (e) {
      Get.snackbar('Error', 'Could not send request. Please try again.');
    } finally {
      _isSubmitting.value = false;
    }
  }

  bool canRegister() {
    return !isPast && !isSignedUp && !isRejected;
  }

  String getRegisterButtonText() {
    if (isPast) return "This gathering has passed";
    if (isRejected) return 'Not available';
    if (isApproved) return "You're confirmed!";
    if (isSignedUp) return 'Pending approval';
    return 'Register';
  }
}

