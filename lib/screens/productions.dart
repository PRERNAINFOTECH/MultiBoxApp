import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/scroll_to_top_wrapper.dart';

class ProductionsScreen extends StatefulWidget {
  const ProductionsScreen({super.key});

  @override
  State<ProductionsScreen> createState() => _ProductionsScreenState();
}

class _ProductionsScreenState extends State<ProductionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  List<dynamic> productions = [];
  List<String> productNames = [];
  List<dynamic> reelsList = [];

  @override
  void initState() {
    super.initState();
    _fetchProductions();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchProductions() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/productions/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        productions = data['productions'] ?? [];
        productNames = List<String>.from(data['products'] ?? []);
        reelsList = data['reels'] ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to fetch productions.'),
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
          const GradientAppBar(title: 'Productions'),
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
                      onRefresh: _fetchProductions,
                      color: AppColors.primary,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (productions.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          else ...[
                            SliverPadding(
                              padding: const EdgeInsets.all(16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return SlideInWidget(
                                      delay: Duration(milliseconds: 100 + (index * 50)),
                                      child: _buildProductionCard(context, productions[index]),
                                    );
                                  },
                                  childCount: productions.length,
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 80),
                            ),
                          ],
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
          onPressed: _addProductionLineDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Production'),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.precision_manufacturing_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No productions yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a production line to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionCard(BuildContext context, dynamic prod) {
    final pk = prod['pk'];
    final productName = prod['product_name'] ?? '';
    final productionQuantity = prod['production_quantity'] ?? 0;
    final List<dynamic> usedReels = prod['reels'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.precision_manufacturing,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      productName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _deleteConfirmationDialog(pk),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoCard(
                  label: 'PRODUCTION QUANTITY',
                  value: '$productionQuantity',
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                  actionIcon: Icons.edit,
                  actionColor: AppColors.primary,
                  onAction: () => _editQuantityDialog(pk, productionQuantity),
                ),
                const SizedBox(height: 12),
                _buildReelsCard(usedReels, pk),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    IconData? actionIcon,
    Color? actionColor,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (actionIcon != null && onAction != null)
            IconButton(
              onPressed: onAction,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (actionColor ?? color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(actionIcon, color: actionColor ?? color, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReelsCard(List<dynamic> reels, int pk) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.circle, color: AppColors.success, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'REELS USED',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _addReelDialog(pk),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: AppColors.success, size: 18),
                ),
              ),
            ],
          ),
          if (reels.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...reels.map((reel) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.radio_button_checked, size: 8, color: AppColors.success),
                  const SizedBox(width: 12),
                  Text(
                    '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'No reels added yet',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addProductionLineDialog() async {
    String? selectedProduct = productNames.isNotEmpty ? productNames.first : null;
    List<String> selectedReels = [];
    final qtyController = TextEditingController();
    String reelSearch = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredReels = reelsList.where((reel) {
              final display = '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg';
              return display.toLowerCase().contains(reelSearch.toLowerCase());
            }).toList();

            return Dialog(
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
                            'Add New Production',
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
                            _buildDialogDropdown(
                              label: 'Product',
                              value: selectedProduct,
                              items: productNames,
                              onChanged: (val) => setState(() => selectedProduct = val),
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              label: 'Search Reels',
                              hint: 'Type to search...',
                              icon: Icons.search,
                              onChanged: (val) => setState(() => reelSearch = val),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: filteredReels.isEmpty
                                  ? Text(
                                      'No reels found',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: filteredReels.map<Widget>((reel) {
                                        final reelId = reel['reel_number'];
                                        final reelDisplay = '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg';
                                        final isSelected = selectedReels.contains(reelId);
                                        return FilterChip(
                                          label: Text(reelDisplay, style: AppTextStyles.labelSmall),
                                          selected: isSelected,
                                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                          checkmarkColor: AppColors.primary,
                                          onSelected: (selected) {
                                            setState(() {
                                              if (selected) {
                                                selectedReels.add(reelId);
                                              } else {
                                                selectedReels.remove(reelId);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: qtyController,
                              label: 'Production Quantity',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                            ),
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
                              onPressed: () => _saveProduction(dialogContext, selectedProduct, selectedReels, qtyController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Save'),
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

  Widget _buildDialogDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDialogTextField({
    TextEditingController? controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textLight, size: 20) : null,
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
    );
  }

  Future<void> _saveProduction(BuildContext dialogContext, String? product, List<String> reels, String qty) async {
    if (product == null || qty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final authToken = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/productions/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: {
        'product': product,
        'production_quantity': qty,
        'reels': jsonEncode(reels),
      },
    );

    if (!dialogContext.mounted) return;
    if (response.statusCode == 201) {
      Navigator.pop(dialogContext);
      _fetchProductions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Production added!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['detail'] ?? 'Failed to add production.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _editQuantityDialog(int pk, int oldQty) async {
    final qtyController = TextEditingController(text: oldQty.toString());

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Quantity',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDialogTextField(
                  controller: qtyController,
                  label: 'New Quantity',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
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
                        onPressed: () => _updateQuantity(dialogContext, pk, qtyController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save'),
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

  Future<void> _updateQuantity(BuildContext dialogContext, int pk, String qty) async {
    final authToken = await _getAuthToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/corrugation/productions/$pk/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'production_quantity': qty}),
    );

    if (!dialogContext.mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(dialogContext);
      _fetchProductions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quantity updated!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['detail'] ?? 'Failed to update quantity.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _addReelDialog(int pk) async {
    String? selectedReel;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_circle, color: AppColors.success),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add Reel',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedReel,
                      decoration: InputDecoration(
                        labelText: 'Select Reel',
                        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: reelsList.map<DropdownMenuItem<String>>((reel) {
                        final display = '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg';
                        return DropdownMenuItem<String>(
                          value: reel['reel_number'],
                          child: Text(display, style: AppTextStyles.bodySmall),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedReel = value),
                    ),
                    const SizedBox(height: 24),
                    Row(
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
                            onPressed: () => _saveReel(dialogContext, pk, selectedReel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Add'),
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
      },
    );
  }

  Future<void> _saveReel(BuildContext dialogContext, int pk, String? selectedReel) async {
    if (selectedReel == null) return;

    final authToken = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/productions/$pk/reels/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: {'reel_number': selectedReel},
    );

    if (!dialogContext.mounted) return;
    if (response.statusCode == 201) {
      Navigator.pop(dialogContext);
      _fetchProductions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reel added!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['detail'] ?? 'Failed to add reel.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _deleteConfirmationDialog(int pk) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
              'Delete Production',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this production? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteProduction(dialogContext, pk),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduction(BuildContext dialogContext, int pk) async {
    final authToken = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/corrugation/productions/$pk/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (!dialogContext.mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(dialogContext);
      _fetchProductions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Production deleted!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['detail'] ?? 'Failed to delete production.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
