import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/app_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import '../config.dart';

class PurchaseOrdersArchiveDetailScreen extends StatefulWidget {
  final String poGivenBy;
  const PurchaseOrdersArchiveDetailScreen({super.key, required this.poGivenBy});

  @override
  State<PurchaseOrdersArchiveDetailScreen> createState() => _PurchaseOrdersArchiveDetailScreenState();
}

class _PurchaseOrdersArchiveDetailScreenState extends State<PurchaseOrdersArchiveDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  List<dynamic> purchaseOrders = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPODetails();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchPODetails() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/corrugation/purchase-orders/archive/by/${Uri.encodeComponent(widget.poGivenBy)}/',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        purchaseOrders = data['purchase_orders'] ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _restorePO(int poId) async {
    final authToken = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/purchase-orders/$poId/restore/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Purchase order restored successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      _fetchPODetails();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error restoring PO: ${response.body}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  List<dynamic> get filteredPurchaseOrders {
    if (_searchQuery.isEmpty) return purchaseOrders;
    return purchaseOrders.where((po) {
      final productName = po['product_name']?.toString().toLowerCase() ?? '';
      return productName.contains(_searchQuery.toLowerCase());
    }).toList();
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
          hintText: 'Search by product name...',
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
              'These purchase orders are archived. Tap restore to bring them back.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                Icons.archive_outlined,
                color: AppColors.warning,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.poGivenBy,
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${filteredPurchaseOrders.length} Archived Order${filteredPurchaseOrders.length != 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOCard(dynamic po, int index) {
    final dispatches = (po["dispatches"] as List?) ?? [];
    
    return SlideInWidget(
      delay: Duration(milliseconds: 100 + (index * 50)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          po["product_name"]?.toString() ?? "",
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.archive_outlined, size: 12, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                po["po_date"] ?? "",
                                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRestoreButton(po["pk"]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          label: 'MATERIAL CODE',
                          value: po["material_code"]?.toString() ?? "-",
                          icon: Icons.qr_code,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          label: 'BOX CODE',
                          value: po["box_no"]?.toString() ?? "-",
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          label: 'PO NUMBER',
                          value: po["po_number"]?.toString() ?? "-",
                          icon: Icons.tag,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          label: 'RATE',
                          value: po["rate"]?.toString() ?? "-",
                          icon: Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuantityCard(
                          label: 'PO QUANTITY',
                          value: po["po_quantity"]?.toString() ?? "-",
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuantityCard(
                          label: 'QTY (+5%)',
                          value: po["po_quantity"] != null
                              ? (double.tryParse(po["po_quantity"].toString())! * 1.05).toStringAsFixed(0)
                              : "-",
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remaining',
                              style: AppTextStyles.caption,
                            ),
                            Text(
                              po["remaining_quantity"]?.toString() ?? "0",
                              style: AppTextStyles.titleLarge.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Max Remaining',
                              style: AppTextStyles.caption,
                            ),
                            Text(
                              po["max_remaining_quantity"]?.toString() ?? "0",
                              style: AppTextStyles.titleLarge.copyWith(color: AppColors.warning),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (dispatches.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 18, color: AppColors.textLight),
                        const SizedBox(width: 8),
                        Text(
                          'Dispatches (${dispatches.length})',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...dispatches.map((dispatch) => _buildDispatchItem(dispatch)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreButton(int poId) {
    return Material(
      color: AppColors.success.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _showRestoreConfirmationDialog(context, poId),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restore, size: 18, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                'Restore',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildQuantityCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchItem(dynamic dispatch) {
    final qty = dispatch["dispatch_quantity"] ?? "";
    final partitions = dispatch["partition_dispatch"] as Map<String, dynamic>? ?? {};
    final partitionStrings = partitions.values.map((v) => "(${v.toString()})").toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle, size: 18, color: AppColors.textLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qty: $qty',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                if (partitionStrings.isNotEmpty)
                  Text(
                    partitionStrings.join(' '),
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            dispatch["dispatch_date"] ?? "",
            style: AppTextStyles.caption,
          ),
        ],
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
                  ? 'No archived purchase orders found for this company'
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
          GradientAppBar(
            title: 'Archived PO Details',
            showBackButton: true,
          ),
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
                      onRefresh: _fetchPODetails,
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
                                    child: _buildCompanyHeader(),
                                  ),
                                  const SizedBox(height: 12),
                                  FadeInWidget(
                                    delay: const Duration(milliseconds: 100),
                                    child: _buildArchiveInfoBanner(),
                                  ),
                                  const SizedBox(height: 12),
                                  FadeInWidget(
                                    delay: const Duration(milliseconds: 150),
                                    child: _buildSearchBar(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filteredPurchaseOrders.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildPOCard(filteredPurchaseOrders[index], index),
                                  childCount: filteredPurchaseOrders.length,
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

  Future<void> _showRestoreConfirmationDialog(BuildContext context, int poId) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.restore, color: AppColors.success, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Restore Purchase Order?',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'This purchase order will be moved back to the active list.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.textLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _restorePO(poId);
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Restore'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
