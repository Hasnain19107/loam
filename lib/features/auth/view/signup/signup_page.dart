import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loam_button.dart';
import '../../controller/auth_controller.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Get.back(),
                            color: AppColors.foreground.withOpacity(0.7),
                          ),
                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'Create account',
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email to get started',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 32),

                          // Form
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller:
                                    authController.signupEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Email',
                                ),
                                validator: authController.validateEmail,
                                onChanged: (_) {
                                  // Trigger validation when email changes
                                  if (formKey.currentState != null) {
                                    formKey.currentState!.validate();
                                  }
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller:
                                    authController.signupPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Create password',
                                  hintText: 'Create password',
                                ),
                                validator: (value) => authController
                                    .validatePassword(value, isSignup: true),
                                onChanged: (_) {
                                  // Trigger validation of confirm password when password changes
                                  if (formKey.currentState != null) {
                                    formKey.currentState!.validate();
                                  }
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller:
                                    authController.signupConfirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Re-enter password',
                                  hintText: 'Re-enter password',
                                ),
                                validator: (value) => authController
                                    .validateConfirmPassword(value),
                                onChanged: (_) {
                                  // Trigger validation when confirm password changes
                                  if (formKey.currentState != null) {
                                    formKey.currentState!.validate();
                                  }
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 16),
                              Text.rich(
                                TextSpan(
                                  text: 'By continuing, you agree to our ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Obx(
                                () {
                                  final email = authController.signupEmailController.text.trim();
                                  final password = authController.signupPasswordController.text;
                                  final confirmPassword = authController.signupConfirmPasswordController.text;
                                  
                                  final isEmailValid = authController.validateEmail(email) == null;
                                  final isPasswordValid = authController.validatePassword(password, isSignup: true) == null;
                                  final isConfirmPasswordValid = authController.validateConfirmPassword(confirmPassword) == null;
                                  
                                  final isFormValid = isEmailValid && isPasswordValid && isConfirmPasswordValid && 
                                                      email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty;
                                  
                                  return LoamButton(
                                    text: authController.isLoading
                                        ? 'Creating account...'
                                        : 'Continue',
                                    onPressed: isFormValid && !authController.isLoading
                                        ? () {
                                            if (formKey.currentState!.validate()) {
                                              authController.signUp();
                                            }
                                          }
                                        : null,
                                    isLoading: authController.isLoading,
                                  );
                                },
                              ),
                            ],
                          ),

                          const Spacer(),
                          

                          // Login link
                           Center(
                             child: Text.rich(
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(
                                    color: AppColors.mutedForeground,
                                  ),
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
                              ),
                           ),
                        SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
