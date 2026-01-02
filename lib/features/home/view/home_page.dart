import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';

import '../../../features/events/widgets/event_card.dart';
import '../controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final eventsController = homeController.eventsController;

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
                          homeController.greeting,
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
                          homeController.authController.userProfile?.photo !=
                              null
                          ? ClipOval(
                              child: Image.network(
                                homeController
                                    .authController
                                    .userProfile!
                                    .photo!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                homeController.greeting
                                        .replaceAll('Hey ', '')
                                        .isNotEmpty
                                    ? homeController.greeting
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
