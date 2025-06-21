import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Refund Policy"),
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
                  _sectionTitle("Refund Policy for Multibox"),
                  _sectionContent("Effective Date: 10 September, 2024"),
                  const SizedBox(height: 16),
                  _sectionContent(
                    "At Prerna Infotech, we aim to ensure the satisfaction of our users with the services provided by Multibox, our platform for corrugated manufacturers. This Refund Policy explains the conditions under which refunds may be issued and the procedures for requesting them. By using Multibox, you agree to the terms of this Refund Policy.",
                  ),

                  _sectionHeading("1. Eligibility for Refunds"),
                  _sectionBulletList([
                    "If a request for a refund is made within 7 days of the original transaction.",
                    "If the user experiences a technical issue with the Multibox platform that cannot be resolved within a reasonable time frame.",
                    "If the Multibox service is discontinued or is unavailable for an extended period beyond what is reasonable.",
                  ]),

                  _sectionHeading("2. Non-Refundable Situations"),
                  _sectionBulletList([
                    "Failure to use the platform or services as intended due to user error or lack of knowledge.",
                    "Delays caused by the customer in providing necessary inputs, information, or approvals.",
                    "If the customer has already downloaded or accessed substantial portions of the product or service.",
                    "If the customer fails to meet the eligibility criteria specified in this policy.",
                  ]),

                  _sectionHeading("3. Process for Requesting Refunds"),
                  _sectionBulletList([
                    "Contact our customer support team at admin@prernainfotech.in within 7 days of the transaction.",
                    "Provide your order details, including the transaction ID, date of purchase, and the reason for the refund request.",
                    "Our team will review your request and notify you of the outcome within 5–7 business days.",
                  ]),

                  _sectionHeading("4. Refund Approval"),
                  _sectionContent(
                    "If your refund request is approved, the amount will be credited back to your original method of payment within 3–5 business days. Please note that the time taken for the refund to appear in your account may vary depending on your bank or payment provider.",
                  ),

                  _sectionHeading("5. Cancellations"),
                  _sectionBulletList([
                    "If the cancellation request is made within 7 days of placing the order for the Multibox service.",
                    "If no significant portion of the service has been accessed, downloaded, or used by the customer.",
                  ]),

                  _sectionHeading("6. Issues with Products and Services"),
                  _sectionContent(
                    "If you encounter issues such as defects in the services provided or discrepancies in stock and inventory management, please notify us immediately. Our team will work with you to address the issue. If the issue is not resolved satisfactorily, you may be eligible for a refund or service credit.",
                  ),

                  _sectionHeading("7. Contact Us"),
                  _sectionContent(
                    "If you have any questions or need further assistance regarding our Refund Policy, please reach out to us at admin@prernainfotech.in.",
                  ),

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
