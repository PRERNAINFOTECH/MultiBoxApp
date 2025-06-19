import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../screens/products_detail.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<String> productNames = [
    "PARLE G 50GM",
    "PARLE G 100GM",
    "COOKIES 35GM",
    "PARLE G 50GM (BHUJ)",
    "PARLE G 100GM (BHUJ)",
    "KTB (TLO)",
    "KTB",
    "PARLE G 800GM",
    "PARLE G 50GM",
    "PARLE G 100GM",
    "COOKIES 35GM",
    "PARLE G 50GM (BHUJ)",
    "PARLE G 100GM (BHUJ)",
    "KTB (TLO)",
    "KTB",
    "PARLE G 800GM",
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProductCard(BuildContext context, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsDetailScreen(productName: name),
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
        title: const Text("Products"),
      ),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: Column(
          children: [
            // Search & Add Product Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Products...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add Product Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implement Add Product logic
                    },
                    icon: const Icon(Icons.add_box),
                    label: const Text("Add Product"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A68F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            // Product List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: productNames.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, productNames[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}