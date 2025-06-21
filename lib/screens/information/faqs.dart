import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("FAQs"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Frequently Asked Questions (FAQ)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const FAQItem(
                    question: "What are the features of Stock Tab on left panel?",
                    answer:
                        "Stock Tab on left panel displays all stocks of each product including Box stock and Partition stock if applied, as well as it also shows the history of the stock that is dispatched to different buyers. Besides this, the Add stock, Edit stock and Delete stock features are available to manage your Products stock.",
                  ),
                  const SizedBox(height: 8),
                  const FAQItem(
                    question: "What are the features of Paper Reels Tab on left panel?",
                    answer:
                        "Paper Reels Tab manages the raw paper material stock. It includes details like reel type, weight, GSM, supplier, and helps track usage in production. Add, edit, and view consumption history in this section for accurate inventory control.",
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expanded = expanded;
          });
        },
        title: Text(
          widget.question,
          style: const TextStyle(
            color: Color(0xFF4A68F2),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
        children: [
          Text(
            widget.answer,
            style: const TextStyle(fontSize: 15, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
