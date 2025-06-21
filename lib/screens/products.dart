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
                      _showAddProductDialog(context);
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

Future<void> _showAddProductDialog(BuildContext context) async {
  final ValueNotifier<int> partitionCount = ValueNotifier<int>(0);

  void addPartition() {
    partitionCount.value++;
  }

  void removePartition(int index) {
    partitionCount.value--;
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: const BoxConstraints(maxHeight: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Add New Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        CloseButton(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField("Product Name"),
                    _buildTextField("Box Number"),
                    _buildTextField("Material Code"),
                    _buildTextField("Size"),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(child: _MiniField("ID L")),
                        SizedBox(width: 10),
                        Expanded(child: _MiniField("ID W")),
                        SizedBox(width: 10),
                        Expanded(child: _MiniField("ID H")),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(child: _MiniField("OD L")),
                        SizedBox(width: 10),
                        Expanded(child: _MiniField("OD W")),
                        SizedBox(width: 10),
                        Expanded(child: _MiniField("OD H")),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField("Color"),
                    _buildTextField("Weight"),
                    _buildTextField("Ply"),
                    _buildTextField("GSM"),
                    _buildTextField("BF"),
                    _buildTextField("CS"),
                    const SizedBox(height: 10),

                    // Partitions Section
                    ValueListenableBuilder<int>(
                      valueListenable: partitionCount,
                      builder: (context, count, _) {
                        return Column(
                          children: [
                            ...List.generate(count, (index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Partition ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            removePartition(index);
                                          });
                                        },
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  _buildTextField("Partition Size"),
                                  _buildTextField("Partition OD"),
                                  _buildTextField("Deckle Cut"),
                                  _buildTextField("Length Cut"),
                                  _buildTextField("Partition Type", hint: "Vertical"),
                                  _buildTextField("Ply Number", hint: "3 Ply"),
                                  _buildTextField("Partition Weight"),
                                  _buildTextField("Ply GSM"),
                                  _buildTextField("Ply BF"),
                                  const Divider(thickness: 1),
                                ],
                              );
                            }),

                            // Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        addPartition();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                                    child: const Text("Add Partition"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (count > 0)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (partitionCount.value > 0) {
                                            partitionCount.value--;
                                          }
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                      child: const Text("Remove Partition"),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A68F2),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Save logic here
                          },
                          child: const Text("Save"),
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

Widget _buildTextField(String label, {String? hint}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

class _MiniField extends StatelessWidget {
  final String label;
  const _MiniField(this.label);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
