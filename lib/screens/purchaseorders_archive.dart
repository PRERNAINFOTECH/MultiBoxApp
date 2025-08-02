import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../screens/purchaseorders_archive_detail.dart';
import '../widgets/custom_app_bar.dart';
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
      // Optionally, show an error message here
    }
  }

  Widget _buildCompanyCard(BuildContext context, String name) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseOrdersArchiveDetailScreen(poGivenBy: name),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4F6EF7)),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(color: Color(0xFF4F6EF7)),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Archive PO's"),
        actions: const [
          AppBarMenu(),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
              scrollController: _scrollController,
              child: Column(
                children: [
                  // Purchase Orders List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        return _buildCompanyCard(context, companies[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
