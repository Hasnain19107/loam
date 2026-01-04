import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../data/models/event_model.dart';
import '../controllers/admin_event_detail_controller.dart';
import '../../widgets/admin_layout.dart';

class AdminEventDetailPage extends StatelessWidget {
  const AdminEventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract event ID from route parameters or path
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

    // Use a tag based on eventId to ensure a fresh controller for each event
    final controller = Get.put(
      AdminEventDetailController(),
      tag: eventId.isNotEmpty && eventId != ':id' ? eventId : null,
    );

    return AdminLayout(
      title: 'Event Details',
      child: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = controller.event;
          if (event == null) {
            return const Center(child: Text('Event not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Edit button
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: event.status == 'published'
                                  ? Colors.green.withOpacity(0.1)
                                  : AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: event.status == 'published'
                                    ? Colors.green.shade800
                                    : AppColors.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Get.toNamed(
                          AppRoutes.adminEventCreate,
                          arguments: event,
                        );
                        if (result == true) {
                          controller.loadEventData();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Event cover image
                if (event.coverImageUrl != null) ...[
                  CachedImage(
                    imageUrl: event.coverImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 24),
                ],

                // Event Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date & Time
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Start Date',
                        text: DateFormat(
                          'EEEE, MMMM d, yyyy • h:mm a',
                        ).format(event.startDate),
                      ),
                      if (event.endDate != null) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.event_available,
                          label: 'End Date',
                          text: DateFormat(
                            'EEEE, MMMM d, yyyy • h:mm a',
                          ).format(event.endDate!),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Location
                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        text: event.location ?? 'No location specified',
                      ),
                      const SizedBox(height: 12),
                      // Capacity
                      _DetailRow(
                        icon: Icons.people,
                        label: 'Capacity',
                        text: event.isUnlimitedCapacity
                            ? 'Unlimited Capacity'
                            : '${event.capacity} Max Participants',
                      ),
                      const SizedBox(height: 12),
                      // Participants
                      _DetailRow(
                        icon: Icons.group,
                        label: 'Current Participants',
                        text:
                            '${controller.approvedParticipants.length} Approved',
                      ),
                      if (event.hostId != null) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.person_outline,
                          label: 'Host ID',
                          text: event.hostId!,
                        ),
                      ],
                      if (event.description != null &&
                          event.description!.isNotEmpty) ...[
                        const Divider(height: 32),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.foreground,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Settings & Configuration Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuration & Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsRow(
                        icon: Icons.lock_outline,
                        label: 'Requires Approval',
                        value: event.requiresApproval,
                      ),
                      const SizedBox(height: 12),
                      _SettingsRow(
                        icon: Icons.visibility_outlined,
                        label: 'Show Participants List',
                        value: event.showParticipants,
                      ),
                      const SizedBox(height: 12),
                      _SettingsRow(
                        icon: Icons.map_outlined,
                        label: 'Hide Location Until Approved',
                        value: event.hideLocationUntilApproved,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: event.visibility == 'public'
                            ? Icons.public
                            : Icons.public_off,
                        label: 'Visibility',
                        text:
                            event.visibility.capitalizeFirst ??
                            event.visibility,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Metadata Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metadata',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.fingerprint,
                        label: 'Event ID',
                        text: event.id,
                        isMono: true,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Created At',
                        text: DateFormat(
                          'MMM d, yyyy h:mm a',
                        ).format(event.createdAt),
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.update,
                        label: 'Last Updated',
                        text: DateFormat(
                          'MMM d, yyyy h:mm a',
                        ).format(event.updatedAt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final bool isMono;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.text,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.mutedForeground),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.foreground,
                  fontFamily: isMono ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.mutedForeground),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.foreground),
          ),
        ),
        Icon(
          value ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: value ? Colors.green : Colors.red,
          size: 20,
        ),
      ],
    );
  }
}
