import 'package:flutter/material.dart';
import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/custom_app_bar.dart';

class PurchaseOrdersArchiveDetailScreen extends StatelessWidget {
  const PurchaseOrdersArchiveDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Archive PO's Detail"),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: const [
          AppBarMenu(),
        ],
      ),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextField(
                decoration: InputDecoration(
                  hintText: "Search by Product Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Product 1",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            "June 20, 2025",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("MATERIAL CODE", style: TextStyle(color: Colors.blue)),
                                SizedBox(height: 4),
                                Text("958746", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 8),
                                Text("PO NUMBER", style: TextStyle(color: Colors.blue)),
                                SizedBox(height: 4),
                                Text("123456789", style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text("PO QUANTITY (GIVEN)", style: TextStyle(color: Colors.blue)),
                                SizedBox(height: 4),
                                Text("4000", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("BOX CODE", style: TextStyle(color: Colors.blue)),
                                SizedBox(height: 4),
                                Text("CS-201", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 8),
                                Text("RATE", style: TextStyle(color: Colors.blue)),
                                SizedBox(height: 4),
                                Text("85.0", style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text("PO QUANTITY (ALLOWED +5%)", style: TextStyle(color: Colors.blue)),
                                SizedBox(height: 4),
                                Text("4200.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),

                      // Dispatch title row with action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Dispatch",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  side: const BorderSide(color: Colors.green),
                                  padding: const EdgeInsets.all(8),
                                ),
                                onPressed: () => _showRestoreConfirmationDialog(context),
                                child: const Icon(Icons.restore_from_trash, size: 20, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Text("Remaining Quantity: 2000"),
                      const Text("Maximum Remaining Quantity: 2200.0"),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "2000 ( 2000 )",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restore_from_trash, color: Colors.green, size: 40),
              const SizedBox(height: 10),
              const Text(
                "Restore Purchase Order?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                "Do you want to restore this purchase order? It will be moved back to the active list.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Restore"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
