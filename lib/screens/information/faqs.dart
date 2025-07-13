import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_box/config.dart';
import 'dart:convert';

import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<FAQItemData>> _faqItems;

  @override
  void initState() {
    super.initState();
    _faqItems = fetchFAQs();
  }

  Future<List<FAQItemData>> fetchFAQs() async {
    final response = await http.get(Uri.parse("$baseUrl/tenant/faqs"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((jsonItem) => FAQItemData(
                question: jsonItem['question'],
                answer: jsonItem['answer'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load FAQs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("FAQs"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
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
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<FAQItemData>>(
                    future: _faqItems,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error loading FAQs: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No FAQs available.');
                      } else {
                        return Column(
                          children: snapshot.data!
                              .map((faq) => FAQItem(
                                    question: faq.question,
                                    answer: faq.answer,
                                  ))
                              .toList(),
                        );
                      }
                    },
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

class FAQItemData {
  final String question;
  final String answer;

  FAQItemData({required this.question, required this.answer});
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            fontSize: 16,
            decoration: TextDecoration.underline,
          ),
        ),
        children: [
          Text(
            widget.answer,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
