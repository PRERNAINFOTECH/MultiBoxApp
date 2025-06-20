import 'package:flutter/material.dart';
import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../screens/purchaseorders_archive_detail.dart';

class PurchaseOrdersArchiveScreen extends StatefulWidget {
  const PurchaseOrdersArchiveScreen({super.key});

  @override
  State<PurchaseOrdersArchiveScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersArchiveScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<String> companies = [
    "TARGET",
    "WALLMART",
    // Add more companies as needed
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  MaterialPageRoute(builder: (context) => const PurchaseOrdersArchiveDetailScreen(),
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
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Archive PO's"),
      ),
      body: ScrollToTopWrapper(
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
