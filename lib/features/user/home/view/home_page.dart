import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loam/features/user/events/controller/events_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/cached_image.dart';

import '../../events/widgets/event_card.dart';

import '../controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure EventsController is loaded as it's used directly
    Get.put(EventsController());
    final eventsController = controller.eventsController;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.greeting,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A place to meet genuine people, in real life.',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.profile),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          controller.authController.userProfile?.photo != null
                          ? CachedAvatarImage(
                              imageUrl:
                                  controller.authController.userProfile!.photo!,
                              size: 40,
                              errorWidget: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    controller.greeting
                                            .replaceAll('Hey ', '')
                                            .isNotEmpty
                                        ? controller.greeting
                                              .replaceAll('Hey ', '')[0]
                                              .toUpperCase()
                                        : 'L',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                controller.greeting
                                        .replaceAll('Hey ', '')
                                        .isNotEmpty
                                    ? controller.greeting
                                          .replaceAll('Hey ', '')[0]
                                          .toUpperCase()
                                    : 'L',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Events list
            Expanded(
              child: Obx(() {
                if (eventsController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final upcomingEvents = eventsController.upcomingEvents;

                if (upcomingEvents.isEmpty) {
                  return Center(
                    child: Text(
                      'No upcoming events',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Text(
                      'Upcoming gatherings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...upcomingEvents.map((event) => EventCard(event: event)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
