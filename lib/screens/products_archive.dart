import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../screens/products_archive_details.dart';
import '../widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class ProductsArchiveScreen extends StatefulWidget {
  const ProductsArchiveScreen({super.key});

  @override
  State<ProductsArchiveScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsArchiveScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<String> productNames = [];
  List<String> filteredProductNames = [];
  bool _loading = true;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _fetchArchivedProducts();
  }

  Future<void> _fetchArchivedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');

    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/archived-products/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(resp.body);
      setState(() {
        productNames = (body['products'] as List)
            .map<String>((p) => p['product_name'] as String)
            .toList();
        filteredProductNames = List.from(productNames);
        _searchController.clear();
        _loading = false;
      });
    } else {
      // Optionally handle error
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

  Widget _buildProductCard(BuildContext context, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsArchiveDetailScreen(productName: name),
          ),
        );
      },
      child: Card(
        color: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Archive Products"),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search Archived Products...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        ),
                        onChanged: _filterProducts,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredProductNames.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(context, filteredProductNames[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
