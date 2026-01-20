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
                    child: Obx(() {
                      // Show verification UI if email was sent
                      if (authController.emailVerificationSent) {
                        return _buildVerificationUI(context, authController);
                      }
                      
                      // Show signup form
                      return _buildSignupForm(context, authController, formKey);
                    }),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignupForm(
    BuildContext context,
    AuthController authController,
    GlobalKey<FormState> formKey,
  ) {
    return Form(
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
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),

          // Form fields
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: authController.signupEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Email',
                ),
                validator: authController.validateEmail,
                onChanged: (_) {
                  if (formKey.currentState != null) {
                    formKey.currentState!.validate();
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: authController.signupPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Create password',
                  hintText: 'Create password',
                ),
                validator: (value) => authController.validatePassword(
                  value,
                  isSignup: true,
                ),
                onChanged: (_) {
                  if (formKey.currentState != null) {
                    formKey.currentState!.validate();
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: authController.signupConfirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Re-enter password',
                  hintText: 'Re-enter password',
                ),
                validator: (value) => authController.validateConfirmPassword(value),
                onChanged: (_) {
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
              Obx(() {
                // Access reactive variables to trigger rebuild
                final email = authController.signupEmail.trim();
                final password = authController.signupPassword;
                final confirmPassword = authController.signupConfirmPassword;
                
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
              }),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVerificationUI(
    BuildContext context,
    AuthController authController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset verification state and go back
            authController.signOut();
          },
          color: AppColors.foreground.withOpacity(0.7),
        ),
        const SizedBox(height: 32),

        // Icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.email_outlined,
              size: 50,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Center(
          child: Text(
            'Verify your email',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 12),

        // Description
        Center(
          child: Text(
            'We\'ve sent a verification link to',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 8),

        // Email
        Center(
          child: Text(
            authController.user?.email ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next Steps',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInstructionStep('1', 'Check your email inbox'),
              const SizedBox(height: 8),
              _buildInstructionStep('2', 'Click the verification link'),
              const SizedBox(height: 8),
              _buildInstructionStep('3', 'Come back and tap "Check Verification"'),
            ],
          ),
        ),

        const Spacer(),

        // Check Verification Button
        Obx(() {
          return LoamButton(
            text: authController.isCheckingVerification
                ? 'Checking...'
                : 'Check Verification',
            onPressed: authController.isCheckingVerification
                ? null
                : () => authController.checkEmailVerification(),
            isLoading: authController.isCheckingVerification,
          );
        }),

        const SizedBox(height: 12),

        // Resend Email Button
        Obx(() {
          final cooldown = authController.resendCooldown;
          final isDisabled = cooldown > 0;
          
          return OutlinedButton(
            onPressed: isDisabled ? null : () => authController.resendVerificationEmail(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isDisabled
                  ? 'Resend in $cooldown seconds'
                  : 'Resend verification email',
              style: TextStyle(
                color: isDisabled ? AppColors.mutedForeground : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Back to Login
        Center(
          child: TextButton(
            onPressed: () {
              authController.signOut();
            },
            child: Text(
              'Cancel and go back',
              style: TextStyle(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
