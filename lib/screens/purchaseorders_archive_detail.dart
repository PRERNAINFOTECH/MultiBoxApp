import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/custom_app_bar.dart';
import '../config.dart';

class PurchaseOrdersArchiveDetailScreen extends StatefulWidget {
  final String poGivenBy;
  const PurchaseOrdersArchiveDetailScreen({super.key, required this.poGivenBy});

  @override
  State<PurchaseOrdersArchiveDetailScreen> createState() => _PurchaseOrdersArchiveDetailScreenState();
}

class _PurchaseOrdersArchiveDetailScreenState extends State<PurchaseOrdersArchiveDetailScreen> {
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
        '$baseUrl/corrugation/purchase-orders/archive/by/${Uri.encodeComponent(widget.poGivenBy)}/',
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

  Future<void> _restorePO(int poId) async {
    final authToken = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/purchase-orders/$poId/restore/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Purchase order restored successfully.")),
        );
      }
      _fetchPODetails();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error restoring PO: ${response.body}")),
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
        title: const Text("Archive PO's Detail"),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: const [
          AppBarMenu(),
        ],
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
                    ...purchaseOrders.map(
                      (po) => Card(
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
                                children: [
                                  Text(
                                    po["product_name"]?.toString() ?? "",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    po["po_date"]?.toString() ?? "",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("MATERIAL CODE", style: TextStyle(color: Colors.blue)),
                                        const SizedBox(height: 4),
                                        Text(po["material_code"]?.toString() ?? "",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 8),
                                        const Text("PO NUMBER", style: TextStyle(color: Colors.blue)),
                                        const SizedBox(height: 4),
                                        Text(po["po_number"]?.toString() ?? "",
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        const Text("PO QUANTITY (GIVEN)", style: TextStyle(color: Colors.blue)),
                                        const SizedBox(height: 4),
                                        Text(po["po_quantity"]?.toString() ?? "",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("BOX CODE", style: TextStyle(color: Colors.blue)),
                                        const SizedBox(height: 4),
                                        Text(po["box_no"]?.toString() ?? "",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 8),
                                        const Text("RATE", style: TextStyle(color: Colors.blue)),
                                        const SizedBox(height: 4),
                                        Text(po["rate"]?.toString() ?? "",
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        const Text("PO QUANTITY (+5%)", style: TextStyle(color: Colors.blue)),
                                        const SizedBox(height: 4),
                                        Text(
                                          po["po_quantity"] != null
                                              ? (double.tryParse(po["po_quantity"].toString())! * 1.05).toStringAsFixed(2)
                                              : "",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),

                              // Dispatch title row with restore action
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
                                        onPressed: () => _showRestoreConfirmationDialog(context, po["pk"]),
                                        child: const Icon(Icons.restore_from_trash, size: 20, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              Text("Remaining Quantity: ${po["remaining_quantity"] ?? ""}"),
                              Text("Maximum Remaining Quantity: ${po["max_remaining_quantity"] ?? ""}"),
                              const SizedBox(height: 12),

                              // Dispatches section
                              ...((po["dispatches"] as List?) ?? []).map((dispatch) {
                                final qty = dispatch["dispatch_quantity"] ?? "";
                                final partitions = dispatch["partition_dispatch"] as Map<String, dynamic>? ?? {};
                                final partitionStrings = partitions.values
                                    .map((v) => "(${v.toString()})")
                                    .toList();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "$qty ${partitionStrings.join(' ')}",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
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

  Future<void> _showRestoreConfirmationDialog(BuildContext context, int poId) async {
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
                      onPressed: () async {
                        await _restorePO(poId);
                        if (context.mounted) Navigator.pop(context);
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
}
