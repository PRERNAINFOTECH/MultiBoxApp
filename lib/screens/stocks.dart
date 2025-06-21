import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> items = [
    {"name": "PARLE G 100GM", "box": 365},
    {"name": "KTB", "box": 7265},
    {"name": "PARLE G 800GM", "box": 570, "vertical": 0},
    {"name": "XYZ Product", "box": 123, "vertical": 5},
  ];

  Widget _buildItemCard(String name, int boxCount, {int? vertical}) {
    return Card(
      color: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF4A68F2),
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 8),
            Text(
              'Box = $boxCount',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (vertical != null) ...[
              const Divider(height: 24, thickness: 1),
              Text(
                'vertical = $vertical',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24, thickness: 1),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 40, // Adjust height as needed
              child: Stack(
                children: [
                  // Edit Button - Left aligned (icon only)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () => _showEditDialog(
                        context,
                        name,
                        stock: boxCount,
                        vertical: vertical ?? 0,
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        foregroundColor: const Color(0xFF4A68F2),
                        side: const BorderSide(color: Color(0xFF4A68F2)),
                      ),
                      child: const Icon(Icons.edit),
                    ),
                  ),
                  // History Button - Center aligned (icon + label)
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showHistoryDialog(
                          context,
                          name,
                          historyData: [
                            {
                              "date": "2025-06-27",
                              "quantity": 2000,
                              "poBy": "Target",
                            },
                            // Add more entries here if needed
                          ],
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text("History"),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.black,)),
                    ),
                  ),
                  // Delete Button - Right aligned (icon only)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(
                          context,
                          name,
                          () {
                            // Actual delete logic here
                            setState(() {
                              items.removeWhere((item) => item['name'] == name);
                            });
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Icon(Icons.delete),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Stocks"),
        actions: const [
          AppBarMenu(),
        ],
      ),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: SizedBox(
                      height: 45, // Desired height
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search...",
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
                  // Add Box Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddStockDialog(
                        context,
                        items.map((e) => e['name'].toString()).toList(),
                        (product, quantity) {
                          setState(() {
                            items.add({"name": product, "box": quantity});
                          });
                        },
                      );
                    },
                    label: const Text("Add Stock"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A68F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded ListView with scroll
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length + 1, // One extra for bottom spacing
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const SizedBox(height: 60); // Bottom spacer
                  }
                  final item = items[index];
                  return _buildItemCard(
                    item['name'],
                    item['box'],
                    vertical: item['vertical'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddStockDialog(
  BuildContext context,
  List<String> productOptions,
  void Function(String product, int quantity) onAdd,
) async {
  final TextEditingController quantityController = TextEditingController();
  String? selectedProduct;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Stock",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text("Select a product"),
                  value: selectedProduct,
                  onChanged: (value) {
                    selectedProduct = value;
                  },
                  items: productOptions
                      .map(
                        (product) => DropdownMenuItem<String>(
                          value: product,
                          child: Text(product),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedProduct != null && quantityController.text.isNotEmpty) {
                          final quantity = int.tryParse(quantityController.text);
                          if (quantity != null) {
                            onAdd(selectedProduct!, quantity);
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Add Stock"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showEditDialog(
  BuildContext context,
  String productName, {
  int stock = 0,
  String manualDate = '',
  String partyName = 'Target',
  int vertical = 0,
}) async {
  final TextEditingController stockController = TextEditingController(text: stock.toString());
  final TextEditingController manualDateController = TextEditingController(text: manualDate);
  final TextEditingController partyNameController = TextEditingController(text: partyName);
  final TextEditingController verticalController = TextEditingController(text: vertical.toString());

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Quantity for $productName",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: manualDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Manual Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          manualDateController.text = "${picked.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: partyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Party Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: verticalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Vertical Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Save logic here
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Save changes"),
                        ),
                      ],
                    )
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

Future<void> _showDeleteConfirmationDialog(
  BuildContext context,
  String productName,
  VoidCallback onConfirmDelete,
) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$productName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onConfirmDelete(); // Trigger delete callback
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}

Future<void> _showHistoryDialog(
  BuildContext context,
  String productName, {
  required List<Map<String, dynamic>> historyData,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Table(
                  border: TableBorder.all(color: Colors.white),
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.2),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFF1F3F5)),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Dispatch Date', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Dispatch Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('PO Given By', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...historyData.map(
                      (entry) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(entry['date'] ?? '-'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(entry['quantity']?.toString() ?? '0'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(entry['poBy'] ?? '-'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
