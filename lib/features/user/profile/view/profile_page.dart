import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

import '../../../../core/widgets/loam_card.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    final settingsItems = [
      _SettingsItem(
        icon: Icons.notifications_outlined,
        label: 'Notification preferences',
        route: AppRoutes.settingsNotifications,
      ),
      _SettingsItem(
        icon: Icons.language,
        label: 'App language',
        value: profileController.userProfile?.language ?? 'English',
        route: AppRoutes.settingsLanguage,
      ),
      _SettingsItem(
        icon: Icons.location_on_outlined,
        label: 'City',
        value: profileController.userProfile?.city ?? 'Singapore',
        route: AppRoutes.settingsCity,
      ),
    ];

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
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Profile card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LoamCard(
                padding: const EdgeInsets.all(16),
                onTap: () => Get.toNamed(AppRoutes.editProfile),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: profileController.userProfile?.photo != null &&
                              profileController.userProfile!.photo!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                profileController.userProfile!.photo!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      profileController.userProfile?.firstName
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          'L',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                profileController.userProfile?.firstName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'L',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileController.userProfile?.firstName ??
                                'Loam User',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profileController.userProfile?.phone ??
                                'No phone added',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Edit profile',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedForeground,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LoamCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: settingsItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return InkWell(
                          onTap: () => Get.toNamed(item.route),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: index < settingsItems.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  color: AppColors.mutedForeground,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (item.value != null) ...[
                                  Text(
                                    item.value!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.mutedForeground,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LoamCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.popover,
                onTap: () async {
                  await profileController.signOut();
                },
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.destructive, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      'Log out',
                      style: TextStyle(
                        color: AppColors.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? value;
  final String route;

  _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    required this.route,
  });
}
