import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../data/models/event_model.dart';

class AdminExportController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxBool _isExportingUsers = false.obs;
  final RxBool _isExportingEvents = false.obs;

  bool get isExportingUsers => _isExportingUsers.value;
  bool get isExportingEvents => _isExportingEvents.value;

  /// Export all users to CSV
  Future<void> exportUsersToCSV() async {
    try {
      _isExportingUsers.value = true;

      // Fetch all users
      final users = await _firebaseService.getAllUsers();

      // Generate CSV content
      final csvContent = _generateUsersCSV(users);

      // Save and share file
      await _saveAndShareFile(
        csvContent,
        'users_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        'Users Export',
      );

      Get.snackbar('Success', 'Users exported successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to export users: ${e.toString()}');
    } finally {
      _isExportingUsers.value = false;
    }
  }

  /// Export all events to CSV
  Future<void> exportEventsToCSV() async {
    try {
      _isExportingEvents.value = true;

      // Fetch all events
      final events = await _firebaseService.getAllEvents();

      // Generate CSV content
      final csvContent = _generateEventsCSV(events);

      // Save and share file
      await _saveAndShareFile(
        csvContent,
        'events_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        'Events Export',
      );

      Get.snackbar('Success', 'Events exported successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to export events: ${e.toString()}');
    } finally {
      _isExportingEvents.value = false;
    }
  }

  /// Generate CSV content for users
  String _generateUsersCSV(List<UserProfileModel> users) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'ID,First Name,Last Name,Email,Phone,Gender,Date of Birth,City,Language,'
      'Relationship Status,Has Children,Work Industry,Country of Birth,'
      'Notifications Enabled,Is Shadow Blocked,Admin Notes,Created At,Updated At',
    );

    // CSV Rows
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final user in users) {
      buffer.writeln(
        _escapeCSVField(user.id) + ',' +
        _escapeCSVField(user.firstName ?? '') + ',' +
        _escapeCSVField(user.lastName ?? '') + ',' +
        _escapeCSVField(user.email ?? '') + ',' +
        _escapeCSVField(user.phone ?? '') + ',' +
        _escapeCSVField(user.gender ?? '') + ',' +
        _escapeCSVField(user.dateOfBirth ?? '') + ',' +
        _escapeCSVField(user.city ?? '') + ',' +
        _escapeCSVField(user.language ?? '') + ',' +
        _escapeCSVField(user.relationshipStatus ?? '') + ',' +
        _escapeCSVField(user.hasChildren == true ? 'Yes' : 'No') + ',' +
        _escapeCSVField(user.workIndustry ?? '') + ',' +
        _escapeCSVField(user.countryOfBirth ?? '') + ',' +
        _escapeCSVField(user.notificationsEnabled == true ? 'Yes' : 'No') + ',' +
        _escapeCSVField(user.isShadowBlocked ? 'Yes' : 'No') + ',' +
        _escapeCSVField(user.adminNotes ?? '') + ',' +
        _escapeCSVField(dateFormat.format(user.createdAt)) + ',' +
        _escapeCSVField(dateFormat.format(user.updatedAt)),
      );
    }

    return buffer.toString();
  }

  /// Generate CSV content for events
  String _generateEventsCSV(List<EventModel> events) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'ID,Name,Description,Location,Start Date,End Date,Capacity,Is Unlimited Capacity,'
      'Requires Approval,Show Participants,Hide Location Until Approved,'
      'Visibility,Status,Host ID,Cover Image URL,Created At,Updated At',
    );

    // CSV Rows
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final event in events) {
      buffer.writeln(
        _escapeCSVField(event.id) + ',' +
        _escapeCSVField(event.name) + ',' +
        _escapeCSVField(event.description ?? '') + ',' +
        _escapeCSVField(event.location ?? '') + ',' +
        _escapeCSVField(dateFormat.format(event.startDate)) + ',' +
        _escapeCSVField(event.endDate != null ? dateFormat.format(event.endDate!) : '') + ',' +
        _escapeCSVField(event.capacity?.toString() ?? '') + ',' +
        _escapeCSVField(event.isUnlimitedCapacity ? 'Yes' : 'No') + ',' +
        _escapeCSVField(event.requiresApproval ? 'Yes' : 'No') + ',' +
        _escapeCSVField(event.showParticipants ? 'Yes' : 'No') + ',' +
        _escapeCSVField(event.hideLocationUntilApproved ? 'Yes' : 'No') + ',' +
        _escapeCSVField(event.visibility) + ',' +
        _escapeCSVField(event.status) + ',' +
        _escapeCSVField(event.hostId ?? '') + ',' +
        _escapeCSVField(event.coverImageUrl ?? '') + ',' +
        _escapeCSVField(dateFormat.format(event.createdAt)) + ',' +
        _escapeCSVField(dateFormat.format(event.updatedAt)),
      );
    }

    return buffer.toString();
  }

  /// Escape CSV field (handle commas, quotes, newlines)
  String _escapeCSVField(String field) {
    if (field.isEmpty) return '';

    // If field contains comma, quote, or newline, wrap in quotes and escape quotes
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }

    return field;
  }

  /// Save file and open it with relevant app
  Future<void> _saveAndShareFile(
    String content,
    String fileName,
    String subject,
  ) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');

      // Write content to file
      await file.writeAsString(content);

      // Open file directly with relevant app (Excel, Google Sheets, etc.)
      final result = await OpenFilex.open(file.path);
      
      if (result.type != ResultType.done) {
        // If opening fails, fall back to share dialog
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: subject,
          text: 'Exported data from Loam Admin',
        );
      }
    } catch (e) {
      // If both fail, try share as last resort
      try {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: subject,
          text: 'Exported data from Loam Admin',
        );
      } catch (shareError) {
        throw Exception('Failed to save or open file: $e');
      }
    }
  }
}

