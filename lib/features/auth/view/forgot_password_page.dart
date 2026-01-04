import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loam_button.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset password',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the email associated with your account and we\'ll send an email with instructions to reset your password.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Email',
                  ),
                  validator: authController.validateEmail,
                ),
                const SizedBox(height: 24),
                Obx(
                  () => LoamButton(
                    text: authController.isLoading
                        ? 'Sending instructions...'
                        : 'Send Instructions',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        authController.sendPasswordResetEmail(
                          emailController.text.trim(),
                        );
                      }
                    },
                    isLoading: authController.isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
