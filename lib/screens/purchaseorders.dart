import 'package:flutter/material.dart';
import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../screens/purchaseorders_detail.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
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
                  MaterialPageRoute(builder: (context) => const PurchaseOrdersDetailScreen(),
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
        title: const Text("PO's"),
      ),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: Column(
          children: [
            // Add Purchase Order Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showAddPurchaseOrderDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F6EF7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text("Add Purchase Order"),
                  ),
                ],
              ),
            ),
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

Future<void> _showAddPurchaseOrderDialog(BuildContext context) async {
  final TextEditingController poNumberController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  String? selectedProduct;
  String? selectedPOBy;
  DateTime? selectedDate;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Purchase Order",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Product Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedProduct,
                      decoration: const InputDecoration(labelText: "Product Name"),
                      items: ['Product A', 'Product B'].map((product) {
                        return DropdownMenuItem(value: product, child: Text(product));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedProduct = value),
                    ),

                    const SizedBox(height: 10),

                    // PO Given By Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedPOBy,
                      decoration: const InputDecoration(labelText: "PO Given By"),
                      items: ['Manager', 'Director'].map((person) {
                        return DropdownMenuItem(value: person, child: Text(person));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedPOBy = value),
                    ),

                    const SizedBox(height: 10),

                    // PO Number
                    TextField(
                      controller: poNumberController,
                      decoration: const InputDecoration(labelText: "PO Number"),
                    ),

                    const SizedBox(height: 10),

                    // PO Date Picker
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "PO Date",
                        suffixIcon: const Icon(Icons.calendar_today),
                        hintText: selectedDate != null
                            ? "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"
                            : "mm/dd/yyyy",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // Rate
                    TextField(
                      controller: rateController,
                      decoration: const InputDecoration(labelText: "Rate"),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 10),

                    // PO Quantity
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: "PO Quantity"),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // You can now use selectedProduct, selectedPOBy, selectedDate
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F6EF7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text("Add Purchase Order"),
                      ),
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
