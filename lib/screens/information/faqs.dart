import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_box/config.dart';
import 'dart:convert';

import '../../widgets/app_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'FAQs'),
          Expanded(
            child: ScrollToTopWrapper(
              scrollController: _scrollController,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _faqItems = fetchFAQs();
                  });
                },
                color: AppColors.primary,
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
                            const SizedBox(height: 32),
                            FutureBuilder<List<FAQItemData>>(
                              future: _faqItems,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return _buildErrorState(snapshot.error.toString());
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return _buildEmptyState();
                                } else {
                                  return Column(
                                    children: snapshot.data!.asMap().entries.map((entry) {
                                      return SlideInWidget(
                                        delay: Duration(milliseconds: 100 + (entry.key * 50)),
                                        child: FAQItem(
                                          question: entry.value.question,
                                          answer: entry.value.answer,
                                          index: entry.key + 1,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }
                              },
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
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.help_outline, color: AppColors.primary, size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Frequently Asked Questions',
          style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Find answers to common questions about MultiBox',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading FAQs',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.question_answer_outlined, color: AppColors.textLight, size: 48),
          const SizedBox(height: 16),
          Text(
            'No FAQs available',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.textLight),
          ),
        ],
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
  final int index;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    required this.index,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
        border: _expanded ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        widget.index.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.answer,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textSecondary),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
