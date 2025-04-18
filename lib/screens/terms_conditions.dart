import 'package:drip_tok/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgdark,
        title: const Text(
          'Terms of Use',
          style: TextStyle(color: Colors.white),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bglight, AppColors.bgdark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: const Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DripTock - Terms of Use',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Effective Date: March 20, 2025\n\n'
                  '1. Acceptance of Terms\n\n'
                  'By accessing and using DripTock, you confirm that you have read, understood, and agreed to these '
                  'Terms of Use, as well as our Privacy Policy. If you do not agree, please do not use the app.\n\n'
                  '2. User Agreement (EULA)\n\n'
                  'Users must agree to our End User License Agreement (EULA) before using DripTock. There is zero '
                  'tolerance for objectionable content, abusive behavior, or violations of these terms. By creating an '
                  'account, users acknowledge that any violations may result in suspension or removal from the '
                  'platform.\n\n'
                  '3. Prohibited Content & Behavior\n\n'
                  'Users must not post, upload, share, or distribute content that includes but is not limited to:\n'
                  '- Hate speech, threats, or harassment\n'
                  '- Nudity, pornography, or sexually explicit material\n'
                  '- Violence or promotion of self-harm\n'
                  '- False, misleading, or fraudulent information\n'
                  '- Spam, scams, or deceptive practices\n\n'
                  'DripTock reserves the right to remove any content that violates these guidelines without notice.\n\n'
                  '4. Content Moderation & Reporting\n\n'
                  'To ensure a safe and respectful community, DripTock has implemented the following measures:\n'
                  '- Filtering System: We use automated and manual moderation tools to detect and filter objectionable content.\n'
                  '- User Reporting: Users can report content that they find inappropriate.\n'
                  '- Blocking Mechanism: Users can block other users to prevent further interactions.\n'
                  '- Response to Reports: Our moderation team will review and act on reported content within 24 hours. '
                  'Content found in violation will be removed, and repeat offenders may be banned.\n\n'
                  '5. Account Termination & Enforcement\n\n'
                  'DripTock reserves the right to terminate accounts that:\n'
                  '- Repeatedly violate content guidelines\n'
                  '- Engage in abusive or harmful behavior\n'
                  '- Fail to comply with our Terms of Use\n\n'
                  '6. Liability Disclaimer\n\n'
                  'DripTock is not responsible for user-generated content but will take appropriate action when content '
                  'is reported. Users are responsible for their own actions within the app.\n\n'
                  '7. Updates & Changes\n\n'
                  'DripTock may update these Terms of Use at any time. Users will be notified of major changes and '
                  'must review the terms regularly to continue using the app.\n\n'
                  '8. Contact Information\n\n'
                  'For any questions or concerns regarding these Terms of Use, please contact us at:\n'
                  'Email: info@driptock.com\n\n'
                  'By using DripTock, you agree to comply with these terms and help us maintain a safe and positive '
                  'community. Thank you for being a part of DripTock.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
