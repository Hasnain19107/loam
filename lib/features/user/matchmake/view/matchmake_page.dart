import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

import '../../../../core/widgets/loam_button.dart';
import '../../../../core/widgets/loam_card.dart';
import '../controller/matchmake_controller.dart';

class MatchmakePage extends StatelessWidget {
  const MatchmakePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchmakeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return Center(
              child: Text(
                'Loading...',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            );
          }

          // State: User has a match
          if (controller.state == MatchmakeState.matched &&
              controller.matchedUser != null) {
            final matchedUser = controller.matchedUser!;
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LoamCard(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 4,
                                ),
                              ),
                              child: matchedUser.photo != null
                                  ? ClipOval(
                                      child: Image.network(
                                        matchedUser.photo!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildAvatarFallback(
                                                  matchedUser.firstName,
                                                ),
                                      ),
                                    )
                                  : _buildAvatarFallback(matchedUser.firstName),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              matchedUser.firstName ?? 'Your Match',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Matched via Loam',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 24),
                            LoamButton(
                              text: 'Start chatting',
                              icon: Icons.chat,
                              onPressed: () => Get.toNamed(AppRoutes.chat),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // State: User has submitted, waiting for match
          if (controller.state == MatchmakeState.submitted) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LoamCard(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Thanks for your input',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Give us 48 hours to review, and we\'ll pass you a match.',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            LoamButton(
                              text: 'Back to Home',
                              variant: LoamButtonVariant.outline,
                              onPressed: () => Get.offAllNamed(AppRoutes.home),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // State: Not started
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Matchmake',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Answer a few questions and we\'ll suggest gatherings that fit you.',
                            style: TextStyle(color: AppColors.mutedForeground),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: LoamButton(
                            text: 'Start',
                            onPressed: () =>
                                Get.toNamed(AppRoutes.matchmakeChat),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAvatarFallback(String? firstName) {
    return Center(
      child: Text(
        (firstName?.isNotEmpty == true ? firstName![0] : 'U').toUpperCase(),
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
