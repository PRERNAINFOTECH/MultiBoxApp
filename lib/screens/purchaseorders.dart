import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../screens/purchaseorders_detail.dart';
import '../widgets/custom_app_bar.dart';
import '../config.dart'; // baseUrl

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  List<String> companies = [];
  List<Map<String, dynamic>> products = [];
  List<String> buyers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPOs();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchPOs() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/purchase-orders/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        companies = List<String>.from(data["purchase_order_list"]);
        products = List<Map<String, dynamic>>.from(data["products"]);
        buyers = List<String>.from(data["po_given_by_choices"]);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      // Optionally show error
    }
  }

  Future<void> _addPurchaseOrder({
    required String productId,
    required String buyer,
    required String poNumber,
    required String poDate,
    required String rate,
    required String quantity,
  }) async {
    final authToken = await _getAuthToken();

    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/purchase-orders/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product_name': productId,
        'po_given_by': buyer,
        'po_number': poNumber,
        'po_date': poDate,
        'rate': rate,
        'po_quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      await _fetchPOs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase order created successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create purchase order: ${response.body}')),
        );
      }
    }
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
                  MaterialPageRoute(
                    builder: (context) => PurchaseOrdersDetailScreen(poGivenBy: name),
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("PO's"),
        actions: const [
          AppBarMenu(),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
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
                        items: products
                            .map((product) => DropdownMenuItem(
                                  value: product['pk'].toString(),
                                  child: Text(product['product_name']),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => selectedProduct = value),
                      ),

                      const SizedBox(height: 10),

                      // PO Given By Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedPOBy,
                        decoration: const InputDecoration(labelText: "PO Given By"),
                        items: buyers
                            .map((person) => DropdownMenuItem(value: person, child: Text(person)))
                            .toList(),
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
                        controller: TextEditingController(
                          text: selectedDate != null
                              ? "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"
                              : "",
                        ),
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
                          onPressed: () async {
                            // Validation
                            if (selectedProduct == null ||
                                selectedPOBy == null ||
                                poNumberController.text.trim().isEmpty ||
                                selectedDate == null ||
                                rateController.text.trim().isEmpty ||
                                quantityController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("All fields are required!"),
                                ),
                              );
                              return;
                            }

                            final formattedDate =
                                "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                            await _addPurchaseOrder(
                              productId: selectedProduct!,
                              buyer: selectedPOBy!,
                              poNumber: poNumberController.text.trim(),
                              poDate: formattedDate,
                              rate: rateController.text.trim(),
                              quantity: quantityController.text.trim(),
                            );
                            if (context.mounted) Navigator.pop(context);
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
}
