import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loam_button.dart';
import '../../../../core/widgets/country_code_select.dart';
import '../../../../core/widgets/birthdate_picker.dart';
import '../../controller/auth_controller.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Progress indicator
              Obx(
                () => Row(
                  children: List.generate(
                    authController.totalOnboardingSteps,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index < authController.onboardingStep
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Step content
              Expanded(
                child: Obx(() => _buildStepContent(context, authController)),
              ),

              // Next button
              Obx(() {
                final canProceed = authController.canProceedOnboarding();
                return LoamButton(
                  text: authController.getOnboardingButtonText(),
                  onPressed:
                      canProceed && !authController.isOnboardingSubmitting
                      ? authController.handleOnboardingStepAction
                      : null,
                  isLoading: authController.isOnboardingSubmitting,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    AuthController authController,
  ) {
    switch (authController.onboardingStep) {
      case 1:
        return _buildPhoneStep(context, authController);
      case 2:
        return _buildFirstNameStep(context, authController);
      case 3:
        return _buildLastNameStep(context, authController);
      case 4:
        return _buildBirthdateStep(context, authController);
      case 5:
        return _buildPhotoStep(context, authController);
      case 6:
        return _buildNotificationsStep(context, authController);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhoneStep(BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's your phone number?",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll use this to keep you updated",
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Obx(
              () => CountryCodeSelect(
                value: authController.onboardingCountryCode,
                onChange: authController.setOnboardingCountryCode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: authController.onboardingPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Phone number'),
                onChanged: authController.setOnboardingPhone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFirstNameStep(
    BuildContext context,
    AuthController authController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's your first name?",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "This is how you'll appear to others",
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: authController.onboardingFirstNameController,
          decoration: const InputDecoration(hintText: 'First name'),
        ),
      ],
    );
  }

  Widget _buildLastNameStep(
    BuildContext context,
    AuthController authController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's your last name?",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "This helps us personalize your experience",
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: authController.onboardingLastNameController,
          decoration: const InputDecoration(hintText: 'Last name'),
        ),
      ],
    );
  }

  Widget _buildBirthdateStep(
    BuildContext context,
    AuthController authController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's your date of birth?",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "This helps us ensure Loam remains a safe, age-appropriate community.",
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const Spacer(),
        Obx(
          () => BirthdatePicker(
            value: authController.onboardingBirthdate,
            onChange: authController.setOnboardingBirthdate,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPhotoStep(BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add a profile photo",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Upload your best photo",
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const Spacer(),
        Center(
          child: Column(
            children: [
              Obx(
                () => GestureDetector(
                  onTap: authController.handleOnboardingPhotoUpload,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child:
                        authController.onboardingPhotoUrl != null &&
                            authController.onboardingPhotoUrl!.isNotEmpty
                        ? ClipOval(
                            child: _buildImageWidget(
                              authController.onboardingPhotoUrl!,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: AppColors.mutedForeground,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: authController.handleOnboardingPhotoUpload,
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text(
                  'Upload photo',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildNotificationsStep(
    BuildContext context,
    AuthController authController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enable notifications",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Get reminders for events and updates",
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 32),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.popover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Push notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stay updated on events',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: authController.onboardingNotifications,
                  onChanged: authController.setOnboardingNotifications,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildImageWidget(String imagePath) {
    // Check if it's a local file path or a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image,
            size: 32,
            color: AppColors.mutedForeground,
          );
        },
      );
    } else {
      // Local file path
      // Remove 'file://' prefix if present
      final cleanPath = imagePath.replaceFirst('file://', '');
      return Image.file(
        File(cleanPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image,
            size: 32,
            color: AppColors.mutedForeground,
          );
        },
      );
    }
  }
}
