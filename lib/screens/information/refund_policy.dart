import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';

class RefundPolicyScreen extends StatefulWidget {
  const RefundPolicyScreen({super.key});

  @override
  State<RefundPolicyScreen> createState() => _RefundPolicyScreenState();
}

class _RefundPolicyScreenState extends State<RefundPolicyScreen> {
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
          const GradientAppBar(title: 'Refund Policy'),
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
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.receipt_long_outlined, color: AppColors.success, size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Refund Policy',
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
            "At Prerna Infotech, we aim to ensure the satisfaction of our users with the services provided by C.Box, our platform for corrugated manufacturers. This Refund Policy explains the conditions under which refunds may be issued and the procedures for requesting them. By using C.Box, you agree to the terms of this Refund Policy.",
          ),
          _sectionHeading("1. Eligibility for Refunds", Icons.check_circle_outline, AppColors.success),
          _bulletList([
            "If a request for a refund is made within 7 days of the original transaction.",
            "If the user experiences a technical issue with the C.Box platform that cannot be resolved within a reasonable time frame.",
            "If the C.Box service is discontinued or is unavailable for an extended period beyond what is reasonable.",
          ]),
          _sectionHeading("2. Non-Refundable Situations", Icons.cancel_outlined, AppColors.error),
          _bulletList([
            "Failure to use the platform or services as intended due to user error or lack of knowledge.",
            "Delays caused by the customer in providing necessary inputs, information, or approvals.",
            "If the customer has already downloaded or accessed substantial portions of the product or service.",
            "If the customer fails to meet the eligibility criteria specified in this policy.",
          ]),
          _sectionHeading("3. Process for Requesting Refunds", Icons.description_outlined, AppColors.info),
          _bulletList([
            "Contact our customer support team at admin@prernainfotech.in within 7 days of the transaction.",
            "Provide your order details, including the transaction ID, date of purchase, and the reason for the refund request.",
            "Our team will review your request and notify you of the outcome within 5-7 business days.",
          ]),
          _sectionHeading("4. Refund Approval", Icons.verified_outlined, AppColors.primary),
          _sectionContent(
            "If your refund request is approved, the amount will be credited back to your original method of payment within 3-5 business days. Please note that the time taken for the refund to appear in your account may vary depending on your bank or payment provider.",
          ),
          _sectionHeading("5. Cancellations", Icons.event_busy_outlined, AppColors.warning),
          _bulletList([
            "If the cancellation request is made within 7 days of placing the order for the C.Box service.",
            "If no significant portion of the service has been accessed, downloaded, or used by the customer.",
          ]),
          _sectionHeading("6. Issues with Products and Services", Icons.build_outlined, AppColors.textSecondary),
          _sectionContent(
            "If you encounter issues such as defects in the services provided or discrepancies in stock and inventory management, please notify us immediately. Our team will work with you to address the issue. If the issue is not resolved satisfactorily, you may be eligible for a refund or service credit.",
          ),
          _sectionHeading("7. Contact Us", Icons.email_outlined, AppColors.primary),
          _sectionContent(
            "If you have any questions or need further assistance regarding our Refund Policy, please reach out to us at admin@prernainfotech.in.",
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String heading, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
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
