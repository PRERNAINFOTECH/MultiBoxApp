import 'package:flutter/material.dart';
import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';

class PurchaseOrdersDetailScreen extends StatelessWidget {
  const PurchaseOrdersDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("PO's Detail"),
        backgroundColor: Colors.white,
        centerTitle: true,
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
                                  side: const BorderSide(color: Colors.grey),
                                  padding: const EdgeInsets.all(8),
                                ),
                                onPressed: () {},
                                child: const Icon(Icons.local_shipping, size: 20),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.all(8),
                                ),
                                onPressed: () {},
                                child: const Icon(Icons.delete, size: 20, color: Colors.red),
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
