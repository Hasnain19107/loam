import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loam_button.dart';
import '../controller/profile_controller.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller state for this page
    controller.initEditProfile();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(),
                    ),
                  ),
                  Text(
                    'Edit profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Profile photo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Obx(
                () => Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: controller.isUploadingPhoto
                          ? null
                          : controller.handlePhotoUpload,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: controller.isUploadingPhoto
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : _buildProfilePhoto(controller),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: controller.isUploadingPhoto
                            ? null
                            : controller.handlePhotoUpload,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // First name
                  _FormField(
                    label: 'First name',
                    controller: controller.firstNameController,
                    placeholder: 'Your first name',
                  ),
                  const SizedBox(height: 24),

                  // Phone number
                  _FormField(
                    label: 'Phone number',
                    controller: controller.phoneController,
                    placeholder: 'Your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Relationship status
                  _FormField(
                    label: 'Relationship status',
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => GestureDetector(
                              onTap: () =>
                                  controller.setRelationshipStatus('single'),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        controller.relationshipStatus ==
                                            'single'
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      controller.relationshipStatus == 'single'
                                      ? AppColors.primary.withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    'Single',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          controller.relationshipStatus ==
                                              'single'
                                          ? AppColors.primary
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => GestureDetector(
                              onTap: () =>
                                  controller.setRelationshipStatus('attached'),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        controller.relationshipStatus ==
                                            'attached'
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      controller.relationshipStatus ==
                                          'attached'
                                      ? AppColors.primary.withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    'Attached',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          controller.relationshipStatus ==
                                              'attached'
                                          ? AppColors.primary
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Children
                  _FormField(
                    label: 'Children',
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => GestureDetector(
                              onTap: () => controller.setHasChildren(false),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: !controller.hasChildren
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: !controller.hasChildren
                                      ? AppColors.primary.withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: !controller.hasChildren
                                          ? AppColors.primary
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => GestureDetector(
                              onTap: () => controller.setHasChildren(true),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: controller.hasChildren
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: controller.hasChildren
                                      ? AppColors.primary.withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: controller.hasChildren
                                          ? AppColors.primary
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Work industry
                  _FormField(
                    label: 'Work industry',
                    controller: controller.workIndustryController,
                    placeholder: 'e.g. Technology, Healthcare',
                  ),
                  const SizedBox(height: 24),

                  // Country of birth
                  _FormField(
                    label: 'Country of birth',
                    controller: controller.countryOfBirthController,
                    placeholder: 'e.g. Singapore',
                  ),
                  const SizedBox(height: 24),

                  // Locked fields
                  Divider(color: AppColors.border),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'These fields cannot be changed',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date of birth (locked)
                  _FormField(
                    label: 'Date of birth',
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          controller.userProfile?.dateOfBirth ?? 'Not set',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  _FormField(
                    label: 'Gender',
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          controller.userProfile?.gender ?? 'Not set',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  Obx(
                    () => LoamButton(
                      text: 'Save changes',
                      onPressed: () => controller.saveProfile(),
                      isLoading: controller.isLoading,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto(ProfileController controller) {
    // Show local photo if uploading, otherwise show profile photo or initials
    if (controller.localPhotoPath != null && controller.localPhotoPath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(controller.localPhotoPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitials(controller);
          },
        ),
      );
    }

    final photoUrl = controller.userProfile?.photo;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitials(controller);
          },
        ),
      );
    }

    return _buildInitials(controller);
  }

  Widget _buildInitials(ProfileController controller) {
    return Center(
      child: Text(
        controller.firstNameController.text.isNotEmpty
            ? controller.firstNameController.text[0].toUpperCase()
            : controller.userProfile?.firstName?.substring(0, 1).toUpperCase() ?? 'L',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final Widget? child;

  const _FormField({
    required this.label,
    this.controller,
    this.placeholder,
    this.keyboardType,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        child ??
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(hintText: placeholder),
            ),
      ],
    );
  }
}
