import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loam_button.dart';
import '../controllers/admin_event_create_controller.dart';
import '../../widgets/admin_layout.dart';

class AdminEventCreatePage extends StatelessWidget {
  const AdminEventCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminEventCreateController());
    final formKey = GlobalKey<FormState>();

    return AdminLayout(
      title: 'Create Event',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image Section
                _SectionCard(
                  title: 'Cover Image',
                  child: Column(
                    children: [
                      // Image Upload Options
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.isUploadingImage
                                  ? null
                                  : () => _showImageSourceDialog(
                                      context,
                                      controller,
                                    ),
                              icon: const Icon(Icons.photo_library, size: 20),
                              label: const Text('Upload from Phone'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.isUploadingImage
                                  ? null
                                  : () {
                                      controller.coverImageUrlController
                                          .clear();
                                      controller.coverImageUrl.value = '';
                                      controller.removeLocalImage();
                                    },
                              icon: const Icon(Icons.clear, size: 20),
                              label: const Text('Clear'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // URL Input (Alternative)
                      TextFormField(
                        controller: controller.coverImageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Or enter image URL',
                          hintText: 'Enter image URL',
                          prefixIcon: Icon(Icons.link),
                        ),
                        onChanged: (value) {
                          controller.coverImageUrl.value = value;
                          // Clear local image if URL is entered
                          if (value.isNotEmpty) {
                            controller.removeLocalImage();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Image Preview
                      Obx(() {
                        // Show local image if available
                        if (controller.localImagePath != null) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(controller.localImagePath!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (controller.isUploadingImage)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }
                        // Show network image if URL is available
                        if (controller.coverImageUrl.value.isNotEmpty) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  controller.coverImageUrl.value,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        // Show placeholder
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.border,
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: AppColors.mutedForeground,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No cover image set',
                                style: TextStyle(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upload from phone or enter URL',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Event Details Section
                _SectionCard(
                  title: 'Event Details',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Event Name *',
                          hintText: 'e.g., Coffee & Conversations',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Event name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.startDateController,
                              decoration: const InputDecoration(
                                labelText: 'Start Date *',
                              ),
                              readOnly: true,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  controller.startDateController.text =
                                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.startTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Start Time *',
                              ),
                              readOnly: true,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  controller.startTimeController.text =
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.endDateController,
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                              ),
                              readOnly: true,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  controller.endDateController.text =
                                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: controller.endTimeController,
                              decoration: const InputDecoration(
                                labelText: 'End Time',
                              ),
                              readOnly: true,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  controller.endTimeController.text =
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText:
                              'e.g., Secret location (shared after approval)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Obx(
                            () => Switch(
                              value: controller.hideLocationUntilApproved.value,
                              onChanged: (value) {
                                controller.hideLocationUntilApproved.value =
                                    value;
                              },
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Location will be shared only after participants are approved',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'What this event is about, who it\'s for, what to expect...',
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Settings Section
                _SectionCard(
                  title: 'Settings',
                  child: Column(
                    children: [
                      _SettingRow(
                        title: 'Approval Required',
                        subtitle: 'Users must be approved before attending',
                        child: Obx(
                          () => Switch(
                            value: controller.requiresApproval.value,
                            onChanged: (value) {
                              controller.requiresApproval.value = value;
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      _SettingRow(
                        title: 'Unlimited Capacity',
                        subtitle: 'No limit on number of attendees',
                        child: Obx(
                          () => Switch(
                            value: controller.isUnlimitedCapacity.value,
                            onChanged: (value) {
                              controller.isUnlimitedCapacity.value = value;
                            },
                          ),
                        ),
                      ),
                      Obx(
                        () => !controller.isUnlimitedCapacity.value
                            ? Column(
                                children: [
                                  const Divider(),
                                  TextFormField(
                                    controller: controller.capacityController,
                                    decoration: const InputDecoration(
                                      labelText: 'Maximum Capacity',
                                      hintText: 'e.g., 20',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                      const Divider(),
                      _SettingRow(
                        title: 'Show Participants',
                        subtitle: controller.showParticipants.value
                            ? 'Users can see who else is attending'
                            : 'Participant list is hidden from attendees',
                        child: Obx(
                          () => Switch(
                            value: controller.showParticipants.value,
                            onChanged: (value) {
                              controller.showParticipants.value = value;
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Visibility'),
                          const SizedBox(height: 8),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      controller.visibility.value = 'public';
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          controller.visibility.value ==
                                              'public'
                                          ? AppColors.primary
                                          : null,
                                      foregroundColor:
                                          controller.visibility.value ==
                                              'public'
                                          ? AppColors.primaryForeground
                                          : AppColors.foreground,
                                    ),
                                    child: const Text('Public'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      controller.visibility.value = 'hidden';
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          controller.visibility.value ==
                                              'hidden'
                                          ? AppColors.primary
                                          : null,
                                      foregroundColor:
                                          controller.visibility.value ==
                                              'hidden'
                                          ? AppColors.primaryForeground
                                          : AppColors.foreground,
                                    ),
                                    child: const Text('Hidden'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status'),
                          const SizedBox(height: 8),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      controller.status.value = 'draft';
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          controller.status.value == 'draft'
                                          ? AppColors.primary
                                          : null,
                                      foregroundColor:
                                          controller.status.value == 'draft'
                                          ? AppColors.primaryForeground
                                          : AppColors.foreground,
                                    ),
                                    child: const Text('Draft'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      controller.status.value = 'published';
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          controller.status.value == 'published'
                                          ? AppColors.primary
                                          : null,
                                      foregroundColor:
                                          controller.status.value == 'published'
                                          ? AppColors.primaryForeground
                                          : AppColors.foreground,
                                    ),
                                    child: const Text('Published'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => LoamButton(
                          text: controller.isLoading
                              ? (controller.isEditing
                                    ? 'Updating...'
                                    : 'Creating...')
                              : (controller.isEditing
                                    ? 'Update Event'
                                    : 'Create Event'),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              controller.saveEvent();
                            }
                          },
                          isLoading: controller.isLoading,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

void _showImageSourceDialog(
  BuildContext context,
  AdminEventCreateController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mutedForeground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.photo_library, size: 28),
            title: const Text(
              'Choose from Gallery',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              controller.pickImageFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, size: 28),
            title: const Text(
              'Take Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              controller.pickImageFromCamera();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
