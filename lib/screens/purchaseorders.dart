import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/app_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../screens/purchaseorders_detail.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import '../config.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  List<String> companies = [];
  List<Map<String, dynamic>> products = [];
  List<String> buyers = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPOs();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchPOs() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/purchase-orders/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        companies = List<String>.from(data["purchase_order_list"]);
        products = List<Map<String, dynamic>>.from(data["products"]);
        buyers = List<String>.from(data["po_given_by_choices"]);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _addPurchaseOrder({
    required String productId,
    required String buyer,
    required String poNumber,
    required String poDate,
    required String rate,
    required String quantity,
  }) async {
    final authToken = await _getAuthToken();

    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/purchase-orders/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product_name': productId,
        'po_given_by': buyer,
        'po_number': poNumber,
        'po_date': poDate,
        'rate': rate,
        'po_quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      await _fetchPOs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Purchase order created successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to create purchase order: ${response.body}')),
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
          hintText: 'Search by company name...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(Icons.search, color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
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
              builder: (context) => PurchaseOrdersDetailScreen(poGivenBy: name),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'C',
                  style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
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
                  Text(
                    'Tap to view purchase orders',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty ? 'No Purchase Orders' : 'No Results Found',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Add your first purchase order to get started'
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPurchaseOrderDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Add PO'),
      ),
      body: Column(
        children: [
          const GradientAppBar(title: 'Purchase Orders'),
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
                      onRefresh: _fetchPOs,
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
                                  const SizedBox(height: 16),
                                  FadeInWidget(
                                    delay: const Duration(milliseconds: 100),
                                    child: _buildStatsCard(),
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
                            child: SizedBox(height: 80),
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

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.business,
            label: 'Companies',
            value: companies.length.toString(),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            icon: Icons.inventory_2_outlined,
            label: 'Products',
            value: products.length.toString(),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            icon: Icons.person_outline,
            label: 'Buyers',
            value: buyers.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPurchaseOrderDialog(BuildContext context) async {
    final TextEditingController poNumberController = TextEditingController();
    final TextEditingController rateController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    String? selectedProduct = products.isNotEmpty ? products.first['pk'].toString() : null;
    String? selectedPOBy = buyers.isNotEmpty ? buyers.first : null;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add Purchase Order',
                              style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
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
                              label: 'Product Name',
                              value: selectedProduct,
                              items: products.map((p) => DropdownMenuItem(
                                value: p['pk'].toString(),
                                child: Text(p['product_name'] ?? ''),
                              )).toList(),
                              onChanged: (value) => setState(() => selectedProduct = value),
                              icon: Icons.inventory_2_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogDropdown(
                              label: 'PO Given By',
                              value: selectedPOBy,
                              items: buyers.map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b),
                              )).toList(),
                              onChanged: (value) => setState(() => selectedPOBy = value),
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: poNumberController,
                              label: 'PO Number',
                              icon: Icons.tag,
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(
                              label: 'PO Date',
                              selectedDate: selectedDate,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: AppColors.primary,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: AppColors.textPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: rateController,
                              label: 'Rate',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: quantityController,
                              label: 'PO Quantity',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
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
                                  flex: 2,
                                  child: GradientButton(
                                    text: 'Add Purchase Order',
                                    onPressed: () async {
                                      if (selectedProduct == null ||
                                          selectedPOBy == null ||
                                          poNumberController.text.trim().isEmpty ||
                                          selectedDate == null ||
                                          rateController.text.trim().isEmpty ||
                                          quantityController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.warning_amber, color: Colors.white),
                                                SizedBox(width: 12),
                                                Text('All fields are required!'),
                                              ],
                                            ),
                                            backgroundColor: AppColors.warning,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                        return;
                                      }

                                      final formattedDate =
                                          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                                      await _addPurchaseOrder(
                                        productId: selectedProduct!,
                                        buyer: selectedPOBy!,
                                        poNumber: poNumberController.text.trim(),
                                        poDate: formattedDate,
                                        rate: rateController.text.trim(),
                                        quantity: quantityController.text.trim(),
                                      );
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildDialogDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            dropdownColor: Colors.white,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                      : 'Select date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selectedDate != null ? AppColors.textPrimary : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
