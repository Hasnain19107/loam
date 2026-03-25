import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loam_button.dart';
import '../../../../data/network/remote/app_settings_service.dart';

class AccessCodePage extends StatefulWidget {
  const AccessCodePage({super.key});

  @override
  State<AccessCodePage> createState() => _AccessCodePageState();
}

class _AccessCodePageState extends State<AccessCodePage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final input = _codeController.text.trim();
    if (input.isEmpty) {
      Get.snackbar('Required', 'Please enter the access code');
      return;
    }

    if (_isValidating) return;
    setState(() => _isValidating = true);

    try {
      final appSettings = Get.find<AppSettingsService>();
      await appSettings.refreshSettings();
      if (!mounted) return;
      if (appSettings.validateAccessCode(input)) {
        final targetRoute =
            appSettings.shouldShowQuiz() ? AppRoutes.quiz : AppRoutes.signup;
        Get.offAllNamed(targetRoute);
      } else {
        setState(() => _isValidating = false);
        Get.snackbar(
          'Invalid Code',
          'The access code you entered is incorrect. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.destructive,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isValidating = false);
      Get.snackbar(
        'Error',
        'Could not validate access code. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.destructive,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.foreground,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Enter Access Code',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Please enter the access code provided to you to continue with your account setup.',
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'Enter access code',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _codeController,
                builder: (context, value, _) => LoamButton(
                  text: 'Continue',
                  isLoading: _isValidating,
                  onPressed: _isValidating || value.text.trim().isEmpty
                      ? null
                      : _handleContinue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Don't have an access code? Contact the app administrator for an invitation.",
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 14,
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
