import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loam_button.dart';
import '../controller/auth_controller.dart';

/// Mandatory page for new users after sign-up (Apple, Google, or Email).
/// They must agree before proceeding to phone number and rest of onboarding.
class CommunityAgreementPage extends StatefulWidget {
  const CommunityAgreementPage({super.key});

  @override
  State<CommunityAgreementPage> createState() => _CommunityAgreementPageState();
}

class _CommunityAgreementPageState extends State<CommunityAgreementPage> {
  bool _agreed = false;

  static const String _agreementText = '''
Community Agreement

By joining Loam, you agree to:

• Be respectful and treat everyone with dignity. No harassment, bullying, hate speech, or discrimination.

• Use your real identity and accurate profile information. Do not impersonate others or create fake accounts.

• Prioritise safety: do not share sensitive personal or financial information with strangers. Meet in public or safe spaces. Report concerning behaviour.

• Keep content and communications appropriate and suitable for a general audience.

• Follow event rules and venue policies as a host or participant. Respect other attendees and staff.

• Report anything that violates these guidelines or makes you uncomfortable. We will review and take action.

Violations may result in warnings, temporary suspension, or permanent removal from the service.

Thank you for helping keep our community safe and welcoming.
''';

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Community Agreement',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please read and accept before continuing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _agreementText,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                value: _agreed,
                onChanged: (value) => setState(() => _agreed = value ?? false),
                title: Text(
                  'I agree to the Community Agreement',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.foreground,
                      ),
                ),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              Obx(
                () => LoamButton(
                  text: 'Continue',
                  onPressed: _agreed && !authController.isLoading
                      ? () => authController.acceptCommunityAgreementAndContinue()
                      : null,
                  isLoading: authController.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
