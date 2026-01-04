import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/admin_event_detail_controller.dart';
import '../../widgets/admin_layout.dart';

class AdminEventRequestsPage extends StatelessWidget {
  const AdminEventRequestsPage({super.key});

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
      final match = RegExp(
        r'/admin/events/([^/?]+)/requests',
      ).firstMatch(currentRoute);
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
      title: 'Event Requests',
      child: DefaultTabController(
        length: 3,
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final event = controller.event;
            if (event == null) {
              return const Center(child: Text('Event not found'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                  color: AppColors.card,
                  child: TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.mutedForeground,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(
                        text:
                            'Pending (${controller.pendingParticipants.length})',
                      ),
                      Tab(
                        text:
                            'Approved (${controller.approvedParticipants.length})',
                      ),
                      Tab(
                        text:
                            'Rejected (${controller.rejectedParticipants.length})',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ParticipantsList(
                        participants: controller.pendingParticipants,
                        controller: controller,
                        emptyMessage: 'No pending requests',
                        showApprove: true,
                        showReject: true,
                      ),
                      _ParticipantsList(
                        participants: controller.approvedParticipants,
                        controller: controller,
                        emptyMessage: 'No approved participants',
                        showReject:
                            true, // Allow rejecting (removing) approved users
                      ),
                      _ParticipantsList(
                        participants: controller.rejectedParticipants,
                        controller: controller,
                        emptyMessage: 'No rejected requests',
                        showApprove: true, // Allow approving rejected users
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ParticipantsList extends StatelessWidget {
  final List<dynamic>
  participants; // Using dynamic to avoid import issues if model not imported, but better to use specific type if possible without adding imports. The controller uses EventParticipantModel.
  final AdminEventDetailController controller;
  final String emptyMessage;
  final bool showApprove;
  final bool showReject;

  const _ParticipantsList({
    required this.participants,
    required this.controller,
    required this.emptyMessage,
    this.showApprove = false,
    this.showReject = false,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final profile = controller.getUserProfile(participant.userId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondary,
                backgroundImage: profile?.photo != null
                    ? NetworkImage(profile!.photo!)
                    : null,
                child: profile?.photo == null
                    ? Text(
                        profile?.firstName?.substring(0, 1).toUpperCase() ??
                            '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.firstName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? '—',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested ${DateFormat('MMM d, yyyy').format(participant.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (showApprove || showReject)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showApprove)
                      IconButton(
                        onPressed: () {
                          controller.updateParticipantStatus(
                            participant.id,
                            'approved',
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 24),
                        color: Colors.green,
                        tooltip: 'Approve',
                      ),
                    if (showReject)
                      IconButton(
                        onPressed: () {
                          controller.updateParticipantStatus(
                            participant.id,
                            'rejected',
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 24),
                        color: AppColors.destructive,
                        tooltip: 'Reject',
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
