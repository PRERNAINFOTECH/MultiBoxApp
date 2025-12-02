import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_widget.dart';

class ProductsDetailScreen extends StatefulWidget {
  final String productName;

  const ProductsDetailScreen({super.key, required this.productName});

  @override
  State<ProductsDetailScreen> createState() => _ProductsDetailScreenState();
}

class _ProductsDetailScreenState extends State<ProductsDetailScreen> {
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
    if (authToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Auth token missing'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() => _loading = false);
      return;
    }

    final respAll = await http.get(
      Uri.parse('$baseUrl/corrugation/products/'),
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product not found!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() => _loading = false);
        return;
      }
    }

    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/products/$productPk/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      product = body['product'];
      partitions = (body['partitions'] as List)
          .map<Map<String, dynamic>>((p) => Map<String, dynamic>.from(p))
          .toList();
      setState(() => _loading = false);
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _archiveProduct() async {
    final authToken = await _getToken();
    if (authToken == null || productPk == null) return;
    final resp = await http.delete(
      Uri.parse('$baseUrl/corrugation/products/$productPk/archive/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product archived!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to archive!'),
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
                            child: _buildProductCard(),
                          ),
                          const SizedBox(height: 16),
                          if (partitions.isNotEmpty) ...[
                            FadeInWidget(
                              delay: const Duration(milliseconds: 150),
                              child: _buildSectionHeader('Partitions'),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(partitions.length, (index) {
                              return SlideInWidget(
                                delay: Duration(milliseconds: 200 + (index * 100)),
                                child: _buildPartitionCard(partitions[index], index),
                              );
                            }),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleInWidget(
        delay: const Duration(milliseconds: 400),
        child: FloatingActionButton(
          onPressed: () => _showPartitionDialog(),
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
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
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product?['product_name'] ?? '',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (product?['box_no'] != null && product!['box_no'].toString().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Code: ${product!['box_no']}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: AppColors.primary,
                      onTap: _editProductDialog,
                    ),
                    _buildActionButton(
                      icon: Icons.archive,
                      label: 'Archive',
                      color: AppColors.error,
                      onTap: () => _showDeleteConfirmationDialog('product', _archiveProduct),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartitionCard(Map<String, dynamic> partition, int index) {
    final colors = [AppColors.accent, AppColors.success, AppColors.warning, AppColors.primary];
    final color = colors[index % colors.length];

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
              color: color.withValues(alpha: 0.1),
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
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.grid_view, color: color, size: 18),
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
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPartitionDialog(initialData: partition),
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.primary,
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmationDialog('partition', () => _deletePartition(partition['pk'])),
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.error,
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

  Future<void> _deletePartition(int? pk) async {
    if (pk == null) return;
    final authToken = await _getToken();
    if (authToken == null) return;

    final resp = await http.delete(
      Uri.parse('$baseUrl/corrugation/partitions/$pk/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (!mounted) return;
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Partition deleted!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      await _fetchProduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete partition!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _editProductDialog() async {
    final Map<String, TextEditingController> ctrls = {};
    for (var entry in product!.entries) {
      if (entry.key == 'pk') continue;
      ctrls[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Product',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: ctrls.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: e.value,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            labelText: e.key.replaceAll('_', ' ').toUpperCase(),
                            labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveProductEdit(dialogContext, ctrls),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProductEdit(BuildContext dialogContext, Map<String, TextEditingController> ctrls) async {
    final authToken = await _getToken();
    if (authToken == null || productPk == null) return;

    final updated = {for (var e in ctrls.entries) e.key: e.value.text.trim()};
    final resp = await http.patch(
      Uri.parse('$baseUrl/corrugation/products/$productPk/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: jsonEncode(updated),
    );

    if (!dialogContext.mounted) return;
    if (resp.statusCode == 200) {
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product updated!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      await _fetchProduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Update failed!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _showPartitionDialog({Map<String, dynamic>? initialData}) async {
    final isEdit = initialData != null;

    final partitionTypeOptions = [
      {'label': 'Vertical', 'value': 'vertical'},
      {'label': 'Horizontal', 'value': 'horizontal'},
      {'label': 'Z-Type', 'value': 'z-type'},
      {'label': 'Criss-Cross', 'value': 'crisscross'},
      {'label': 'C-Type', 'value': 'c-type'},
    ];
    final plyNoOptions = [
      {'label': '3 Ply', 'value': '3'},
      {'label': '5 Ply', 'value': '5'},
      {'label': '7 Ply', 'value': '7'},
    ];

    final partitionSizeCtrl = TextEditingController(text: initialData?['partition_size'] ?? '');
    final partitionOdCtrl = TextEditingController(text: initialData?['partition_od'] ?? '');
    final deckleCutCtrl = TextEditingController(text: initialData?['deckle_cut'] ?? '');
    final lengthCutCtrl = TextEditingController(text: initialData?['length_cut'] ?? '');
    final partitionWeightCtrl = TextEditingController(text: initialData?['partition_weight'] ?? '');
    final gsmCtrl = TextEditingController(text: initialData?['gsm'] ?? '');
    final bfCtrl = TextEditingController(text: initialData?['bf'] ?? '');

    String partitionTypeValue = initialData?['partition_type'] ?? 'vertical';
    String plyNoValue = initialData?['ply_no'] ?? '3';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600, maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: isEdit ? AppColors.accentGradient : AppColors.headerGradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? 'Edit Partition' : 'Add Partition',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildDialogTextField(partitionSizeCtrl, 'Partition Size'),
                            _buildDialogTextField(partitionOdCtrl, 'Partition OD'),
                            _buildDialogTextField(deckleCutCtrl, 'Deckle Cut'),
                            _buildDialogTextField(lengthCutCtrl, 'Length Cut'),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DropdownButtonFormField<String>(
                                value: partitionTypeValue,
                                items: partitionTypeOptions
                                    .map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => partitionTypeValue = val);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Partition Type',
                                  labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DropdownButtonFormField<String>(
                                value: plyNoValue,
                                items: plyNoOptions
                                    .map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => plyNoValue = val);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Ply Number',
                                  labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            _buildDialogTextField(partitionWeightCtrl, 'Partition Weight'),
                            _buildDialogTextField(gsmCtrl, 'Ply GSM'),
                            _buildDialogTextField(bfCtrl, 'Ply BF'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.divider)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: BorderSide(color: AppColors.divider),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _savePartition(
                                dialogContext,
                                isEdit,
                                initialData?['pk'],
                                partitionSizeCtrl,
                                partitionOdCtrl,
                                deckleCutCtrl,
                                lengthCutCtrl,
                                partitionTypeValue,
                                plyNoValue,
                                partitionWeightCtrl,
                                gsmCtrl,
                                bfCtrl,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEdit ? AppColors.accent : AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(isEdit ? 'Update' : 'Add Partition'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _savePartition(
    BuildContext dialogContext,
    bool isEdit,
    int? pk,
    TextEditingController partitionSizeCtrl,
    TextEditingController partitionOdCtrl,
    TextEditingController deckleCutCtrl,
    TextEditingController lengthCutCtrl,
    String partitionTypeValue,
    String plyNoValue,
    TextEditingController partitionWeightCtrl,
    TextEditingController gsmCtrl,
    TextEditingController bfCtrl,
  ) async {
    final authToken = await _getToken();
    if (authToken == null || productPk == null) return;

    if (isEdit && pk != null) {
      final resp = await http.patch(
        Uri.parse('$baseUrl/corrugation/partitions/$pk/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: jsonEncode({
          'partition_size': partitionSizeCtrl.text.trim(),
          'partition_od': partitionOdCtrl.text.trim(),
          'deckle_cut': deckleCutCtrl.text.trim(),
          'length_cut': lengthCutCtrl.text.trim(),
          'partition_type': partitionTypeValue,
          'ply_no': plyNoValue,
          'partition_weight': partitionWeightCtrl.text.trim(),
          'gsm': gsmCtrl.text.trim(),
          'bf': bfCtrl.text.trim(),
        }),
      );

      if (!dialogContext.mounted) return;
      if (resp.statusCode == 200) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Partition updated!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        await _fetchProduct();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Update failed!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      final postBody = {
        'product_id': productPk,
        'new_partition_size': partitionSizeCtrl.text.trim(),
        'new_partition_od': partitionOdCtrl.text.trim(),
        'new_deckle_cut': deckleCutCtrl.text.trim(),
        'new_length_cut': lengthCutCtrl.text.trim(),
        'new_partition_type': partitionTypeValue,
        'new_ply_no': plyNoValue,
        'new_partition_weight': partitionWeightCtrl.text.trim(),
        'new_gsm': gsmCtrl.text.trim(),
        'new_bf': bfCtrl.text.trim(),
      };

      final resp = await http.post(
        Uri.parse('$baseUrl/corrugation/partitions/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: jsonEncode(postBody),
      );

      if (!dialogContext.mounted) return;
      if (resp.statusCode == 201) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Partition added!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        await _fetchProduct();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Add failed!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(String itemType, VoidCallback onConfirm) async {
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
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              itemType == 'product' ? 'Archive Product' : 'Delete Partition',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          itemType == 'product'
              ? 'Are you sure you want to archive this product? You can restore it later from the archive.'
              : 'Are you sure you want to delete this partition? This action cannot be undone.',
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
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(itemType == 'product' ? 'Archive' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
