import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';

import '../../../../core/widgets/loam_card.dart';
import '../../../../data/models/event_model.dart';
import '../controller/my_events_controller.dart';

class MyEventsPage extends GetView<MyEventsController> {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded if not already
    final controller = Get.put(MyEventsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                'My Events',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Tabs Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  if (controller.isLoading) {
                    return Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                    );
                  }

                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // Tabs
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: TabBar(
                            labelColor: AppColors.foreground,
                            unselectedLabelColor: AppColors.mutedForeground,
                            indicator: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            tabs: const [
                              Tab(text: 'Upcoming'),
                              Tab(text: 'Past'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Content
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildEventsList(
                                controller.upcomingEvents,
                                'upcoming',
                                context,
                              ),
                              _buildEventsList(
                                controller.pastEvents,
                                'past',
                                context,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(
    List<MyEventItem> items,
    String type,
    BuildContext context,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(type, context);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isPast = type == 'past';
        return Padding(
          padding: EdgeInsets.only(bottom: index < items.length - 1 ? 16 : 0),
          child: _EventCard(
            event: item.event,
            status: item.status,
            isPast: isPast,
            onTap: () => Get.toNamed(
              AppRoutes.eventDetail.replaceAll(':id', item.event.id),
              parameters: {'source': 'my-gatherings'},
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No $type events',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              type == 'upcoming'
                  ? "You haven't joined any upcoming events yet."
                  : "No past events found.",
              style: TextStyle(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final String status;
  final bool isPast;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.status,
    required this.isPast,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  Color _getStatusColor() {
    if (isPast) return AppColors.muted;
    switch (status) {
      case AppConstants.participationStatusApproved:
        return Colors.green.shade100;
      case AppConstants.participationStatusPending:
        return Colors.orange.shade100;
      case AppConstants.participationStatusRejected:
        return Colors.red.shade100;
      default:
        return AppColors.muted;
    }
  }

  Color _getStatusTextColor() {
    if (isPast) return AppColors.mutedForeground;
    switch (status) {
      case AppConstants.participationStatusApproved:
        return Colors.green.shade800;
      case AppConstants.participationStatusPending:
        return Colors.orange.shade800;
      case AppConstants.participationStatusRejected:
        return Colors.red.shade800;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _getStatusText() {
    if (isPast) return 'Past';
    switch (status) {
      case AppConstants.participationStatusApproved:
        return 'Confirmed';
      case AppConstants.participationStatusPending:
        return 'Pending';
      case AppConstants.participationStatusRejected:
        return 'Rejected';
      default:
        return status.capitalizeFirst ?? status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.6 : 1.0,
      child: LoamCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.startDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(event.startDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
