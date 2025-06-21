import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class ProductionsArchiveScreen extends StatefulWidget {
  const ProductionsArchiveScreen({super.key});

  @override
  State<ProductionsArchiveScreen> createState() => _ProductionsScreenState();
}

class _ProductionsScreenState extends State<ProductionsArchiveScreen> {
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
        title: const Text("Archive Productions"),
        backgroundColor: Colors.white,
        actions: const [
          AppBarMenu(),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Product 1",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const CircleBorder(),
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.all(10),
                            ),
                            onPressed: () {
                              _showRestoreConfirmationDialog(context);
                            },
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
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("PRODUCTION QUANTITY", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text("2500", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("REELS USED", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text("6016 - 41.0 - 570kg", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text("6016 - 41.0 - 570kg", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showRestoreConfirmationDialog(BuildContext context) async {
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
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Restore"),
          ),
        ],
      );
    },
  );
}
