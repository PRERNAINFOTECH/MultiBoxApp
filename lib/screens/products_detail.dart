import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class ProductsDetailScreen extends StatefulWidget {
  final String productName;

  const ProductsDetailScreen({super.key, required this.productName});

  @override
  State<ProductsDetailScreen> createState() => _ProductsDetailScreenState();
}

class _ProductsDetailScreenState extends State<ProductsDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? product;
  List<Map<String, dynamic>> partitions = [];
  int? productPk;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchProduct() async {
    setState(() => _loading = true);
    final authToken = await _getToken();
    if (authToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auth token missing'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _loading = false);
      return;
    }

    // Find product pk
    final respAll = await http.get(
      Uri.parse('$baseUrl/corrugation/products/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (respAll.statusCode == 200) {
      final productsList = jsonDecode(respAll.body)['products'] as List;
      final match = productsList.firstWhere(
        (p) => p['product_name'] == widget.productName,
        orElse: () => null,
      );
      if (match != null) {
        productPk = match['pk'];
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product not found!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _loading = false);
        return;
      }
    }

    // Get product details and partitions
    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/products/$productPk/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      product = body['product'];
      partitions = (body['partitions'] as List)
          .map<Map<String, dynamic>>((p) => Map<String, dynamic>.from(p))
          .toList();
      setState(() => _loading = false);
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _archiveProduct() async {
    final authToken = await _getToken();
    if (authToken == null || productPk == null) return;
    final resp = await http.delete(
      Uri.parse('$baseUrl/corrugation/products/$productPk/archive/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      // Navigate back and trigger refresh
      Navigator.pop(context, true); // pass a result to trigger refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product archived!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to archive!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editProductDialog() async {
    final Map<String, TextEditingController> ctrls = {};
    for (var entry in product!.entries) {
      if (entry.key == "pk") continue;
      ctrls[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Product",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CloseButton(),
                  ],
                ),
                const SizedBox(height: 10),
                ...ctrls.entries.map(
                  (e) => _buildDialogField(
                    e.key.replaceAll('_', ' ').toUpperCase(),
                    e.value,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final authToken = await _getToken();
                        if (authToken == null || productPk == null) return;
                        final updated = {
                          for (var e in ctrls.entries)
                            e.key: e.value.text.trim(),
                        };
                        final resp = await http.patch(
                          Uri.parse(
                            '$baseUrl/corrugation/products/$productPk/',
                          ),
                          headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                            'Authorization': 'Token $authToken',
                          },
                          body: jsonEncode(updated),
                        );
                        if (!context.mounted) return;
                        if (resp.statusCode == 200) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Product updated!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          await _fetchProduct();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Update failed!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPartitionDialog({Map<String, dynamic>? initialData}) async {
    final isEdit = initialData != null;

    // Dropdown options
    final partitionTypeOptions = [
      {'label': 'Vertical', 'value': 'vertical'},
      {'label': 'Horizontal', 'value': 'horizontal'},
      {'label': 'Z-Type', 'value': 'z-type'},
      {'label': 'Criss-Cross', 'value': 'crisscross'},
      {'label': 'C-Type', 'value': 'c-type'},
    ];
    final plyNoOptions = [
      {'label': '3 Ply', 'value': '3'},
      {'label': '5 Ply', 'value': '5'},
      {'label': '7 Ply', 'value': '7'},
    ];

    // Text fields
    final partitionSizeCtrl = TextEditingController(text: initialData?['partition_size'] ?? "");
    final partitionOdCtrl = TextEditingController(text: initialData?['partition_od'] ?? "");
    final deckleCutCtrl = TextEditingController(text: initialData?['deckle_cut'] ?? "");
    final lengthCutCtrl = TextEditingController(text: initialData?['length_cut'] ?? "");
    final partitionWeightCtrl = TextEditingController(text: initialData?['partition_weight'] ?? "");
    final gsmCtrl = TextEditingController(text: initialData?['gsm'] ?? "");
    final bfCtrl = TextEditingController(text: initialData?['bf'] ?? "");

    // Dropdowns (init with default or initial value)
    String partitionTypeValue = initialData?['partition_type'] ?? 'vertical';
    String plyNoValue = initialData?['ply_no'] ?? '3';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? "Edit Partition" : "Partition Details",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const CloseButton(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildDialogField("Partition Size", partitionSizeCtrl),
                      _buildDialogField("Partition OD", partitionOdCtrl),
                      _buildDialogField("Deckle Cut", deckleCutCtrl),
                      _buildDialogField("Length Cut", lengthCutCtrl),

                      // Partition Type Dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: DropdownButtonFormField<String>(
                          value: partitionTypeValue,
                          items: partitionTypeOptions
                              .map((option) => DropdownMenuItem(
                                    value: option['value'],
                                    child: Text(option['label']!),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => partitionTypeValue = val);
                          },
                          decoration: const InputDecoration(
                            labelText: "Partition Type",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      // Ply Number Dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: DropdownButtonFormField<String>(
                          value: plyNoValue,
                          items: plyNoOptions
                              .map((option) => DropdownMenuItem(
                                    value: option['value'],
                                    child: Text(option['label']!),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => plyNoValue = val);
                          },
                          decoration: const InputDecoration(
                            labelText: "Ply Number",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      _buildDialogField("Partition Weight", partitionWeightCtrl),
                      _buildDialogField("Ply GSM", gsmCtrl),
                      _buildDialogField("Ply BF", bfCtrl),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A68F2),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final authToken = await _getToken();
                              if (authToken == null || productPk == null) return;

                              if (isEdit) {
                                // PATCH partitions/<pk>/
                                final resp = await http.patch(
                                  Uri.parse('$baseUrl/corrugation/partitions/${initialData["pk"]}/'),
                                  headers: {
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Token $authToken',
                                  },
                                  body: jsonEncode({
                                    "partition_size": partitionSizeCtrl.text.trim(),
                                    "partition_od": partitionOdCtrl.text.trim(),
                                    "deckle_cut": deckleCutCtrl.text.trim(),
                                    "length_cut": lengthCutCtrl.text.trim(),
                                    "partition_type": partitionTypeValue,
                                    "ply_no": plyNoValue,
                                    "partition_weight": partitionWeightCtrl.text.trim(),
                                    "gsm": gsmCtrl.text.trim(),
                                    "bf": bfCtrl.text.trim(),
                                  }),
                                );
                                if (!ctx.mounted) return;
                                if (resp.statusCode == 200) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Partition updated!"), backgroundColor: Colors.green),
                                  );
                                  await _fetchProduct();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Update failed!"), backgroundColor: Colors.red),
                                  );
                                }
                              } else {
                                // POST partitions/
                                final postBody = {
                                  "product_id": productPk,
                                  "new_partition_size": partitionSizeCtrl.text.trim(),
                                  "new_partition_od": partitionOdCtrl.text.trim(),
                                  "new_deckle_cut": deckleCutCtrl.text.trim(),
                                  "new_length_cut": lengthCutCtrl.text.trim(),
                                  "new_partition_type": partitionTypeValue,
                                  "new_ply_no": plyNoValue,
                                  "new_partition_weight": partitionWeightCtrl.text.trim(),
                                  "new_gsm": gsmCtrl.text.trim(),
                                  "new_bf": bfCtrl.text.trim(),
                                };
                                final resp = await http.post(
                                  Uri.parse('$baseUrl/corrugation/partitions/'),
                                  headers: {
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Token $authToken',
                                  },
                                  body: jsonEncode(postBody),
                                );
                                if (!ctx.mounted) return;
                                if (resp.statusCode == 201) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Partition added!"), backgroundColor: Colors.green),
                                  );
                                  await _fetchProduct();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Add failed!"), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            child: const Text("Save"),
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
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    String itemType,
    VoidCallback onConfirm,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $itemType"),
        content: Text("Are you sure you want to delete this $itemType?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _coloredCircleButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: color),
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildLabeledCard({
    required String headerLeft,
    String? headerRight,
    Widget? headerRightWidget,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
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
                    ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnRow(
    String left,
    String right, {
    bool isHeader = false,
  }) {
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: Text(product?['product_name'] ?? widget.productName),
        actions: const [AppBarMenu()],
      ),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ---- PRODUCT CARD ----
              _buildLabeledCard(
                headerLeft: product?['product_name'] ?? '',
                headerRight: product?['box_no'] != null
                    ? "Code - ${product!['box_no']}"
                    : "",
                children: [
                  _buildTwoColumnRow("MATERIAL CODE", "SIZE", isHeader: true),
                  _buildTwoColumnRow(
                    "${product?['material_code'] ?? ''}",
                    "${product?['size'] ?? ''}",
                  ),
                  _buildTwoColumnRow("ID", "OD", isHeader: true),
                  _buildTwoColumnRow(
                    "${product?['inner_length'] ?? ''}x${product?['inner_breadth'] ?? ''}x${product?['inner_depth'] ?? ''}",
                    "${product?['outer_length'] ?? ''}x${product?['outer_breadth'] ?? ''}x${product?['outer_depth'] ?? ''}",
                  ),
                  _buildTwoColumnRow("COLOR", "WEIGHT", isHeader: true),
                  _buildTwoColumnRow(
                    "${product?['color'] ?? ''}",
                    "${product?['weight'] ?? ''}",
                  ),
                  _buildTwoColumnRow("PLY", "CS", isHeader: true),
                  _buildTwoColumnRow(
                    "${product?['ply'] ?? ''}",
                    "${product?['cs'] ?? ''}",
                  ),
                  _buildTwoColumnRow("GSM", "BF", isHeader: true),
                  _buildTwoColumnRow(
                    "${product?['gsm'] ?? ''}",
                    "${product?['bf'] ?? ''}",
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _coloredCircleButton(
                        Icons.add_box,
                        Colors.green,
                        () => _showPartitionDialog(),
                      ),
                      _coloredCircleButton(
                        Icons.edit,
                        Colors.blue,
                        _editProductDialog,
                      ),
                      _coloredCircleButton(Icons.delete, Colors.red, () {
                        _showDeleteConfirmationDialog("product", () {
                          _archiveProduct();
                        });
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Show divider and partition cards ONLY if partitions exist!
              if (partitions.isNotEmpty) ...[
                const Divider(thickness: 1.5, color: Colors.blueGrey),
                const SizedBox(height: 20),
                ...partitions.map(
                  (p) => _buildLabeledCard(
                    headerLeft: "Partition - ${p["partition_type"] ?? ''}",
                    headerRightWidget: Row(
                      children: [
                        _coloredCircleButton(Icons.delete, Colors.red, () {
                          _showDeleteConfirmationDialog("partition", () async {
                            final authToken = await _getToken();
                            if (authToken == null) return;
                            final resp = await http.delete(
                              Uri.parse(
                                '$baseUrl/corrugation/partitions/${p["pk"]}/',
                              ),
                              headers: {
                                'Accept': 'application/json',
                                'Authorization': 'Token $authToken',
                              },
                            );
                            if (!mounted) return;
                            if (resp.statusCode == 200) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Partition deleted!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              await _fetchProduct();
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to delete partition!"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          });
                        }),
                        _coloredCircleButton(Icons.edit, Colors.blue, () {
                          _showPartitionDialog(initialData: p);
                        }),
                      ],
                    ),
                    children: [
                      _buildTwoColumnRow(
                        "PARTITION SIZE",
                        "PARTITION OD",
                        isHeader: true,
                      ),
                      _buildTwoColumnRow(
                        "${p["partition_size"] ?? ''}",
                        "${p["partition_od"] ?? ''}",
                      ),
                      _buildTwoColumnRow(
                        "DECKLE CUT",
                        "LENGTH CUT",
                        isHeader: true,
                      ),
                      _buildTwoColumnRow(
                        "${p["deckle_cut"] ?? ''}",
                        "${p["length_cut"] ?? ''}",
                      ),
                      _buildTwoColumnRow(
                        "PLY NO.",
                        "PARTITION WEIGHT",
                        isHeader: true,
                      ),
                      _buildTwoColumnRow(
                        "${p["ply_no"] ?? ''}",
                        "${p["partition_weight"] ?? ''}",
                      ),
                      _buildTwoColumnRow("GSM", "BF", isHeader: true),
                      _buildTwoColumnRow(
                        "${p["gsm"] ?? ''}",
                        "${p["bf"] ?? ''}",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
