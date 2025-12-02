import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/app_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../screens/purchaseorders_archive_detail.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import '../config.dart';

class PurchaseOrdersArchiveScreen extends StatefulWidget {
  const PurchaseOrdersArchiveScreen({super.key});

  @override
  State<PurchaseOrdersArchiveScreen> createState() => _PurchaseOrdersArchiveScreenState();
}

class _PurchaseOrdersArchiveScreenState extends State<PurchaseOrdersArchiveScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  List<String> companies = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchArchivedCompanies();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchArchivedCompanies() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/purchase-orders/archive/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        companies = List<String>.from(data['purchase_order_list'] ?? []);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  List<String> get filteredCompanies {
    if (_searchQuery.isEmpty) return companies;
    return companies.where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.small,
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search archived companies...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(Icons.search, color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildArchiveInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.archive_outlined,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These purchase orders have been archived. Tap to view details and restore if needed.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, String name, int index) {
    return SlideInWidget(
      delay: Duration(milliseconds: 100 + (index * 50)),
      child: AnimatedCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseOrdersArchiveDetailScreen(poGivenBy: name),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.archive_outlined,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.archive_outlined, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Archived',
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.archive_outlined,
                size: 40,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty ? 'No Archived Orders' : 'No Results Found',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Archived purchase orders will appear here'
                  : 'Try adjusting your search terms',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
          const GradientAppBar(title: 'Archived POs'),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : ScrollToTopWrapper(
                    scrollController: _scrollController,
                    child: RefreshIndicator(
                      onRefresh: _fetchArchivedCompanies,
                      color: AppColors.primary,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  FadeInWidget(
                                    child: _buildSearchBar(),
                                  ),
                                  const SizedBox(height: 12),
                                  FadeInWidget(
                                    delay: const Duration(milliseconds: 100),
                                    child: _buildArchiveInfoBanner(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filteredCompanies.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildCompanyCard(context, filteredCompanies[index], index),
                                  childCount: filteredCompanies.length,
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 24),
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
}
