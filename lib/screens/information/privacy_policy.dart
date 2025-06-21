import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Privacy Policy"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle("Privacy Policy for Multibox"),
                  _sectionContent("Effective Date: 10 September, 2024"),
                  const SizedBox(height: 16),
                  _sectionContent(
                      "At Multibox, accessible from www.multibox.co.in, we prioritize the privacy and security of our users' information. This Privacy Policy outlines how we collect, use, and protect your data when you use our website and services. By accessing or using Multibox, you agree to the terms of this Privacy Policy."),
                  const SizedBox(height: 20),

                  _sectionHeading("1. Information We Collect"),
                  _sectionSubheading("a) Personal Information"),
                  _sectionBulletList([
                    "Name",
                    "Email address",
                    "Contact information (e.g., phone number)",
                    "Any other information you provide during the sign-up process",
                  ]),
                  _sectionSubheading("b) Product and Stock Data"),
                  _sectionContent(
                      "As part of providing our stock and product management services, we collect and store data related to the products, inventory, and stock levels that you manage using the Multibox platform."),

                  const SizedBox(height: 16),
                  _sectionHeading("2. How We Use Your Information"),
                  _sectionBulletList([
                    "To provide and maintain the Multibox service",
                    "To process transactions and manage billing",
                    "To communicate with you, including sending updates and notifications",
                    "To improve our website and services based on user feedback",
                    "To offer personalized content and recommendations",
                    "To ensure data security and prevent fraud",
                    "To comply with legal obligations",
                  ]),

                  const SizedBox(height: 16),
                  _sectionHeading("3. How We Protect Your Information"),
                  _sectionBulletList([
                    "Secure access control and password protection",
                    "Regular security audits and vulnerability assessments",
                    "Data backup and disaster recovery plans",
                  ]),

                  const SizedBox(height: 16),
                  _sectionHeading("4. Sharing of Your Information"),
                  _sectionContent(
                      "We do not sell, trade, or rent your personal information to third parties. We may share your data in the following situations:"),
                  _sectionBulletList([
                    "When required by law, to comply with legal obligations or respond to lawful requests from government authorities",
                    "To protect our legal rights, property, or safety",
                  ]),

                  const SizedBox(height: 16),
                  _sectionHeading("5. Your Rights"),
                  _sectionBulletList([
                    "Access: You can request a copy of the personal data we hold about you.",
                    "Rectification: You can request corrections to inaccurate or incomplete data.",
                    "Deletion: You can request the deletion of your data under certain conditions.",
                    "Restriction: You can request the restriction of processing your data.",
                    "Portability: You can request your data in a structured, commonly used format.",
                  ]),
                  _sectionContent(
                      "To exercise any of these rights, please contact us at admin@prernainfotech.in."),

                  const SizedBox(height: 16),
                  _sectionHeading("6. Cookies and Tracking Technologies"),
                  _sectionContent(
                      "We use cookies and similar tracking technologies to enhance your experience on our website. Cookies are small text files stored on your device that help us recognize you when you return to the site."),
                  _sectionContent(
                      "You can control or delete cookies through your browser settings. However, please note that disabling cookies may affect your ability to use certain features of the Multibox service."),

                  const SizedBox(height: 16),
                  _sectionHeading("7. Data Retention"),
                  _sectionContent(
                      "We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law."),

                  const SizedBox(height: 16),
                  _sectionHeading("8. Changes to This Privacy Policy"),
                  _sectionContent(
                      "We may update this Privacy Policy from time to time. Any changes will be posted on this page, and the \"Effective Date\" at the top of the policy will be updated. We encourage you to review this policy periodically to stay informed about how we protect your data."),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A68F2)),
      textAlign: TextAlign.center,
    );
  }

  Widget _sectionHeading(String heading) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        heading,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _sectionSubheading(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _sectionBulletList(List<String> items) {
    return Column(
      children: items
          .map((item) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 15)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}
