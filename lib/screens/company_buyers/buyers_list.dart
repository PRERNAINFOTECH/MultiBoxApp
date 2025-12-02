import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';
import '../../config.dart';

class BuyersListScreen extends StatefulWidget {
  const BuyersListScreen({super.key});

  @override
  State<BuyersListScreen> createState() => _BuyersListScreenState();
}

class _BuyersListScreenState extends State<BuyersListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _buyers = [];
  bool _isLoading = true;
  String? _authToken;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchBuyers();
  }

  Future<void> _loadTokenAndFetchBuyers() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');

    if (_authToken != null) {
      await _fetchBuyers();
    } else {
      setState(() => _isLoading = false);
      _showError("User not authenticated.");
    }
  }

  Future<void> _fetchBuyers() async {
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse('$baseUrl/tenant/buyers/'),
      headers: {'Authorization': 'Token $_authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _buyers = data
            .map((item) => {
                  'id': item['id'],
                  'name': item['buyer_name'],
                })
            .toList();
        _isLoading = false;
      });
    } else {
      _showError("Failed to load buyers.");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBuyer(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenant/buyers/'),
      headers: {
        'Authorization': 'Token $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'buyer_name': name}),
    );

    if (response.statusCode == 201) {
      _showSuccess('Buyer added successfully');
      _fetchBuyers();
    } else {
      _showError(json.decode(response.body)['detail'] ?? 'Add failed');
    }
  }

  Future<void> _editBuyer(int id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tenant/buyers/$id/'),
      headers: {
        'Authorization': 'Token $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'buyer_name': name}),
    );

    if (response.statusCode == 200) {
      _showSuccess('Buyer updated successfully');
      _fetchBuyers();
    } else {
      _showError(json.decode(response.body)['detail'] ?? 'Update failed');
    }
  }

  Future<void> _deleteBuyer(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tenant/buyers/$id/'),
      headers: {'Authorization': 'Token $_authToken'},
    );

    if (response.statusCode == 200) {
      _showSuccess('Buyer deleted successfully');
      _fetchBuyers();
    } else {
      _showError(json.decode(response.body)['detail'] ?? 'Delete failed');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(msg),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredBuyers {
    if (_searchQuery.isEmpty) return _buyers;
    return _buyers.where((b) => b['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
          hintText: 'Search buyers...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(Icons.search, color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
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
            child: const Center(
              child: Icon(Icons.people, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Buyers',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 4),
                Text(
                  _buyers.length.toString(),
                  style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showAddBuyerDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('Add', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerCard(Map<String, dynamic> buyer, int index) {
    return SlideInWidget(
      delay: Duration(milliseconds: 100 + (index * 50)),
      child: AnimatedCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  buyer['name'].toString().isNotEmpty ? buyer['name'].toString()[0].toUpperCase() : 'B',
                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buyer['name'],
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Buyer #${buyer['id']}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditBuyerDialog(buyer['id'], buyer['name']),
              icon: Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _showDeleteBuyerDialog(buyer['id'], buyer['name']),
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Delete',
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
                Icons.people_outline,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty ? 'No Buyers' : 'No Results Found',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty ? 'Add your first buyer to get started' : 'Try adjusting your search terms',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              GradientButton(
                text: 'Add Buyer',
                onPressed: _showAddBuyerDialog,
                icon: Icons.add,
              ),
            ],
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
          const GradientAppBar(title: 'Buyers'),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : ScrollToTopWrapper(
                    scrollController: _scrollController,
                    child: RefreshIndicator(
                      onRefresh: _fetchBuyers,
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
                                    child: _buildStatsCard(),
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
                          if (filteredBuyers.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildBuyerCard(filteredBuyers[index], index),
                                  childCount: filteredBuyers.length,
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

  void _showAddBuyerDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_add, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Add Buyer', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              _buildDialogTextField(controller: controller, label: 'Buyer Name', icon: Icons.person_outline),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.textLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: 'Add',
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          _addBuyer(name);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBuyerDialog(int id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => Dialog(
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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.edit, color: AppColors.info, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Edit Buyer', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              _buildDialogTextField(controller: controller, label: 'Buyer Name', icon: Icons.person_outline),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.textLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty) {
                          _editBuyer(id, newName);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }

  void _showDeleteBuyerDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
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
              Text('Delete Buyer?', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "$name"?',
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _deleteBuyer(id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w500),
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
}
