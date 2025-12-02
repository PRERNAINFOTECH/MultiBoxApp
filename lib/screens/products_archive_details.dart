import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_widget.dart';
import '../screens/products_archive.dart';

class ProductsArchiveDetailScreen extends StatefulWidget {
  final String productName;

  const ProductsArchiveDetailScreen({super.key, required this.productName});

  @override
  State<ProductsArchiveDetailScreen> createState() => _ProductsArchiveDetailScreenState();
}

class _ProductsArchiveDetailScreenState extends State<ProductsArchiveDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? product;
  List<Map<String, dynamic>> partitions = [];
  int? productPk;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchProduct() async {
    setState(() => _loading = true);
    final authToken = await _getToken();
    if (authToken == null) return;

    final respAll = await http.get(
      Uri.parse('$baseUrl/corrugation/archived-products/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (respAll.statusCode == 200) {
      final productsList = jsonDecode(respAll.body)['products'] as List;
      final match = productsList.firstWhere(
        (p) => p['product_name'] == widget.productName,
        orElse: () => null,
      );
      if (match != null) {
        productPk = match['pk'];
      } else {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Archived product not found!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/archived-products/$productPk/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      product = body['product'];
      partitions = (body['partitions'] as List)
          .map<Map<String, dynamic>>((p) => Map<String, dynamic>.from(p))
          .toList();
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _restoreProduct() async {
    final authToken = await _getToken();
    if (authToken == null || productPk == null) return;
    final resp = await http.post(
      Uri.parse('$baseUrl/corrugation/products/$productPk/restore/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (!mounted) return;
    if (resp.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProductsArchiveScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product restored!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to restore!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
          GradientAppBar(title: product?['product_name'] ?? widget.productName),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchProduct,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          FadeInWidget(
                            child: _buildArchivedBanner(),
                          ),
                          const SizedBox(height: 16),
                          FadeInWidget(
                            delay: const Duration(milliseconds: 100),
                            child: _buildProductCard(),
                          ),
                          const SizedBox(height: 16),
                          if (partitions.isNotEmpty) ...[
                            FadeInWidget(
                              delay: const Duration(milliseconds: 200),
                              child: _buildSectionHeader('Partitions'),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(partitions.length, (index) {
                              return SlideInWidget(
                                delay: Duration(milliseconds: 250 + (index * 100)),
                                child: _buildPartitionCard(partitions[index], index),
                              );
                            }),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleInWidget(
        delay: const Duration(milliseconds: 400),
        child: FloatingActionButton.extended(
          onPressed: _showRestoreConfirmationDialog,
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.restore),
          label: const Text('Restore'),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildArchivedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.archive, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archived Product',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This product is archived. Tap the restore button to bring it back.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '${partitions.length} ${partitions.length == 1 ? 'item' : 'items'}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.inventory_2, color: AppColors.warning, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?['product_name'] ?? '',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product?['box_no'] != null && product!['box_no'].toString().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Code: ${product!['box_no']}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow('Material Code', '${product?['material_code'] ?? '-'}', 'Size', '${product?['size'] ?? '-'}'),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Inner Dim (L×W×H)',
                  '${product?['inner_length'] ?? '-'}×${product?['inner_breadth'] ?? '-'}×${product?['inner_depth'] ?? '-'}',
                  'Outer Dim (L×W×H)',
                  '${product?['outer_length'] ?? '-'}×${product?['outer_breadth'] ?? '-'}×${product?['outer_depth'] ?? '-'}',
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Color', '${product?['color'] ?? '-'}', 'Weight', '${product?['weight'] ?? '-'}'),
                const SizedBox(height: 16),
                _buildDetailRow('Ply', '${product?['ply'] ?? '-'}', 'CS', '${product?['cs'] ?? '-'}'),
                const SizedBox(height: 16),
                _buildDetailRow('GSM', '${product?['gsm'] ?? '-'}', 'BF', '${product?['bf'] ?? '-'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartitionCard(Map<String, dynamic> partition, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.grid_view, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partition ${index + 1}',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        partition['partition_type']?.toString().toUpperCase() ?? 'N/A',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPartitionDetailRow('Size', '${partition['partition_size'] ?? '-'}', 'OD', '${partition['partition_od'] ?? '-'}'),
                const SizedBox(height: 12),
                _buildPartitionDetailRow('Deckle Cut', '${partition['deckle_cut'] ?? '-'}', 'Length Cut', '${partition['length_cut'] ?? '-'}'),
                const SizedBox(height: 12),
                _buildPartitionDetailRow('Ply No.', '${partition['ply_no'] ?? '-'}', 'Weight', '${partition['partition_weight'] ?? '-'}'),
                const SizedBox(height: 12),
                _buildPartitionDetailRow('GSM', '${partition['gsm'] ?? '-'}', 'BF', '${partition['bf'] ?? '-'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartitionDetailRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                '$label1: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value1,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label2: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value2,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showRestoreConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restore, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Restore Product',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to restore this product? It will be moved back to your active products.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreProduct();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
