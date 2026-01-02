import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/loam_button.dart';
import '../controller/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    color: AppColors.foreground.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: authController.loginEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Email',
                        ),
                        validator: authController.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: authController.loginPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Password',
                        ),
                        validator: (value) =>
                            authController.validatePassword(value),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text('Forgot your password?'),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => LoamButton(
                          text: authController.isLoading
                              ? 'Signing in...'
                              : 'Log in',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              authController.signIn();
                            }
                          },
                          isLoading: authController.isLoading,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social buttons
                  LoamButton(
                    text: 'Continue with Apple',
                    variant: LoamButtonVariant.social,
                    icon: Icons.apple,
                    onPressed: () {
                      // TODO: Implement Apple sign in
                    },
                  ),
                  const SizedBox(height: 12),
                  LoamButton(
                    text: 'Continue with Google',
                    variant: LoamButtonVariant.social,
                    icon: Icons.g_mobiledata,
                    onPressed: () {
                      // TODO: Implement Google sign in
                    },
                  ),

                  const SizedBox(height: 32),

                  // Sign up link
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: AppColors.mutedForeground),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.quiz),
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
