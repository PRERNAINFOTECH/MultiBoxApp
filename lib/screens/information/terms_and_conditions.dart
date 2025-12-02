import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
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
          const GradientAppBar(title: 'Terms & Conditions'),
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
                            child: _buildTermsSection(),
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
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.gavel_outlined, color: AppColors.warning, size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Terms and Conditions',
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

  Widget _buildTermsSection() {
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
            "Welcome to Multibox (\"Website\"), owned and operated by PRERNA INFOTECH (referred to as \"we,\" \"us,\" or \"our\"). By accessing or using our website, you agree to comply with and be bound by these Terms and Conditions. Please read them carefully before using the site. If you do not agree to these terms, you should not use this website.",
          ),
          _sectionHeading("1. Acceptance of Terms"),
          _sectionContent(
            "By accessing and using our Website, you agree to abide by these Terms and Conditions and to comply with all applicable laws and regulations. These terms apply to all visitors, users, and others who access or use the Website.",
          ),
          _sectionHeading("2. Use of the Website"),
          _sectionContent("You agree not to use the Website:"),
          _bulletList([
            "To engage in any conduct that restricts or inhibits any other user from using or enjoying the Website.",
            "To infringe upon or violate our intellectual property rights or the intellectual property rights of others.",
            "To transmit any unlawful, harmful, defamatory, or otherwise objectionable material.",
            "For unauthorized commercial purposes without our prior written consent.",
          ]),
          _sectionHeading("3. Intellectual Property Rights"),
          _sectionContent(
            "All content on this Website, including but not limited to text, graphics, logos, images, and software, is the property of PRERNA INFOTECH and is protected by intellectual property laws. Unauthorized use of any content on this site is strictly prohibited.",
          ),
          _sectionHeading("4. User Accounts"),
          _sectionContent(
            "If you create an account on our Website, you are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer. You agree to accept responsibility for all activities that occur under your account or password.",
          ),
          _sectionHeading("5. Product Information"),
          _sectionContent(
            "We aim to provide accurate and up-to-date information on our Website regarding our corrugated box products, including pricing, availability, and specifications. However, we do not warrant that the product descriptions or other content available on the Website are error-free, complete, or current.",
          ),
          _sectionHeading("6. Orders and Payment"),
          _sectionContent(
            "By placing an order on our Website, you agree to provide current, complete, and accurate purchase and account information. We reserve the right to refuse or cancel any order if fraud or unauthorized or illegal activity is suspected.",
          ),
          _sectionHeading("7. Shipping and Delivery"),
          _sectionContent(
            "Plan Purchase, monthly report and database copy any of which applicable shall be delayed from either of payment gateway or your location or both which cannot be controlled by us.",
          ),
          _sectionHeading("8. Returns and Refunds"),
          _sectionContent(
            "We offer returns and refunds under certain conditions. Please mail to us at admin@prernainfotech.in for more details.",
          ),
          _sectionHeading("9. Limitation of Liability"),
          _sectionContent(
            "To the fullest extent permitted by law, PRERNA INFOTECH shall not be liable for any indirect, incidental, special, or consequential damages, including but not limited to loss of profits, revenue, or data, arising out of the use or inability to use the Website or plans purchased through the Website.",
          ),
          _sectionHeading("10. Changes to the Terms and Conditions"),
          _sectionContent(
            "We reserve the right to modify or update these Terms and Conditions at any time. Any changes will be posted on this page with an updated \"Effective Date.\" Your continued use of the Website after any modifications constitute your acceptance of the revised Terms.",
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
              color: AppColors.warning,
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
                        color: AppColors.warning,
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
