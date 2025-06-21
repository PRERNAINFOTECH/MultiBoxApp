import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../screens/products_archive_details.dart';
import '../widgets/custom_app_bar.dart';

class ProductsArchiveScreen extends StatefulWidget {
  const ProductsArchiveScreen({super.key});

  @override
  State<ProductsArchiveScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsArchiveScreen> {
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
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: Column(
          children: [
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