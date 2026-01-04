import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/event_model.dart';
import '../../../../core/routes/app_routes.dart';

class AdminEventCreateController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final _picker = ImagePicker();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Form fields
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final coverImageUrlController = TextEditingController();
  final locationController = TextEditingController();
  final startDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endDateController = TextEditingController();
  final endTimeController = TextEditingController();
  final capacityController = TextEditingController();

  final RxString coverImageUrl = ''.obs;
  final RxString _localImagePath = ''.obs;
  final RxBool _isUploadingImage = false.obs;
  bool get isUploadingImage => _isUploadingImage.value;
  String? get localImagePath => _localImagePath.value.isNotEmpty ? _localImagePath.value : null;
  
  final RxBool requiresApproval = true.obs;
  final RxBool isUnlimitedCapacity = true.obs;
  final RxBool hideLocationUntilApproved = true.obs;
  final RxBool showParticipants = false.obs;
  final RxString visibility = 'public'.obs;
  final RxString status = 'published'.obs;

  // Edit mode
  final Rx<EventModel?> _editingEvent = Rx<EventModel?>(null);
  bool get isEditing => _editingEvent.value != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to cover image URL changes
    coverImageUrlController.addListener(() {
      coverImageUrl.value = coverImageUrlController.text;
    });

    // Check if we have an event to edit passed via arguments
    if (Get.arguments != null && Get.arguments is EventModel) {
      loadEventForEditing(Get.arguments as EventModel);
    }
  }

  void loadEventForEditing(EventModel event) {
    _editingEvent.value = event;

    nameController.text = event.name;
    if (event.description != null)
      descriptionController.text = event.description!;
    if (event.coverImageUrl != null)
      coverImageUrlController.text = event.coverImageUrl!;
    if (event.location != null) locationController.text = event.location!;

    startDateController.text = _formatDate(event.startDate);
    startTimeController.text = _formatTime(event.startDate);

    if (event.endDate != null) {
      endDateController.text = _formatDate(event.endDate!);
      endTimeController.text = _formatTime(event.endDate!);
    }

    if (event.capacity != null)
      capacityController.text = event.capacity.toString();

    coverImageUrl.value = event.coverImageUrl ?? '';
    requiresApproval.value = event.requiresApproval;
    isUnlimitedCapacity.value = event.isUnlimitedCapacity;
    hideLocationUntilApproved.value = event.hideLocationUntilApproved;
    showParticipants.value = event.showParticipants;
    visibility.value = event.visibility;
    status.value = event.status;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    coverImageUrlController.dispose();
    locationController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    capacityController.dispose();
    super.onClose();
  }

  Future<void> pickImageFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _localImagePath.value = image.path;
        // Clear URL if local image is selected
        coverImageUrlController.clear();
        coverImageUrl.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _localImagePath.value = image.path;
        // Clear URL if local image is selected
        coverImageUrlController.clear();
        coverImageUrl.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: ${e.toString()}');
    }
  }

  void removeLocalImage() {
    _localImagePath.value = '';
  }

  Future<void> saveEvent() async {
    if (nameController.text.trim().isEmpty ||
        startDateController.text.isEmpty ||
        startTimeController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in required fields');
      return;
    }

    try {
      _isLoading.value = true;

      // Upload image if local image is selected
      String? finalImageUrl = coverImageUrl.value.trim().isNotEmpty
          ? coverImageUrl.value.trim()
          : null;

      // For editing, upload image before creating event data
      if (_localImagePath.value.isNotEmpty && isEditing && _editingEvent.value != null) {
        _isUploadingImage.value = true;
        try {
          finalImageUrl = await _firebaseService.uploadEventImage(
            _editingEvent.value!.id,
            _localImagePath.value,
          );
          coverImageUrl.value = finalImageUrl;
        } catch (e) {
          Get.snackbar('Error', 'Failed to upload image: ${e.toString()}');
          _isUploadingImage.value = false;
          _isLoading.value = false;
          return;
        } finally {
          _isUploadingImage.value = false;
        }
      }

      // Parse dates
      final startDate = DateTime.parse(
        '${startDateController.text} ${startTimeController.text}',
      );
      DateTime? endDate;
      if (endDateController.text.isNotEmpty &&
          endTimeController.text.isNotEmpty) {
        endDate = DateTime.parse(
          '${endDateController.text} ${endTimeController.text}',
        );
      }

      // Get current user
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create event model
      final eventData = EventModel(
        id: isEditing
            ? _editingEvent.value!.id
            : '', // Will be generated by Firestore if new
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        coverImageUrl: finalImageUrl,
        location: locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        startDate: startDate,
        endDate: endDate,
        capacity: isUnlimitedCapacity.value
            ? null
            : (int.tryParse(capacityController.text) ?? null),
        isUnlimitedCapacity: isUnlimitedCapacity.value,
        requiresApproval: requiresApproval.value,
        showParticipants: showParticipants.value,
        hideLocationUntilApproved: hideLocationUntilApproved.value,
        visibility: visibility.value,
        status: status.value,
        hostId: isEditing ? _editingEvent.value!.hostId : user.uid,
        createdAt: isEditing ? _editingEvent.value!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String? eventId;
      if (isEditing) {
        await _firebaseService.updateEvent(eventData.id, eventData.toJson());
        eventId = eventData.id;
        Get.snackbar('Success', 'Event updated successfully');
      } else {
        eventId = await _firebaseService.createEvent(eventData);
        Get.snackbar('Success', 'Event created successfully');
      }

      // For new events, upload image after event creation (so we have the event ID)
      if (_localImagePath.value.isNotEmpty && !isEditing && eventId.isNotEmpty) {
        _isUploadingImage.value = true;
        try {
          finalImageUrl = await _firebaseService.uploadEventImage(
            eventId,
            _localImagePath.value,
          );
          // Update event with the uploaded image URL
          await _firebaseService.updateEvent(eventId, {
            'cover_image_url': finalImageUrl,
          });
        } catch (e) {
          print('Warning: Failed to upload image after event creation: $e');
          // Don't fail the whole operation if image upload fails
        } finally {
          _isUploadingImage.value = false;
        }
      }

      // Clear local image path after successful save
      _localImagePath.value = '';

      // Explicitly navigate to the events list page to ensure we are on the correct page
      // and trigger a fresh load of the events list.
      Get.offAllNamed(AppRoutes.adminEvents);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save event: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
}
