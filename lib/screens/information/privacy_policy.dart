import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Privacy Policy'),
          Expanded(
            child: ScrollToTopWrapper(
              scrollController: _scrollController,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          FadeInWidget(child: _buildHeader()),
                          const SizedBox(height: 24),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 100),
                            child: _buildPolicySection(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.privacy_tip_outlined, color: AppColors.info, size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Privacy Policy',
          style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Effective Date: 10 September, 2024',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionContent(
            "At C.Box, accessible from www.multibox.co.in, we prioritize the privacy and security of our users' information. This Privacy Policy outlines how we collect, use, and protect your data when you use our website and services. By accessing or using C.Box, you agree to the terms of this Privacy Policy.",
          ),
          _sectionHeading("1. Information We Collect"),
          _sectionSubheading("a) Personal Information"),
          _bulletList([
            "Name",
            "Email address",
            "Contact information (e.g., phone number)",
            "Any other information you provide during the sign-up process",
          ]),
          _sectionSubheading("b) Product and Stock Data"),
          _sectionContent(
            "As part of providing our stock and product management services, we collect and store data related to the products, inventory, and stock levels that you manage using the C.Box platform.",
          ),
          _sectionHeading("2. How We Use Your Information"),
          _bulletList([
            "To provide and maintain the C.Box service",
            "To process transactions and manage billing",
            "To communicate with you, including sending updates and notifications",
            "To improve our website and services based on user feedback",
            "To offer personalized content and recommendations",
            "To ensure data security and prevent fraud",
            "To comply with legal obligations",
          ]),
          _sectionHeading("3. How We Protect Your Information"),
          _bulletList([
            "Secure access control and password protection",
            "Regular security audits and vulnerability assessments",
            "Data backup and disaster recovery plans",
          ]),
          _sectionHeading("4. Sharing of Your Information"),
          _sectionContent(
            "We do not sell, trade, or rent your personal information to third parties. We may share your data in the following situations:",
          ),
          _bulletList([
            "When required by law, to comply with legal obligations or respond to lawful requests from government authorities",
            "To protect our legal rights, property, or safety",
          ]),
          _sectionHeading("5. Your Rights"),
          _bulletList([
            "Access: You can request a copy of the personal data we hold about you.",
            "Rectification: You can request corrections to inaccurate or incomplete data.",
            "Deletion: You can request the deletion of your data under certain conditions.",
            "Restriction: You can request the restriction of processing your data.",
            "Portability: You can request your data in a structured, commonly used format.",
          ]),
          _sectionContent("To exercise any of these rights, please contact us at admin@prernainfotech.in."),
          _sectionHeading("6. Cookies and Tracking Technologies"),
          _sectionContent(
            "We use cookies and similar tracking technologies to enhance your experience on our website. Cookies are small text files stored on your device that help us recognize you when you return to the site.",
          ),
          _sectionContent(
            "You can control or delete cookies through your browser settings. However, please note that disabling cookies may affect your ability to use certain features of the C.Box service.",
          ),
          _sectionHeading("7. Data Retention"),
          _sectionContent(
            "We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.",
          ),
          _sectionHeading("8. Changes to This Privacy Policy"),
          _sectionContent(
            "We may update this Privacy Policy from time to time. Any changes will be posted on this page, and the \"Effective Date\" at the top of the policy will be updated. We encourage you to review this policy periodically to stay informed about how we protect your data.",
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String heading) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              heading,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionSubheading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        content,
        style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textSecondary),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
