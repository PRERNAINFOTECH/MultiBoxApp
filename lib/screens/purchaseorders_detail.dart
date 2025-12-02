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

class PurchaseOrdersDetailScreen extends StatefulWidget {
  final String poGivenBy;
  const PurchaseOrdersDetailScreen({super.key, required this.poGivenBy});

  @override
  State<PurchaseOrdersDetailScreen> createState() =>
      _PurchaseOrdersDetailScreenState();
}

class _PurchaseOrdersDetailScreenState
    extends State<PurchaseOrdersDetailScreen> {
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
        '$baseUrl/corrugation/purchase-orders/by/${Uri.encodeComponent(widget.poGivenBy)}/',
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

  Future<void> _postDispatch({
    required int poId,
    required String dispatchDate,
    required String dispatchQty,
    required Map<String, String> partitionDispatch,
  }) async {
    final authToken = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/dispatches/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pk': poId,
        'dispatch_date': dispatchDate,
        'dispatch_quantity': dispatchQty,
        'partition_dispatch': partitionDispatch,
      }),
    );
    if (!mounted) return;
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Dispatch added successfully'),
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
                Expanded(child: Text('Error adding dispatch: ${response.body}')),
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

  Future<void> _deletePO(int poId) async {
    final authToken = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/corrugation/purchase-orders/$poId/'),
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
                Text('Purchase order deleted successfully'),
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
                Expanded(child: Text('Error deleting PO: ${response.body}')),
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

  Widget _buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                widget.poGivenBy.isNotEmpty ? widget.poGivenBy[0].toUpperCase() : 'C',
                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
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
                  style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${filteredPurchaseOrders.length} Purchase Order${filteredPurchaseOrders.length != 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.primaryLight.withValues(alpha: 0.02),
                  ],
                ),
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            po["po_date"] ?? "",
                            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.local_shipping,
                        color: AppColors.info,
                        onTap: () => _showDispatchDialog(context, po["pk"]),
                        tooltip: 'Add Dispatch',
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        onTap: () => _showDeleteConfirmationDialog(context, po["pk"]),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
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
                          color: AppColors.primary,
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
                        Icon(Icons.local_shipping, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Dispatches (${dispatches.length})',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: color),
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
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
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
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle, size: 18, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qty: ${dispatch["dispatch_quantity"] ?? ""}',
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
                  ? 'No purchase orders found for this company'
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
            title: 'PO Details',
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
                                  const SizedBox(height: 16),
                                  FadeInWidget(
                                    delay: const Duration(milliseconds: 100),
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

  Future<void> _showDispatchDialog(BuildContext context, int poId) async {
    final TextEditingController dispatchDateController = TextEditingController();
    final TextEditingController dispatchQtyController = TextEditingController();
    List<TextEditingController> partitionControllers = [TextEditingController()];
    List<String> partitionNames = ['vertical'];
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
                            child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add Dispatch',
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
                            _buildDialogDateField(
                              label: 'Dispatch Date',
                              controller: dispatchDateController,
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
                                  setState(() {
                                    selectedDate = picked;
                                    dispatchDateController.text =
                                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: dispatchQtyController,
                              label: 'Dispatch Quantity',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Partition Dispatch',
                                  style: AppTextStyles.titleMedium,
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      partitionControllers.add(TextEditingController());
                                      partitionNames.add('partition_${partitionControllers.length}');
                                    });
                                  },
                                  icon: Icon(Icons.add, size: 18, color: AppColors.primary),
                                  label: Text(
                                    'Add',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(partitionControllers.length, (idx) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: TextField(
                                          controller: TextEditingController(text: partitionNames[idx]),
                                          onChanged: (v) => partitionNames[idx] = v,
                                          style: AppTextStyles.bodyMedium,
                                          decoration: const InputDecoration(
                                            hintText: 'Name',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: TextField(
                                          controller: partitionControllers[idx],
                                          keyboardType: TextInputType.number,
                                          style: AppTextStyles.bodyMedium,
                                          decoration: const InputDecoration(
                                            hintText: 'Qty',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (idx > 0)
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            partitionControllers.removeAt(idx);
                                            partitionNames.removeAt(idx);
                                          });
                                        },
                                        icon: Icon(Icons.remove_circle, color: AppColors.error),
                                      ),
                                  ],
                                ),
                              );
                            }),
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
                                    text: 'Add Dispatch',
                                    onPressed: () async {
                                      if (dispatchDateController.text.isEmpty ||
                                          dispatchQtyController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.warning_amber, color: Colors.white),
                                                SizedBox(width: 12),
                                                Text('Please fill in all required fields'),
                                              ],
                                            ),
                                            backgroundColor: AppColors.warning,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                        return;
                                      }

                                      Map<String, String> partitionDispatch = {};
                                      for (int i = 0; i < partitionControllers.length; i++) {
                                        if (partitionControllers[i].text.isNotEmpty) {
                                          partitionDispatch[partitionNames[i]] = partitionControllers[i].text;
                                        }
                                      }

                                      await _postDispatch(
                                        poId: poId,
                                        dispatchDate: dispatchDateController.text,
                                        dispatchQty: dispatchQtyController.text,
                                        partitionDispatch: partitionDispatch,
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

  Widget _buildDialogDateField({
    required String label,
    required TextEditingController controller,
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
                  controller.text.isNotEmpty ? controller.text : 'Select date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: controller.text.isNotEmpty ? AppColors.textPrimary : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, int poId) async {
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
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete_outline, color: AppColors.error, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete Purchase Order?',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone. The purchase order will be permanently removed.',
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
                          await _deletePO(poId);
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Delete'),
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
