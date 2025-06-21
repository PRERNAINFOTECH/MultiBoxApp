import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Terms & Conditions"),
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
                  _sectionTitle("Terms and Conditions"),
                  _sectionContent("Effective Date: 10 September, 2024"),
                  const SizedBox(height: 16),
                  _sectionContent(
                      "Welcome to Multibox (“Website”), owned and operated by PRERNA INFOTECH (referred to as \"we,\" \"us,\" or \"our\"). By accessing or using our website, you agree to comply with and be bound by these Terms and Conditions. Please read them carefully before using the site. If you do not agree to these terms, you should not use this website."),
                  const SizedBox(height: 20),

                  _sectionHeading("1. Acceptance of Terms"),
                  _sectionContent(
                      "By accessing and using our Website, you agree to abide by these Terms and Conditions and to comply with all applicable laws and regulations. These terms apply to all visitors, users, and others who access or use the Website."),

                  _sectionHeading("2. Use of the Website"),
                  _sectionBulletList([
                    "To engage in any conduct that restricts or inhibits any other user from using or enjoying the Website.",
                    "To infringe upon or violate our intellectual property rights or the intellectual property rights of others.",
                    "To transmit any unlawful, harmful, defamatory, or otherwise objectionable material.",
                    "For unauthorized commercial purposes without our prior written consent.",
                  ]),

                  _sectionHeading("3. Intellectual Property Rights"),
                  _sectionContent(
                      "All content on this Website, including but not limited to text, graphics, logos, images, and software, is the property of PRERNA INFOTECH and is protected by intellectual property laws. Unauthorized use of any content on this site is strictly prohibited."),

                  _sectionHeading("4. User Accounts"),
                  _sectionContent(
                      "If you create an account on our Website, you are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer. You agree to accept responsibility for all activities that occur under your account or password."),

                  _sectionHeading("5. Product Information"),
                  _sectionContent(
                      "We aim to provide accurate and up-to-date information on our Website regarding our corrugated box products, including pricing, availability, and specifications. However, we do not warrant that the product descriptions or other content available on the Website are error-free, complete, or current."),

                  _sectionHeading("6. Orders and Payment"),
                  _sectionContent(
                      "By placing an order on our Website, you agree to provide current, complete, and accurate purchase and account information. We reserve the right to refuse or cancel any order if fraud or unauthorized or illegal activity is suspected."),

                  _sectionHeading("7. Shipping and Delivery"),
                  _sectionContent(
                      "Plan Purchase, monthly report and database copy any of which applicable shall be delayed from either of payment gateway or your location or both which cannot be controlled by us."),

                  _sectionHeading("8. Returns and Refunds"),
                  _sectionContent(
                      "We offer returns and refunds under certain conditions. Please mail to us at admin@prernainfotech.in for more details."),

                  _sectionHeading("9. Limitation of Liability"),
                  _sectionContent(
                      "To the fullest extent permitted by law, PRERNA INFOTECH shall not be liable for any indirect, incidental, special, or consequential damages, including but not limited to loss of profits, revenue, or data, arising out of the use or inability to use the Website or plans purchased through the Website."),

                  _sectionHeading("10. Changes to the Terms and Conditions"),
                  _sectionContent(
                      "We reserve the right to modify or update these Terms and Conditions at any time. Any changes will be posted on this page with an updated \"Effective Date.\" Your continued use of the Website after any modifications constitute your acceptance of the revised Terms."),

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
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
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
                ),
              ))
          .toList(),
    );
  }
}
