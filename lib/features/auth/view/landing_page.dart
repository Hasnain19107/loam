import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/network/remote/app_settings_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late AppSettingsService _settingsService;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Get or create the settings service
    if (Get.isRegistered<AppSettingsService>()) {
      _settingsService = Get.find<AppSettingsService>();
    } else {
      _settingsService = Get.put(AppSettingsService());
    }
    // Ensure settings are loaded
    _settingsService.initializeSettings();
  }

  Future<void> _handleGetStarted() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    try {
      await _settingsService.refreshSettings();
      if (!mounted) return;
      if (_settingsService.alphacodeRequired) {
        Get.toNamed(AppRoutes.accessCode);
      } else if (_settingsService.shouldShowQuiz()) {
        Get.toNamed(AppRoutes.quiz);
      } else {
        Get.toNamed(AppRoutes.signup);
      }
    } catch (e) {
      print('Error checking alphacode: $e');
      if (mounted) Get.toNamed(AppRoutes.signup);
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/landing-hero.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'Genuine people,\nin real life',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Curated experiences for Christians.\nMostly singles, all welcome.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                  const SizedBox(height: 48),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _settingsService.isLoading || _isNavigating
                              ? null
                              : _handleGetStarted,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _settingsService.isLoading || _isNavigating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Get started'),
                        ),
                      )),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withOpacity(0.8)),
                       backgroundColor: AppColors.background,
                      ),
                      child: const Text('I already have an account'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _LegalFooter(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white.withOpacity(0.6),
        );
    final linkStyle = baseStyle?.copyWith(
      color: Colors.white.withOpacity(0.9),
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: baseStyle,
        text: 'By signing up, you agree to the ',
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(AppRoutes.terms),
          ),
          const TextSpan(text: ', '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(AppRoutes.privacy),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Community Guidelines',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(AppRoutes.communityGuidelines),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
