import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/custom_app_bar.dart';
import '../config.dart';

class PurchaseOrdersDetailScreen extends StatefulWidget {
  final String poGivenBy;
  const PurchaseOrdersDetailScreen({super.key, required this.poGivenBy});

  @override
  State<PurchaseOrdersDetailScreen> createState() =>
      _PurchaseOrdersDetailScreenState();
}

class _PurchaseOrdersDetailScreenState
    extends State<PurchaseOrdersDetailScreen> {
  final ScrollController scrollController = ScrollController();

  bool _loading = true;
  List<dynamic> purchaseOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchPODetails();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchPODetails() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/corrugation/purchase-orders/by/${Uri.encodeComponent(widget.poGivenBy)}/',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        purchaseOrders = data['purchase_orders'] ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _postDispatch({
    required int poId,
    required String dispatchDate,
    required String dispatchQty,
    required Map<String, String> partitionDispatch,
  }) async {
    final authToken = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/dispatches/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pk': poId,
        'dispatch_date': dispatchDate,
        'dispatch_quantity': dispatchQty,
        'partition_dispatch': partitionDispatch,
      }),
    );
    if (!mounted) return;
    if (response.statusCode == 201) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dispatch added successfully.")),
        );
      }
      _fetchPODetails();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding dispatch: ${response.body}")),
        );
      }
    }
  }

  Future<void> _deletePO(int poId) async {
    final authToken = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/corrugation/purchase-orders/$poId/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Purchase order deleted successfully.")),
        );
      }
      _fetchPODetails();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting PO: ${response.body}")),
        );
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("PO's Detail"),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: const [AppBarMenu()],
      ),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                    ...purchaseOrders.map(
                      (po) => Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    po["product_name"]?.toString() ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    po["po_date"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "MATERIAL CODE",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          po["material_code"]?.toString() ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "PO NUMBER",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          po["po_number"]?.toString() ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "PO QUANTITY (GIVEN)",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          po["po_quantity"]?.toString() ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "BOX CODE",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          po["box_no"]?.toString() ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "RATE",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          po["rate"]?.toString() ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "PO QUANTITY (+5%)",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          po["po_quantity"] != null
                                              ? (double.tryParse(
                                                          po["po_quantity"]
                                                              .toString(),
                                                        )! *
                                                        1.05)
                                                    .toStringAsFixed(2)
                                              : "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),

                              // Dispatch title row with action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Dispatch",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          side: const BorderSide(
                                            color: Colors.blueGrey,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        onPressed: () async {
                                          await _showDispatchDialog(
                                            context,
                                            po["pk"],
                                          );
                                        },
                                        child: const Icon(
                                          Icons.local_shipping,
                                          size: 20,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        onPressed: () async {
                                          await _showDeleteConfirmationDialog(
                                            context,
                                            po["pk"],
                                          );
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              Text(
                                "Remaining Quantity: ${po["remaining_quantity"] ?? ""}",
                              ),
                              Text(
                                "Maximum Remaining Quantity: ${po["max_remaining_quantity"] ?? ""}",
                              ),
                              const SizedBox(height: 12),

                              // Dispatches section
                              ...((po["dispatches"] as List?) ?? []).map((
                                dispatch,
                              ) {
                                final partitions =
                                    dispatch["partition_dispatch"]
                                        as Map<String, dynamic>? ??
                                    {};
                                partitions.values
                                    .map((v) => "(${v.toString()})")
                                    .toList();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          [
                                            dispatch["dispatch_quantity"]
                                                    ?.toString() ??
                                                "",
                                            ...((dispatch["partition_dispatch"]
                                                        as Map<
                                                          String,
                                                          dynamic
                                                        >? ??
                                                    {})
                                                .values
                                                .map(
                                                  (v) => "(${v.toString()})",
                                                )),
                                          ].join(" "),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _showDispatchDialog(BuildContext context, int poId) async {
    final TextEditingController dispatchDateController =
        TextEditingController();
    final TextEditingController dispatchQtyController = TextEditingController();
    List<TextEditingController> partitionControllers = [
      TextEditingController(),
    ];
    List<String> partitionNames = ['vertical'];

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return LayoutBuilder(
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
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
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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

                          // Partition Dispatch Row(s)
                          ...List.generate(partitionControllers.length, (idx) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      partitionNames[idx],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: partitionControllers[idx],
                                    decoration: InputDecoration(
                                      labelText: "Partition Dispatch",
                                      hintText:
                                          "Quantity for ${partitionNames[idx]}",
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  onPressed: partitionControllers.length > 1
                                      ? () {
                                          setState(() {
                                            partitionControllers.removeAt(idx);
                                            partitionNames.removeAt(idx);
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  partitionControllers.add(
                                    TextEditingController(),
                                  );
                                  partitionNames.add(
                                    'partition ${partitionControllers.length}',
                                  );
                                });
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Add Partition"),
                            ),
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
                                onPressed: () async {
                                  // Validation
                                  if (dispatchDateController.text.isEmpty ||
                                      dispatchQtyController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Fill all fields!"),
                                      ),
                                    );
                                    return;
                                  }
                                  Map<String, String> partitionDispatch = {};
                                  for (
                                    int i = 0;
                                    i < partitionControllers.length;
                                    i++
                                  ) {
                                    final name = partitionNames[i];
                                    final qty = partitionControllers[i].text
                                        .trim();
                                    if (qty.isNotEmpty) {
                                      partitionDispatch[name] = qty;
                                    }
                                  }
                                  await _postDispatch(
                                    poId: poId,
                                    dispatchDate: dispatchDateController.text,
                                    dispatchQty: dispatchQtyController.text,
                                    partitionDispatch: partitionDispatch,
                                  );
                                  if (context.mounted) Navigator.pop(context);
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
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    int poId,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 40,
                ),
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
                      onPressed: () async {
                        await _deletePO(poId);
                        if (context.mounted) Navigator.pop(context);
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
}
