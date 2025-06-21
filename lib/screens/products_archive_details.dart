import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class ProductsArchiveDetailScreen extends StatefulWidget {
  final String productName;

  const ProductsArchiveDetailScreen({super.key, required this.productName});

  @override
  State<ProductsArchiveDetailScreen> createState() => _ProductsDetailScreenState();
}

class _ProductsDetailScreenState extends State<ProductsArchiveDetailScreen> {
  final ScrollController _scrollController = ScrollController();

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
        title: Text(widget.productName),
        actions: const [
          AppBarMenu(),
        ],
      ),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildLabeledCard(
                headerLeft: widget.productName,
                headerRight: "Code - BH-507",
                children: [
                  _buildTwoColumnRow("MATERIAL CODE", "SIZE", isHeader: true),
                  _buildTwoColumnRow("ID", "OD", isHeader: false),
                  _buildTwoColumnRow("445x280x295", "448x283x301"),
                  _buildTwoColumnRow("COLOR", "WEIGHT", isHeader: true),
                  _buildTwoColumnRow("Dark Green", "439gm"),
                  _buildTwoColumnRow("PLY", "CS", isHeader: true),
                  _buildTwoColumnRow("3", "130"),
                  _buildTwoColumnRow("GSM", "BF", isHeader: true),
                  _buildTwoColumnRow("140", "18"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _showRestoreConfirmationDialog();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: const Icon(Icons.restore_from_trash, color: Colors.green),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1.5, color: Colors.blueGrey),
              const SizedBox(height: 20),
              _buildLabeledCard(
                headerLeft: "Partition - vertical",
                children: [
                  _buildTwoColumnRow("PARTITION SIZE", "PARTITION OD", isHeader: true),
                  _buildTwoColumnRow("47x32.5 /12", "275x298"),
                  _buildTwoColumnRow("DECKLE CUT", "LENGTH CUT", isHeader: true),
                  _buildTwoColumnRow("4", "3"),
                  _buildTwoColumnRow("PLY NO.", "PARTITION WEIGHT", isHeader: true),
                  _buildTwoColumnRow("3 Ply", "40"),
                  _buildTwoColumnRow("GSM", "BF", isHeader: true),
                  _buildTwoColumnRow("140", "18"),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
              // Your actual restore logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Product restored")),
              );
            },
            child: const Text("Restore", style: TextStyle(color: Colors.green)),
          ),
        ],
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
                Text(
                  headerLeft,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
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
}
