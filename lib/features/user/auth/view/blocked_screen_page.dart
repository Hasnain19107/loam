import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';

class BlockedScreenPage extends StatelessWidget {
  const BlockedScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get reason from route arguments
    final reason = Get.arguments as String?;
    final isAgeRestricted = reason == 'age';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your application is under review',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  isAgeRestricted
                      ? 'Thank you for your interest in Loam.\n\nOur team is currently reviewing your application and will be in touch if we\'re able to proceed.'
                      : 'We\'ll notify you once a decision has been made.',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
