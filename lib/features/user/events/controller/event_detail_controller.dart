import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/models/event_participant_model.dart';
import '../../../../data/models/user_profile_model.dart';

import '../../../../data/network/remote/firebase_service.dart';
import '../../../auth/controller/auth_controller.dart';

class EventDetailController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<EventModel?> _event = Rx<EventModel?>(null);
  final RxList<UserProfileModel> _participants = <UserProfileModel>[].obs;
  final Rx<EventParticipantModel?> _participation = Rx<EventParticipantModel?>(
    null,
  );
  final RxBool _isLoading = true.obs;
  final RxBool _isSubmitting = false.obs;
  final RxBool _showConfirmation = false.obs;
  final RxInt _approvedCount = 0.obs; // Track actual approved participant count

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

  String eventId = '';

  @override
  void onInit() {
    super.onInit();

    // Extract event ID from route parameters or path
    eventId = Get.parameters['id'] ?? Get.arguments as String? ?? '';

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
      final match = RegExp(r'/event/([^/?]+)').firstMatch(currentRoute);
      if (match != null) {
        final captured = match.group(1);
        if (captured != null && captured != ':id') {
          eventId = captured;
        }
      }
    }

    if (eventId.isNotEmpty && eventId != ':id') {
      loadEventData();
    } else {
      _isLoading.value = false;
      print("Event ID extraction failed: $eventId. Route: ${Get.currentRoute}");
    }
  }

  Future<void> loadEventData() async {
    if (eventId.isEmpty || eventId == ':id') {
      _isLoading.value = false;
      return;
    }

    try {
      _isLoading.value = true;

      final event = await _firebaseService.getEvent(eventId);
      if (event != null) {
        _event.value = event;

        // Load approved count for capacity calculation
        try {
          final approvedCount = await _firebaseService.getEventApprovedCount(
            eventId,
          );
          _approvedCount.value = approvedCount;
        } catch (e) {
          print('Error loading approved count: $e');
        }

        // Only load participants if permitted
        if (event.showParticipants ||
            await _firebaseService.isAdmin(_authController.user?.uid ?? '')) {
          await loadParticipants();
        }

        if (_authController.user != null) {
          try {
            final participation = await _firebaseService.getEventParticipation(
              eventId,
              _authController.user!.uid,
            );
            _participation.value = participation;
          } catch (_) {}
        }
      } else {
        Get.snackbar('Error', 'Event not found');
      }
    } catch (e) {
      print('Error loading event: $e');
      Get.snackbar('Error', 'Failed to load event');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadParticipants() async {
    try {
      final participants = await _firebaseService.getEventParticipants(eventId);
      _participants.assignAll(participants);
    } catch (e) {
      print('Error loading participants: $e');
    }
  }

  Future<void> registerForEvent() async {
    if (eventId.isEmpty || _authController.user == null) {
      Get.snackbar('Error', 'You must be logged in to register');
      return;
    }

    // Check capacity before registration
    if (event != null &&
        !event!.isUnlimitedCapacity &&
        event!.capacity != null) {
      if (_approvedCount.value >= event!.capacity!) {
        Get.snackbar(
          'Event Full',
          'Sorry, this event has reached its maximum capacity.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    _isSubmitting.value = true;

    try {
      await _firebaseService.registerForEvent(
        eventId,
        _authController.user!.uid,
      );

      await loadEventData();
      _showConfirmation.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to register: ${e.toString()}');
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

  // Dialog state
  final RxBool _reportDialogOpen = false.obs;
  bool get reportDialogOpen => _reportDialogOpen.value;

  void openReportDialog() {
    _reportDialogOpen.value = true;
  }

  void closeReportDialog() {
    _reportDialogOpen.value = false;
  }

  // Action methods
  Future<void> shareEvent() async {
    if (event == null) return;
    final shareText = '$eventName - $formattedDate at $formattedTime';
    try {
      await Share.share(shareText);
    } catch (e) {
      Get.snackbar('Error', 'Failed to share');
    }
  }

  void contactOrganizer() {
    Get.snackbar('Info', 'Chat with organiser coming soon');
  }

  void openInBrowser() {
    Get.snackbar('Info', 'Opening in browser');
  }

  void reportEvent() {
    openReportDialog();
  }

  // Formatting getters
  String get eventName => event?.name ?? '';

  String get formattedDate {
    if (event == null) return '';
    return DateFormat('EEE, MMM d').format(event!.startDate);
  }

  String get formattedTime {
    if (event == null) return '';
    return DateFormat('h:mm a').format(event!.startDate);
  }

  int? get spotsLeft {
    if (event == null || event!.isUnlimitedCapacity) return null;
    if (event!.capacity == null) return null;
    // Use actual approved count, not just visible participants
    final count = _approvedCount.value;
    final spots = (event!.capacity! - count);
    return spots > 0 ? spots : 0;
  }

  // Navigation
  void navigateToHome() {
    Get.offAllNamed(AppRoutes.main);
  }
}
