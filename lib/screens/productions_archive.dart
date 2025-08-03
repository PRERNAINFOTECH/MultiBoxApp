import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';
import '../config.dart';

class ProductionsArchiveScreen extends StatefulWidget {
  const ProductionsArchiveScreen({super.key});

  @override
  State<ProductionsArchiveScreen> createState() => _ProductionsArchiveScreenState();
}

class _ProductionsArchiveScreenState extends State<ProductionsArchiveScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  List<dynamic> productions = [];
  

  @override
  void initState() {
    super.initState();
    _fetchArchivedProductions();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchArchivedProductions() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/productions/archive/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        productions = data['productions'] ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch archive.")),
      );
    }
  }

  Future<void> _showRestoreConfirmationDialog(BuildContext context, int pk) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Restore Production"),
          content: const Text("Are you sure you want to restore this production?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _restoreProduction(pk);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Restore"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _restoreProduction(int pk) async {
    final authToken = await _getAuthToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/corrugation/productions/$pk/restore/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      _fetchArchivedProductions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Production restored!")),
      );
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['detail'] ?? "Failed to restore production.")),
      );
    }
  }

  Widget _buildProductionCard(dynamic prod) {
    final pk = prod['pk'];
    final productName = prod['product_name'] ?? '';
    final productionQuantity = prod['production_quantity'] ?? 0;
    final reels = prod['reels'] as List<dynamic>;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => _showRestoreConfirmationDialog(context, pk),
                  child: const Icon(Icons.restore_from_trash, color: Colors.green, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Production Quantity Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("PRODUCTION QUANTITY", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("$productionQuantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Reels Used Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("REELS USED", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        ...reels.map((reel) => Text(
                              '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
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
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Archive Productions"),
        backgroundColor: Colors.white,
        actions: const [
          AppBarMenu(),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
              scrollController: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...productions.map((prod) => _buildProductionCard(prod)),
                  ],
                ),
              ),
            ),
    );
  }
}
