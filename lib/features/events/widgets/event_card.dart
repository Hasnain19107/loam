import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isCompact;

  const EventCard({
    super.key,
    required this.event,
    this.isCompact = false,
  });

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.eventDetail.replaceAll(':id', event.id),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.popover,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.loamCardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCompact)
              Container(
                height: 128,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Text('✨', style: TextStyle(fontSize: 32)),
                    ),
                    if (event.requiresApproval)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 12,
                                color: AppColors.foreground,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Requires approval',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(event.startDate)} · ${_formatTime(event.startDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hosted by Loam',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground.withOpacity(0.7),
                          ),
                        ),
                        if (event.spotsLeft != null && !event.isPast) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${event.spotsLeft} spots left',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (event.isPast) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Past gathering',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

