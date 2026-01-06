import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loam_button.dart';
import '../../controller/auth_controller.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return  ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Spacer to push content to center
                      SizedBox(height: (constraints.maxHeight - 400) / 2),
                      // Centered content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          Obx(
                            () => LoamButton(
                              text: 'Sign up with Apple',
                              variant: LoamButtonVariant.social,
                              icon: Icons.apple,
                              onPressed: (authController.isLoadingApple || authController.isLoadingGoogle)
                                  ? null
                                  : () => authController.signUpWithApple(),
                              isLoading: authController.isLoadingApple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(
                            () => LoamButton(
                              text: 'Sign up with Google',
                              variant: LoamButtonVariant.social,
                              iconWidget: Image.asset(
                                'assets/google.png',
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                              onPressed: (authController.isLoadingApple || authController.isLoadingGoogle)
                                  ? null
                                  : () => authController.signUpWithGoogle(),
                              isLoading: authController.isLoadingGoogle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LoamButton(
                            text: 'Sign up with email',
                            variant: LoamButtonVariant.social,
                            icon: Icons.mail_outline,
                          
                            onPressed: () => Get.toNamed(AppRoutes.signup),
                          ),
                        ],
                      ),
                      // Spacer to push login link to bottom
                      const Spacer(),
                      // Login link at bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text.rich(
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
                      ),
                    ],
                  ),
                ),
              
            );
          },
        ),
      ),
    );
  }
}
