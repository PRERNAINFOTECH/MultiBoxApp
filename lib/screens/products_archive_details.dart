import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';
import '../screens/products_archive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class ProductsArchiveDetailScreen extends StatefulWidget {
  final String productName;

  const ProductsArchiveDetailScreen({super.key, required this.productName});

  @override
  State<ProductsArchiveDetailScreen> createState() => _ProductsDetailScreenState();
}

class _ProductsDetailScreenState extends State<ProductsArchiveDetailScreen> {
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
          const SnackBar(content: Text("Archived product not found!")),
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
        const SnackBar(content: Text("Product restored!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to restore!")),
      );
    }
  }

  Future<void> _showRestoreConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Restore Product"),
        content: const Text("Are you sure you want to restore this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: _restoreProduct,
            child: const Text("Restore", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _coloredCircleButton(IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          side: BorderSide(color: color),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _buildLabeledCard({
    required String headerLeft,
    String? headerRight,
    Widget? headerRightWidget,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(headerLeft,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    )),
                headerRightWidget ??
                    Text(
                      headerRight ?? "",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    )
              ],
            ),
            const SizedBox(height: 12),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnRow(String left, String right, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.blue : Colors.black,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.blue : Colors.black,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: Text(product?['product_name'] ?? widget.productName),
        actions: const [AppBarMenu()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
              scrollController: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildLabeledCard(
                      headerLeft: product?['product_name'] ?? '',
                      headerRight:
                          product?['box_no'] != null ? "Code - ${product!['box_no']}" : "",
                      children: [
                        _buildTwoColumnRow("MATERIAL CODE", "SIZE", isHeader: true),
                        _buildTwoColumnRow(
                          "${product?['material_code'] ?? ''}",
                          "${product?['size'] ?? ''}",
                        ),
                        _buildTwoColumnRow("ID", "OD", isHeader: true),
                        _buildTwoColumnRow(
                          "${product?['inner_length'] ?? ''}x${product?['inner_breadth'] ?? ''}x${product?['inner_depth'] ?? ''}",
                          "${product?['outer_length'] ?? ''}x${product?['outer_breadth'] ?? ''}x${product?['outer_depth'] ?? ''}",
                        ),
                        _buildTwoColumnRow("COLOR", "WEIGHT", isHeader: true),
                        _buildTwoColumnRow(
                          "${product?['color'] ?? ''}",
                          "${product?['weight'] ?? ''}",
                        ),
                        _buildTwoColumnRow("PLY", "CS", isHeader: true),
                        _buildTwoColumnRow(
                          "${product?['ply'] ?? ''}",
                          "${product?['cs'] ?? ''}",
                        ),
                        _buildTwoColumnRow("GSM", "BF", isHeader: true),
                        _buildTwoColumnRow(
                          "${product?['gsm'] ?? ''}",
                          "${product?['bf'] ?? ''}",
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _coloredCircleButton(Icons.restore, Colors.green, _showRestoreConfirmationDialog),
                          ],
                        ),
                      ],
                    ),
                    if (partitions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(thickness: 1.5, color: Colors.blueGrey),
                      const SizedBox(height: 20),
                      ...partitions.map((p) => _buildLabeledCard(
                            headerLeft: "Partition - ${p["partition_type"] ?? ''}",
                            children: [
                              _buildTwoColumnRow("PARTITION SIZE", "PARTITION OD", isHeader: true),
                              _buildTwoColumnRow(
                                  "${p["partition_size"] ?? ''}", "${p["partition_od"] ?? ''}"),
                              _buildTwoColumnRow("DECKLE CUT", "LENGTH CUT", isHeader: true),
                              _buildTwoColumnRow(
                                  "${p["deckle_cut"] ?? ''}", "${p["length_cut"] ?? ''}"),
                              _buildTwoColumnRow("PLY NO.", "PARTITION WEIGHT", isHeader: true),
                              _buildTwoColumnRow(
                                  "${p["ply_no"] ?? ''}", "${p["partition_weight"] ?? ''}"),
                              _buildTwoColumnRow("GSM", "BF", isHeader: true),
                              _buildTwoColumnRow("${p["gsm"] ?? ''}", "${p["bf"] ?? ''}"),
                            ],
                          )),
                      const SizedBox(height: 50),
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}
