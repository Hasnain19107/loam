import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controller/event_detail_controller.dart';

class EventParticipantsPage extends StatelessWidget {
  const EventParticipantsPage({super.key});

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
      final match = RegExp(r'/event/([^/?]+)/participants').firstMatch(currentRoute);
      if (match != null) {
        final captured = match.group(1);
        if (captured != null && captured != ':id') {
          eventId = captured;
        }
      }
    }

    final controller = Get.find<EventDetailController>(
      tag: eventId.isNotEmpty && eventId != ':id' ? eventId : null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Who's going"),
              if (controller.event != null)
                Text(
                  controller.event!.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.participants.isEmpty) {
          return Center(
            child: Text(
              'No participants yet',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.participants.length,
          itemBuilder: (context, index) {
            final participant = controller.participants[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.popover,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: participant.photo != null
                        ? ClipOval(
                            child: Image.network(
                              participant.photo!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              participant.firstName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    participant.firstName ?? 'Guest',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
