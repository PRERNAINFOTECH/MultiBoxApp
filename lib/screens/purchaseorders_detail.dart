import 'package:flutter/material.dart';
import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/custom_app_bar.dart';

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
                                  side: const BorderSide(color: Colors.blueGrey),
                                  padding: const EdgeInsets.all(8),
                                ),
                                onPressed: () => _showDispatchDialog(context),
                                child: const Icon(Icons.local_shipping, size: 20, color: Colors.blueGrey,),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.all(8),
                                ),
                                onPressed: () => _showDeleteConfirmationDialog(context),
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

Future<void> _showDispatchDialog(BuildContext context) async {
  final TextEditingController dispatchDateController = TextEditingController();
  final TextEditingController dispatchQtyController = TextEditingController();
  final TextEditingController partitionQtyController = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Dispatch Details",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dispatch Date
                    TextField(
                      controller: dispatchDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Dispatch Date",
                        hintText: "mm/dd/yyyy",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dispatchDateController.text =
                              "${picked.month}/${picked.day}/${picked.year}";
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // Dispatch Quantity
                    TextField(
                      controller: dispatchQtyController,
                      decoration: const InputDecoration(
                        labelText: "Dispatch Quantity",
                        hintText: "Enter quantity",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 15),

                    // Partition Dispatch Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 70,
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              "vertical",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: partitionQtyController,
                            decoration: const InputDecoration(
                              labelText: "Partition Dispatch",
                              hintText: "Quantity for vertical",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Handle Save logic
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F6EF7),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Save Dispatch"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
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
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              const Text(
                "Delete Purchase Order?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to delete this purchase order? This action cannot be undone.",
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
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Delete"),
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
