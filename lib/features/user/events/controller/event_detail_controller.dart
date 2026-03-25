import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final RxBool _hasReportedThisEvent = false.obs;

  // Getters
  EventModel? get event => _event.value;
  bool get hasReportedThisEvent => _hasReportedThisEvent.value;
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
        if (event.showParticipants) {
          await loadParticipants();
        }

        if (_authController.user != null) {
          try {
            final participation = await _firebaseService.getEventParticipation(
              eventId,
              _authController.user!.uid,
            );
            _participation.value = participation;
            final reported = await _firebaseService.hasUserReportedEvent(
              eventId,
              _authController.user!.uid,
            );
            _hasReportedThisEvent.value = reported;
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

  // Report dialog state
  final RxBool _reportDialogOpen = false.obs;
  final RxBool _isReportSubmitting = false.obs;
  bool get reportDialogOpen => _reportDialogOpen.value;
  bool get isReportSubmitting => _isReportSubmitting.value;

  void openReportDialog() {
    _reportDialogOpen.value = true;
  }

  void closeReportDialog() {
    _reportDialogOpen.value = false;
  }

  /// Submit event report with reason to Firebase. Returns true on success (caller can close dialog).
  Future<bool> submitReport(String reason) async {
    if (eventId.isEmpty || eventId == ':id' || _authController.user == null) {
      Get.snackbar('Error', 'You must be logged in to report an event');
      return false;
    }
    if (_hasReportedThisEvent.value) {
      Get.snackbar('Info', 'You have already reported this event.');
      return false;
    }

    _isReportSubmitting.value = true;
    try {
      await _firebaseService.reportEvent(
        eventId,
        _authController.user!.uid,
        reason,
      );
      _hasReportedThisEvent.value = true;
      Get.back(); // Close report dialog immediately after success
      Get.snackbar('Thank you', 'Our team will review this event.');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit report. Please try again.');
      return false;
    } finally {
      _isReportSubmitting.value = false;
    }
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

  Future<void> contactOrganizer() async {
    final raw = event?.contactNumber?.trim();
    debugPrint('[Contact] event.contactNumber: "$raw"');
    if (raw == null || raw.isEmpty) {
      Get.snackbar('Info', 'No contact number set for this event');
      return;
    }
    // Tel URI: strip spaces, dashes, parentheses; keep digits and +
    final number = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (number.isEmpty) {
      Get.snackbar('Info', 'No valid contact number');
      return;
    }
    final telUri = Uri.parse('tel:$number');
    debugPrint('[Contact] launching tel URI: $telUri');
    try {
      bool launched = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('[Contact] launchUrl(externalApplication) = $launched');
      if (!launched) {
        launched = await launchUrl(telUri, mode: LaunchMode.platformDefault);
        debugPrint('[Contact] launchUrl(platformDefault) = $launched');
      }
      if (!launched) {
        Get.snackbar('Error', 'Could not open dial app. Check device settings.');
      }
    } catch (e, st) {
      debugPrint('[Contact] error: $e');
      debugPrint('[Contact] stack: $st');
      Get.snackbar('Error', 'Could not open dial app: $e');
    }
  }

  void openInBrowser() {
    Get.snackbar('Info', 'Opening in browser');
  }

  void openReportEventDialog() {
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
