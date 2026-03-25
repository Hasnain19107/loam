import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

/// In-app legal document viewer with demo content.
/// Navigate with: Get.toNamed(AppRoutes.terms) etc.
class LegalDocumentPage extends StatelessWidget {
  final String type;

  const LegalDocumentPage({super.key, required this.type});

  String get _title {
    switch (type) {
      case 'terms':
        return 'Terms of Service';
      case 'privacy':
        return 'Privacy Policy';
      case 'guidelines':
        return 'Community Guidelines';
      default:
        return 'Legal';
    }
  }

  String get _content {
    switch (type) {
      case 'terms':
        return _demoTerms;
      case 'privacy':
        return _demoPrivacy;
      case 'guidelines':
        return _demoGuidelines;
      default:
        return 'Content not found.';
    }
  }

  static const String _demoTerms = '''
Terms of Service (Demo)

Last updated: 2025

1. Acceptance of Terms
By accessing or using the Loam app ("Service"), you agree to be bound by these Terms of Service. If you do not agree, do not use the Service.

2. Description of Service
Loam provides a platform for curated in-person experiences and events, primarily for Christian singles and community members. We facilitate event discovery, registration, and community guidelines.

3. Eligibility
You must be at least 21 years of age to use this Service. By using the Service, you represent that you meet this requirement.

4. Account and Conduct
You are responsible for keeping your account secure and for all activity under your account. You agree to provide accurate information and to comply with our Community Guidelines. Harassment, hate speech, or inappropriate behaviour may result in suspension or termination.

5. Events and Participation
Event hosts and organisers are responsible for their events. Loam does not guarantee the quality, safety, or outcome of any event. Your participation is at your own risk.

6. Intellectual Property
The Service and its original content (excluding user content) are owned by Loam. You may not copy, modify, or distribute our materials without permission.

7. Limitation of Liability
To the fullest extent permitted by law, Loam shall not be liable for any indirect, incidental, or consequential damages arising from your use of the Service.

8. Changes
We may update these Terms from time to time. Continued use of the Service after changes constitutes acceptance of the new Terms.

9. Contact
For questions about these Terms, please contact us through the app or at support@example.com.

This is demo content. Replace with your official Terms of Service.
''';

  static const String _demoPrivacy = '''
Privacy Policy (Demo)

Last updated: 2025

1. Information We Collect
We collect information you provide directly, such as name, email, phone number, profile details, and event participation. We also collect usage data (e.g. device type, app usage) to improve the Service.

2. How We Use Your Information
We use your information to provide and improve the Service, to communicate with you about events and your account, to enforce our policies, and to comply with legal obligations.

3. Sharing of Information
We may share information with event hosts when you register for their events (e.g. name, contact as needed). We do not sell your personal data. We may share data with service providers who assist our operations, subject to confidentiality.

4. Data Retention
We retain your data for as long as your account is active or as needed to provide the Service and comply with law. You may request deletion of your account and associated data.

5. Security
We take reasonable measures to protect your data. No method of transmission or storage is 100% secure; we cannot guarantee absolute security.

6. Your Rights
Depending on your location, you may have rights to access, correct, delete, or port your data, or to object to or restrict certain processing. Contact us to exercise these rights.

7. Children
The Service is not intended for users under 21. We do not knowingly collect data from minors.

8. Changes to This Policy
We may update this Privacy Policy. We will notify you of material changes via the app or email where appropriate.

9. Contact
For privacy questions or requests, contact us at privacy@example.com.

This is demo content. Replace with your official Privacy Policy.
''';

  static const String _demoGuidelines = '''
Community Guidelines (Demo)

Last updated: 2025

Our goal is to create a respectful, safe, and genuine environment for in-person connection. Please follow these guidelines.

1. Be Respectful
Treat everyone with respect. No harassment, bullying, hate speech, or discrimination based on race, religion, gender, or any other protected characteristic.

2. Be Genuine
Use your real identity and accurate profile information. Do not impersonate others or create fake accounts.

3. Safety First
Do not share sensitive personal or financial information with strangers. Meet in public or safe spaces for events. Report any concerning behaviour.

4. Appropriate Content
Do not post or share offensive, explicit, or illegal content. Event descriptions and communications should be suitable for a general audience.

5. Event Conduct
As a host or participant, follow event rules and venue policies. Respect other attendees and staff. Loam may take action against those who disrupt events or violate these guidelines.

6. Reporting
If you see something that violates these guidelines or makes you uncomfortable, report it through the app. We will review reports and take appropriate action.

7. Consequences
Violations may result in warnings, temporary suspension, or permanent removal from the Service, depending on severity and context.

Thank you for helping keep our community safe and welcoming.

This is demo content. Replace with your official Community Guidelines.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          color: AppColors.foreground,
        ),
        title: Text(
          _title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SelectableText(
          _content,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.foreground,
          ),
        ),
      ),
    );
  }
}
