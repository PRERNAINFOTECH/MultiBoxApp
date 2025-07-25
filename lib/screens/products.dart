import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../screens/products_detail.dart';
import '../widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  List<String> productNames = [];
  List<String> filteredProductNames = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/products/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
        },
    );
    if (resp.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(resp.body);
      setState(() {
        productNames = (body['products'] as List)
            .map<String>((p) => p['product_name'] as String)
            .toList();
            filteredProductNames = List.from(productNames);
        _searchController.clear();
        filteredProductNames = List.from(productNames);
        _loading = false;
      });
    } else {
      // optionally handle error
      setState(() => _loading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProductNames = productNames
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProductCard(BuildContext context, String name) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsDetailScreen(productName: name),
          ),
        );
        if (result == true) {
          _fetchProducts(); // refresh after deletion
        }
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
        actions: const [AppBarMenu()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
              scrollController: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              controller: _searchController,
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
                              onChanged: _filterProducts,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddProductDialog(context);
                          },
                          icon: const Icon(Icons.add_box),
                          label: const Text("Add Product"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A68F2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredProductNames.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(
                            context, filteredProductNames[index]);
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
  // Controllers for product fields
  final nameCtrl = TextEditingController();
  final boxNoCtrl = TextEditingController();
  final materialCodeCtrl = TextEditingController();
  final sizeCtrl = TextEditingController();
  final idLCtrl = TextEditingController();
  final idWCtrl = TextEditingController();
  final idHCtrl = TextEditingController();
  final odLCtrl = TextEditingController();
  final odWCtrl = TextEditingController();
  final odHCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final plyCtrl = TextEditingController();
  final gsmCtrl = TextEditingController();
  final bfCtrl = TextEditingController();
  final csCtrl = TextEditingController();

  // List for partition controllers
  List<Map<String, TextEditingController>> partitions = [];

  // Add 1st partition by default
  void addPartition() {
    partitions.add({
      'partition_size': TextEditingController(),
      'partition_od': TextEditingController(),
      'deckle_cut': TextEditingController(),
      'length_cut': TextEditingController(),
      'partition_type': TextEditingController(),
      'ply_no': TextEditingController(),
      'partition_weight': TextEditingController(),
      'partition_gsm': TextEditingController(),
      'partition_bf': TextEditingController(),
    });
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
                    _buildCtrlTextField(nameCtrl, "Product Name"),
                    _buildCtrlTextField(boxNoCtrl, "Box Number"),
                    _buildCtrlTextField(materialCodeCtrl, "Material Code"),
                    _buildCtrlTextField(sizeCtrl, "Size"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _MiniCtrlField(idLCtrl, "ID L")),
                        const SizedBox(width: 10),
                        Expanded(child: _MiniCtrlField(idWCtrl, "ID W")),
                        const SizedBox(width: 10),
                        Expanded(child: _MiniCtrlField(idHCtrl, "ID H")),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _MiniCtrlField(odLCtrl, "OD L")),
                        const SizedBox(width: 10),
                        Expanded(child: _MiniCtrlField(odWCtrl, "OD W")),
                        const SizedBox(width: 10),
                        Expanded(child: _MiniCtrlField(odHCtrl, "OD H")),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildCtrlTextField(colorCtrl, "Color"),
                    _buildCtrlTextField(weightCtrl, "Weight"),
                    _buildCtrlTextField(plyCtrl, "Ply"),
                    _buildCtrlTextField(gsmCtrl, "GSM"),
                    _buildCtrlTextField(bfCtrl, "BF"),
                    _buildCtrlTextField(csCtrl, "CS"),
                    const SizedBox(height: 10),

                    // Partitions Section
                    ...List.generate(partitions.length, (index) {
                      final part = partitions[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Partition ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (partitions.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      partitions.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                ),
                            ],
                          ),
                          _buildCtrlTextField(part['partition_size']!, "Partition Size"),
                          _buildCtrlTextField(part['partition_od']!, "Partition OD"),
                          _buildCtrlTextField(part['deckle_cut']!, "Deckle Cut"),
                          _buildCtrlTextField(part['length_cut']!, "Length Cut"),
                          _buildCtrlTextField(part['partition_type']!, "Partition Type", hint: "Vertical"),
                          _buildCtrlTextField(part['ply_no']!, "Ply Number", hint: "3 Ply"),
                          _buildCtrlTextField(part['partition_weight']!, "Partition Weight"),
                          _buildCtrlTextField(part['partition_gsm']!, "Ply GSM"),
                          _buildCtrlTextField(part['partition_bf']!, "Ply BF"),
                          const Divider(thickness: 1),
                        ],
                      );
                    }),
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
                      ],
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
                          onPressed: () async {
                            // 1. Gather product field values
                            final prefs = await SharedPreferences.getInstance();
                            final authToken = prefs.getString('auth_token');
                            if (!context.mounted) return;
                            if (authToken == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("No Auth Token Found!"), backgroundColor: Colors.red),
                              );
                              return;
                            }

                            final productData = {
                              'product_name': nameCtrl.text.trim(),
                              'box_no': boxNoCtrl.text.trim(),
                              'material_code': materialCodeCtrl.text.trim(),
                              'size': sizeCtrl.text.trim(),
                              'inner_length': idLCtrl.text.trim(),
                              'inner_breadth': idWCtrl.text.trim(),
                              'inner_depth': idHCtrl.text.trim(),
                              'outer_length': odLCtrl.text.trim(),
                              'outer_breadth': odWCtrl.text.trim(),
                              'outer_depth': odHCtrl.text.trim(),
                              'color': colorCtrl.text.trim(),
                              'weight': weightCtrl.text.trim(),
                              'ply': plyCtrl.text.trim(),
                              'gsm': gsmCtrl.text.trim(),
                              'bf': bfCtrl.text.trim(),
                              'cs': csCtrl.text.trim(),
                            };

                            // 2. Prepare partition arrays for each required key
                            Map<String, List<String>> partitionFields = {
                              'partition_size': [],
                              'partition_od': [],
                              'deckle_cut': [],
                              'length_cut': [],
                              'partition_type': [],
                              'ply_no': [],
                              'partition_weight': [],
                              'partition_gsm': [],
                              'partition_bf': [],
                            };

                            for (var part in partitions) {
                              partitionFields['partition_size']!.add(part['partition_size']!.text.trim());
                              partitionFields['partition_od']!.add(part['partition_od']!.text.trim());
                              partitionFields['deckle_cut']!.add(part['deckle_cut']!.text.trim());
                              partitionFields['length_cut']!.add(part['length_cut']!.text.trim());
                              partitionFields['partition_type']!.add(part['partition_type']!.text.trim());
                              partitionFields['ply_no']!.add(part['ply_no']!.text.trim());
                              partitionFields['partition_weight']!.add(part['partition_weight']!.text.trim());
                              partitionFields['partition_gsm']!.add(part['partition_gsm']!.text.trim());
                              partitionFields['partition_bf']!.add(part['partition_bf']!.text.trim());
                            }

                            final postBody = {
                              ...productData,
                              ...partitionFields,
                            };

                            final resp = await http.post(
                              Uri.parse('$baseUrl/corrugation/products/'),
                              headers: {
                                'Accept': 'application/json',
                                'Content-Type': 'application/json',
                                'Authorization': 'Token $authToken',
                              },
                              body: jsonEncode(postBody),
                            );

                            if (resp.statusCode == 201) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Product Added Successfully!"), backgroundColor: Colors.green),
                              );
                            } else {
                              String msg = "Failed to add product.";
                              try {
                                msg = jsonDecode(resp.body)['detail'] ?? msg;
                              } catch (_) {}
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg), backgroundColor: Colors.red),
                              );
                            }
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

// Helper for normal TextFields with controller
Widget _buildCtrlTextField(TextEditingController ctrl, String label, {String? hint}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

// Helper for small TextFields with controller (for ID/OD fields)
class _MiniCtrlField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _MiniCtrlField(this.controller, this.label);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
