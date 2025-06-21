import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("About Us"),
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
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle("About Us"),
                  _sectionContent(
                    "Multibox is a Software as a Service (SaaS) platform that provides the best automated software for corrugated manufacturers to manage their stocks, products, production line, and much more. This includes reels inventory management with reel stock and summaries to easily organize their materials and products. Manufacturers can focus on their unit while the handling is done by the app, saving time and money.",
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle("Our Mission"),
                  _sectionContent(
                    "Our mission at Multibox is to provide the best automated software as a service for as many corrugation manufacturers as possible. We aim to empower manufacturers to streamline their operations, reduce costs, and increase efficiency by providing them with the services they need to succeed. We are committed to helping our clients achieve their goals by giving them software that is easy to use, reliable, and cost-effective.",
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle("Our Vision"),
                  _sectionContent(
                    "Our vision at Multibox is to become the leading provider of automated software for corrugation manufacturers. We aim to be the go-to solution for manufacturers looking to streamline their operations, reduce costs, and increase efficiency. We are committed to providing our clients with the best possible service and support, and to helping them achieve their goals by giving them the tools they need to succeed.",
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle("Our Operational Address"),
                  _sectionContent(
                    "Prerna Infotech\n\n"
                    "1166/A, 'PRERNA',\n"
                    "Sir Pattani Road,\n"
                    "Opp. HCG Hospital,\n"
                    "Bhavnagar - 364001",
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A68F2),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
