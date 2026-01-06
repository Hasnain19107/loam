import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../widgets/admin_layout.dart';
import '../controller/admin_settings_controller.dart';
import '../controller/admin_export_controller.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSettingsController());

    return AdminLayout(
      title: 'Settings',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin & Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage admins and app settings',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),

              // Invite an Admin (always show, but functionality restricted to super admins)
              _InviteAdminCard(controller: controller),
              const SizedBox(height: 16),

              // Admin List
              _AdminListCard(controller: controller),
              const SizedBox(height: 16),

              // Moderation
              _ModerationCard(controller: controller),
              const SizedBox(height: 16),

              // Event Defaults
              _EventDefaultsCard(controller: controller),
              const SizedBox(height: 16),

              // Quiz Onboarding
              _QuizOnboardingCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteAdminCard extends StatelessWidget {
  final AdminSettingsController controller;

  const _InviteAdminCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.popover,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.loamCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invite an Admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a new admin by email address',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add admin by email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: controller.email,
                          )..selection = TextSelection.collapsed(
                              offset: controller.email.length,
                            ),
                          onChanged: controller.setEmail,
                          decoration: InputDecoration(
                            hintText: 'name@email.com',
                            errorText: controller.emailError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: controller.emailError != null
                                    ? AppColors.destructive
                                    : AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: controller.emailError != null
                                    ? AppColors.destructive
                                    : AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => ElevatedButton(
                            onPressed: controller.isAddingAdmin
                                ? null
                                : controller.addAdmin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.primaryForeground,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: controller.isAddingAdmin
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryForeground,
                                      ),
                                    ),
                                  )
                                : const Text('Add Admin'),
                          )),
                    ],
                  ),
                  // Success message
                  Obx(() => controller.addAdminSuccessMessage != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.addAdminSuccessMessage!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              )),
        ],
      ),
    );
  }
}

class _AdminListCard extends StatelessWidget {
  final AdminSettingsController controller;

  const _AdminListCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.popover,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.loamCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current admins with access to the dashboard',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final admins = controller.admins;
            final invites = controller.invites;
            final currentUserId = controller.currentUserId;

            if (admins.isEmpty && invites.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No admins found',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Active Admins
                ...admins.map((admin) {
                  final isCurrentUser = admin['user_id'] == currentUserId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                admin['email'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${admin['role'] == AppConstants.roleSuperAdmin ? 'Super Admin' : 'Event Host'} • Active',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentUser)
                          Text(
                            '(You)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          )
                        else if (controller.isSuperAdmin)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.destructive,
                              size: 20,
                            ),
                            onPressed: () => controller.removeAdmin(
                              admin['id'],
                              admin['user_id'],
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                // Pending Invites
                if (invites.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Pending Invites',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  ...invites.map((invite) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invite['email'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${invite['role'] == AppConstants.roleSuperAdmin ? 'Super Admin' : 'Event Host'} • Pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (controller.isSuperAdmin)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.destructive,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.removeInvite(invite['id']),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ModerationCard extends StatelessWidget {
  final AdminSettingsController controller;

  const _ModerationCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final exportController = Get.find<AdminExportController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.popover,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.loamCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moderation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quick access to moderation tools',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          // Blocked users
          InkWell(
            onTap: controller.navigateToBlockedUsers,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Blocked users',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.mutedForeground,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // User exports
          Obx(() {
            final isLoading = exportController.isExportingUsers;
            return InkWell(
              onTap: isLoading ? null : exportController.exportUsersToCSV,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'User exports (CSV)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isLoading
                            ? AppColors.mutedForeground
                            : AppColors.foreground,
                      ),
                    ),
                    isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.chevron_right,
                            color: AppColors.mutedForeground,
                            size: 20,
                          ),
                  ],
                ),
              ),
            );
          }),
          // Event exports
          Obx(() {
            final isLoading = exportController.isExportingEvents;
            return InkWell(
              onTap: isLoading ? null : exportController.exportEventsToCSV,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Event exports (CSV)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isLoading
                            ? AppColors.mutedForeground
                            : AppColors.foreground,
                      ),
                    ),
                    isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.chevron_right,
                            color: AppColors.mutedForeground,
                            size: 20,
                          ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EventDefaultsCard extends StatelessWidget {
  final AdminSettingsController controller;

  const _EventDefaultsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.popover,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.loamCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Defaults',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Default settings for new events',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Default city',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.defaultCity,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approval required',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Require approval for event signups',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => controller.isSavingApprovalRequired
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: controller.approvalRequired,
                      onChanged: controller.toggleApprovalRequired,
                      activeColor: AppColors.primary,
                    )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reveal location after approval',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.approvalRequired
                          ? 'Only show exact location to approved participants'
                          : 'Enable "Approval required" to use this setting',
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.approvalRequired
                            ? AppColors.mutedForeground
                            : AppColors.mutedForeground.withOpacity(0.6),
                      ),
                    )),
                  ],
                ),
              ),
              Obx(() {
                final isSaving = controller.isSavingRevealLocation;
                final isDisabled = !controller.approvalRequired;
                
                return isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: controller.revealLocationAfterApproval,
                        onChanged: isDisabled ? null : controller.toggleRevealLocationAfterApproval,
                        activeColor: AppColors.primary,
                      );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizOnboardingCard extends StatelessWidget {
  final AdminSettingsController controller;

  const _QuizOnboardingCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.popover,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.loamCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quiz Onboarding',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Control whether new users see the quiz during signup',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enable Quiz Onboarding',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'When disabled, users skip the quiz and go straight to sign up',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.isSavingQuizSetting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Switch(
                      value: controller.quizOnboardingEnabled,
                      onChanged: controller.toggleQuizOnboarding,
                      activeColor: AppColors.primary,
                    ),
                ],
              )),
        ],
      ),
    );
  }
}