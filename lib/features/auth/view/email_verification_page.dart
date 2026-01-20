import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loam_button.dart';
import '../controller/auth_controller.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final authController = Get.find<AuthController>();
  bool isCheckingVerification = false;
  bool isResendingEmail = false;
  Timer? _autoCheckTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification every 3 seconds
    _startAutoCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startAutoCheck() {
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification(silent: true);
    });
  }

  Future<void> _checkEmailVerification({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isCheckingVerification = true;
      });
    }

    try {
      await authController.checkEmailVerification();
      
      if (authController.isEmailVerified) {
        _autoCheckTimer?.cancel();
        
        if (!silent) {
          Get.snackbar(
            'Success',
            'Email verified successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
        
        // Proceed to onboarding or main screen
        await authController.proceedAfterEmailVerification();
      } else if (!silent) {
        Get.snackbar(
          'Not Verified',
          'Please check your email and click the verification link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.destructive,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (!silent) {
        Get.snackbar(
          'Error',
          'Failed to check verification status',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (!silent) {
        setState(() {
          isCheckingVerification = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) {
      Get.snackbar(
        'Please Wait',
        'You can resend the email in $_resendCooldown seconds',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isResendingEmail = true;
    });

    try {
      await authController.resendVerificationEmail();
      
      Get.snackbar(
        'Email Sent',
        'Verification email has been sent to ${authController.user?.email}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Start cooldown
      setState(() {
        _resendCooldown = 60;
      });

      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _resendCooldown--;
        });

        if (_resendCooldown <= 0) {
          timer.cancel();
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send verification email',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isResendingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
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
              
              const SizedBox(height: 16),
              
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
                child: Obx(() {
                  final email = authController.user?.email ?? '';
                  return Text(
                    email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
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
                    _buildInstructionStep('3', 'Return here and tap "Check Verification"'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Check Verification Button
              LoamButton(
                text: isCheckingVerification 
                    ? 'Checking...' 
                    : 'Check Verification',
                onPressed: isCheckingVerification 
                    ? null 
                    : () => _checkEmailVerification(),
                isLoading: isCheckingVerification,
              ),
              
              const SizedBox(height: 12),
              
              // Resend Email Button
              OutlinedButton(
                onPressed: isResendingEmail || _resendCooldown > 0
                    ? null
                    : _resendVerificationEmail,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isResendingEmail
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _resendCooldown > 0
                            ? 'Resend in $_resendCooldown seconds'
                            : 'Resend verification email',
                        style: TextStyle(
                          color: _resendCooldown > 0
                              ? AppColors.mutedForeground
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () {
                    authController.signOut();
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
