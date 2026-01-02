import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loam_button.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create your account',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you\'d like to continue',
                style: TextStyle(color: AppColors.mutedForeground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              LoamButton(
                text: 'Sign in with Apple',
                variant: LoamButtonVariant.social,
                icon: Icons.apple,
                onPressed: () {
                  // TODO: Implement Apple sign in
                },
              ),
              const SizedBox(height: 12),
              LoamButton(
                text: 'Sign in with Google',
                variant: LoamButtonVariant.social,
                icon: Icons.g_mobiledata,
                onPressed: () {
                  // TODO: Implement Google sign in
                },
              ),
              const SizedBox(height: 12),
              LoamButton(
                text: 'Sign up with email',
                variant: LoamButtonVariant.social,
                icon: Icons.mail_outline,
                onPressed: () => Get.toNamed(AppRoutes.signup),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: AppColors.mutedForeground),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.login),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
