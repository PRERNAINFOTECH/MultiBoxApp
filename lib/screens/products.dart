import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_widget.dart';
import '../screens/products_detail.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  List<String> productNames = [];
  List<String> filteredProductNames = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/products/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(resp.body);
      setState(() {
        productNames = (body['products'] as List)
            .map<String>((p) => p['product_name'] as String)
            .toList();
        filteredProductNames = List.from(productNames);
        _searchController.clear();
        filteredProductNames = List.from(productNames);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProductNames = productNames
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Products'),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchProducts,
                    color: AppColors.primary,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: FadeInWidget(
                              child: _buildSearchAndAddRow(),
                            ),
                          ),
                        ),
                        if (filteredProductNames.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products found',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add a product to get started',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return SlideInWidget(
                                    delay: Duration(milliseconds: 100 + (index * 50)),
                                    child: _buildProductCard(
                                      context,
                                      filteredProductNames[index],
                                      index,
                                    ),
                                  );
                                },
                                childCount: filteredProductNames.length,
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleInWidget(
        delay: const Duration(milliseconds: 400),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddProductDialog(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildSearchAndAddRow() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterProducts,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(Icons.search, color: AppColors.textLight),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textLight),
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String name, int index) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
    ];
    final color = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsDetailScreen(productName: name),
              ),
            );
            if (result == true) {
              _fetchProducts();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'P',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
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
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view details',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final boxNoCtrl = TextEditingController();
    final materialCodeCtrl = TextEditingController();
    final sizeCtrl = TextEditingController();
    final idLCtrl = TextEditingController();
    final idWCtrl = TextEditingController();
    final idHCtrl = TextEditingController();
    final odLCtrl = TextEditingController();
    final odWCtrl = TextEditingController();
    final odHCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final plyCtrl = TextEditingController();
    final gsmCtrl = TextEditingController();
    final bfCtrl = TextEditingController();
    final csCtrl = TextEditingController();

    List<Map<String, TextEditingController>> partitions = [];

    void addPartition() {
      partitions.add({
        'partition_size': TextEditingController(),
        'partition_od': TextEditingController(),
        'deckle_cut': TextEditingController(),
        'length_cut': TextEditingController(),
        'partition_type': TextEditingController(),
        'ply_no': TextEditingController(),
        'partition_weight': TextEditingController(),
        'partition_gsm': TextEditingController(),
        'partition_bf': TextEditingController(),
      });
    }

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
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
                            'Add New Product',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogSection('Basic Information'),
                            _buildDialogTextField(nameCtrl, 'Product Name', Icons.inventory),
                            _buildDialogTextField(boxNoCtrl, 'Box Number', Icons.numbers),
                            _buildDialogTextField(materialCodeCtrl, 'Material Code', Icons.qr_code),
                            _buildDialogTextField(sizeCtrl, 'Size', Icons.straighten),
                            const SizedBox(height: 16),
                            
                            _buildDialogSection('Inner Dimensions (ID)'),
                            Row(
                              children: [
                                Expanded(child: _buildMiniTextField(idLCtrl, 'Length')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildMiniTextField(idWCtrl, 'Width')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildMiniTextField(idHCtrl, 'Height')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildDialogSection('Outer Dimensions (OD)'),
                            Row(
                              children: [
                                Expanded(child: _buildMiniTextField(odLCtrl, 'Length')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildMiniTextField(odWCtrl, 'Width')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildMiniTextField(odHCtrl, 'Height')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildDialogSection('Specifications'),
                            Row(
                              children: [
                                Expanded(child: _buildMiniTextField(colorCtrl, 'Color')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildMiniTextField(weightCtrl, 'Weight')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildMiniTextField(plyCtrl, 'Ply')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildMiniTextField(gsmCtrl, 'GSM')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildMiniTextField(bfCtrl, 'BF')),
                                const SizedBox(width: 8),
                                Expanded(child: _buildMiniTextField(csCtrl, 'CS')),
                              ],
                            ),
                            
                            if (partitions.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              ...List.generate(partitions.length, (index) {
                                final part = partitions[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Partition ${index + 1}',
                                            style: AppTextStyles.titleSmall.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                partitions.removeAt(index);
                                              });
                                            },
                                            icon: const Icon(Icons.remove_circle, color: AppColors.error),
                                            iconSize: 20,
                                          ),
                                        ],
                                      ),
                                      _buildMiniTextField(part['partition_size']!, 'Size'),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(child: _buildMiniTextField(part['partition_od']!, 'OD')),
                                          const SizedBox(width: 8),
                                          Expanded(child: _buildMiniTextField(part['deckle_cut']!, 'Deckle Cut')),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(child: _buildMiniTextField(part['length_cut']!, 'Length Cut')),
                                          const SizedBox(width: 8),
                                          Expanded(child: _buildMiniTextField(part['partition_type']!, 'Type')),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(child: _buildMiniTextField(part['ply_no']!, 'Ply No.')),
                                          const SizedBox(width: 8),
                                          Expanded(child: _buildMiniTextField(part['partition_weight']!, 'Weight')),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(child: _buildMiniTextField(part['partition_gsm']!, 'GSM')),
                                          const SizedBox(width: 8),
                                          Expanded(child: _buildMiniTextField(part['partition_bf']!, 'BF')),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  addPartition();
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Partition'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(color: AppColors.divider),
                        ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveProduct(
                                dialogContext,
                                nameCtrl, boxNoCtrl, materialCodeCtrl, sizeCtrl,
                                idLCtrl, idWCtrl, idHCtrl,
                                odLCtrl, odWCtrl, odHCtrl,
                                colorCtrl, weightCtrl, plyCtrl, gsmCtrl, bfCtrl, csCtrl,
                                partitions,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Save Product'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDialogSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
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

  Widget _buildMiniTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodySmall,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }

  Future<void> _saveProduct(
    BuildContext dialogContext,
    TextEditingController nameCtrl,
    TextEditingController boxNoCtrl,
    TextEditingController materialCodeCtrl,
    TextEditingController sizeCtrl,
    TextEditingController idLCtrl,
    TextEditingController idWCtrl,
    TextEditingController idHCtrl,
    TextEditingController odLCtrl,
    TextEditingController odWCtrl,
    TextEditingController odHCtrl,
    TextEditingController colorCtrl,
    TextEditingController weightCtrl,
    TextEditingController plyCtrl,
    TextEditingController gsmCtrl,
    TextEditingController bfCtrl,
    TextEditingController csCtrl,
    List<Map<String, TextEditingController>> partitions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (!dialogContext.mounted) return;
    if (authToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No Auth Token Found!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final productData = {
      'product_name': nameCtrl.text.trim(),
      'box_no': boxNoCtrl.text.trim(),
      'material_code': materialCodeCtrl.text.trim(),
      'size': sizeCtrl.text.trim(),
      'inner_length': idLCtrl.text.trim(),
      'inner_breadth': idWCtrl.text.trim(),
      'inner_depth': idHCtrl.text.trim(),
      'outer_length': odLCtrl.text.trim(),
      'outer_breadth': odWCtrl.text.trim(),
      'outer_depth': odHCtrl.text.trim(),
      'color': colorCtrl.text.trim(),
      'weight': weightCtrl.text.trim(),
      'ply': plyCtrl.text.trim(),
      'gsm': gsmCtrl.text.trim(),
      'bf': bfCtrl.text.trim(),
      'cs': csCtrl.text.trim(),
    };

    Map<String, List<String>> partitionFields = {
      'partition_size': [],
      'partition_od': [],
      'deckle_cut': [],
      'length_cut': [],
      'partition_type': [],
      'ply_no': [],
      'partition_weight': [],
      'partition_gsm': [],
      'partition_bf': [],
    };

    for (var part in partitions) {
      partitionFields['partition_size']!.add(part['partition_size']!.text.trim());
      partitionFields['partition_od']!.add(part['partition_od']!.text.trim());
      partitionFields['deckle_cut']!.add(part['deckle_cut']!.text.trim());
      partitionFields['length_cut']!.add(part['length_cut']!.text.trim());
      partitionFields['partition_type']!.add(part['partition_type']!.text.trim());
      partitionFields['ply_no']!.add(part['ply_no']!.text.trim());
      partitionFields['partition_weight']!.add(part['partition_weight']!.text.trim());
      partitionFields['partition_gsm']!.add(part['partition_gsm']!.text.trim());
      partitionFields['partition_bf']!.add(part['partition_bf']!.text.trim());
    }

    final postBody = {
      ...productData,
      ...partitionFields,
    };

    final resp = await http.post(
      Uri.parse('$baseUrl/corrugation/products/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: jsonEncode(postBody),
    );

    if (resp.statusCode == 201) {
      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product Added Successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _fetchProducts();
    } else {
      String msg = 'Failed to add product.';
      try {
        msg = jsonDecode(resp.body)['detail'] ?? msg;
      } catch (_) {}
      if (!dialogContext.mounted) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
