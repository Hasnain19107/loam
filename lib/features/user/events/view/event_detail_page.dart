import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loam_button.dart';
import '../controller/event_detail_controller.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract event ID from route parameters or path
    String eventId = Get.parameters['id'] ?? '';
    
    // If param is empty or just the placeholder ':id', try to get from query params
    if (eventId.isEmpty || eventId == ':id') {
      final uri = Uri.parse(Get.currentRoute);
      if (uri.queryParameters.containsKey('id')) {
        eventId = uri.queryParameters['id']!;
      }
    }

    // Fallback to regex from path if still empty or placeholder
    if (eventId.isEmpty || eventId == ':id') {
      final currentRoute = Get.currentRoute;
      final match = RegExp(r'/event/([^/?]+)').firstMatch(currentRoute);
      if (match != null) {
        final captured = match.group(1);
        if (captured != null && captured != ':id') {
          eventId = captured;
        }
      }
    }

    final controller = Get.put(
      EventDetailController(),
      tag: eventId.isNotEmpty && eventId != ':id' ? eventId : null,
    );

    // Show report dialog if controller triggers it
    // Using ObxListener or simply letting controller handle showing is handled via callback below
    // But since the controller logic handles "Action", we can just invoke it.

    return Obx(() {
      if (controller.showConfirmation) {
        return _buildConfirmationScreen(context, controller);
      }

      if (controller.isLoading || controller.event == null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final event = controller.event!;
      final displayDate = controller.formattedDate;
      final displayTime = controller.formattedTime;
      final spotsLeft = controller.spotsLeft;
      final isPast = controller.isPast;
      final showStickyRegister =
          !isPast && !controller.isSignedUp && !controller.isRejected;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Hero image at top
                Column(
                  children: [
                    Container(
                      height: 256,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty
                          ? Image.network(
                              event.coverImageUrl!,
                              height: 256,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                // Show fallback gradient while loading
                                return Container(
                                  height: 256,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withOpacity(0.3),
                                        AppColors.primary.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to original gradient design
                                return Container(
                                  height: 256,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withOpacity(0.3),
                                        AppColors.primary.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text('✨', style: TextStyle(fontSize: 64)),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('✨', style: TextStyle(fontSize: 64)),
                            ),
                    ),
                  ],
                ),

                // Back button - moves with scroll
                Positioned(
                  top: 16,
                  left: 16,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ),

                // Content card
                Column(
                  children: [
                    const SizedBox(height: 200),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.popover,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                _EventDetailRow(
                                  icon: Icons.calendar_today,
                                  text: displayDate,
                                ),
                                const SizedBox(height: 12),
                                _EventDetailRow(
                                  icon: Icons.access_time,
                                  text: displayTime,
                                ),
                                const SizedBox(height: 12),
                                _EventDetailRow(
                                  icon: Icons.location_on,
                                  text: event.location ?? 'Location TBA',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.calendar_today,
                                  label: controller.getRegisterButtonText(),
                                  onPressed: controller.canRegister()
                                      ? () => controller.registerForEvent()
                                      : null,
                                  isPrimary: true,
                                  isDisabled: !controller.canRegister(),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.share,
                                  label: 'Share',
                                  onPressed: () => controller.shareEvent(),
                                  isPrimary: false,
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.chat_bubble_outline,
                                  label: 'Contact',
                                  onPressed: controller.isApproved
                                      ? () => controller.contactOrganizer()
                                      : null,
                                  isPrimary: false,
                                  isDisabled: !controller.isApproved,
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.more_horiz,
                                  label: 'More',
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (_) =>
                                          _buildMoreSheet(context, controller),
                                    );
                                  },
                                  isPrimary: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (spotsLeft != null &&
                                !isPast &&
                                !controller.isRejected)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$spotsLeft spots left',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            if (controller.isRejected) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'This event requires approval. You\'re not able to register for this event.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (event.requiresApproval &&
                                !controller.isSignedUp &&
                                !controller.isRejected) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'This event requires approval. After you register, our team will review your request.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if ((controller.isApproved ||
                                    event.showParticipants) &&
                                controller.participants.isNotEmpty) ...[
                              Divider(color: AppColors.border),
                              const SizedBox(height: 24),
                              InkWell(
                                onTap: () => Get.toNamed(
                                  AppRoutes.eventParticipants.replaceAll(
                                    ':id',
                                    controller.eventId,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 72, // 32px avatar + 20px spacing * 2 for 3 avatars
                                      height: 32,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: controller.participants
                                            .take(3)
                                            .toList()
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final index = entry.key;
                                              final participant = entry.value;
                                              return Positioned(
                                                left: (index * 20).toDouble(),
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppColors.background,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 14,
                                                    backgroundColor:
                                                        AppColors.secondary,
                                                    child:
                                                        participant.photo != null
                                                        ? ClipOval(
                                                            child: Image.network(
                                                              participant.photo!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Text(
                                                            participant.firstName
                                                                    ?.substring(
                                                                      0,
                                                                      1,
                                                                    )
                                                                    .toUpperCase() ??
                                                                '?',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primary,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 48),
                                    Text(
                                      "See who's going",
                                      style: TextStyle(
                                        color: AppColors.foreground,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            Divider(color: AppColors.border),
                            const SizedBox(height: 24),
                            Text(
                              'About this gathering',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.description ?? '',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: showStickyRegister ? 100 : 24),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: showStickyRegister
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.95),
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(
                  child: LoamButton(
                    text: controller.isSubmitting
                        ? 'Submitting...'
                        : 'Register',
                    onPressed: () => controller.registerForEvent(),
                    isLoading: controller.isSubmitting,
                  ),
                ),
              )
            : null,
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    bool isDisabled = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isPrimary
                ? (isDisabled ? AppColors.secondary : AppColors.primary)
                : AppColors.background,
            border: isPrimary ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary
                    ? (isDisabled
                          ? AppColors.mutedForeground
                          : AppColors.primaryForeground)
                    : AppColors.foreground,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: isPrimary
                      ? (isDisabled
                            ? AppColors.mutedForeground
                            : AppColors.primaryForeground)
                      : AppColors.foreground,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationScreen(BuildContext context, EventDetailController controller) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                    Icons.mail_outline,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your registration has been received',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Our team is reviewing your registration and will let you know once you're approved.",
                  style: TextStyle(color: AppColors.mutedForeground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                LoamButton(
                  text: 'Back to events',
                  onPressed: () => controller.navigateToHome(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreSheet(
    BuildContext context,
    EventDetailController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'More options',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_browser),
                  title: const Text('Open in browser'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.openInBrowser();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.red),
                  title: const Text(
                    'Report event',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Open dialog using controller stub but defining dialog here since it is UI
                    Get.dialog(_buildReportDialog());
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDialog() {
    return AlertDialog(
      title: const Text('Thanks for letting us know'),
      content: const Text('Our team will review this event.'),
      actions: [
        LoamButton(text: 'Done', onPressed: () => Get.toNamed(AppRoutes.main)),
      ],
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: AppColors.mutedForeground)),
      ],
    );
  }
}
