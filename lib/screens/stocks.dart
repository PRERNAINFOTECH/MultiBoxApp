import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
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

  List<Map<String, dynamic>> items = [];
  List<String> products = [];
  List<String> buyers = [];
  String searchText = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    return {'Accept': 'application/json', 'Authorization': 'Token $authToken'};
  }

  Future<void> _fetchStocks() async {
    setState(() {
      _loading = true;
    });
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/stocks/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        products = List<String>.from(data['products'] ?? []);
        buyers = List<String>.from(data['buyers'] ?? []);
        items = List<Map<String, dynamic>>.from(data['stocks'] ?? []);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      // Optionally: show an error message
    }
  }

  Future<void> _addStock(String product, int quantity) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/stocks/'),
      headers: headers,
      body: {"product_name": product, "stock_quantity": quantity.toString()},
    );
    if (response.statusCode == 200) {
      await _fetchStocks();
    } else {
      // Optionally: show an error message
    }
  }

  Future<void> _editStock(
    Map<String, dynamic> item,
    int quantity, {
    String? manualDate,
    String? partyName,
    int? vertical,
  }) async {
    final headers = await _getHeaders();

    final body = {
      "product_name": item['product_name'],
      "stock_quantity": quantity.toString(),
      if (manualDate != null && manualDate.isNotEmpty) "po_date": manualDate,
      if (partyName != null && partyName.isNotEmpty) "po_from": partyName,
      if (vertical != null) "stock_items[vertical]": vertical.toString(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/stocks/'),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      await _fetchStocks();
    } else {
      // Optionally: show an error message
    }
  }

  Future<void> _deleteStock(int stockPk) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/corrugation/stocks/$stockPk/delete/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      await _fetchStocks();
    } else {
      // Optionally: show an error message
    }
  }

  Future<List<Map<String, dynamic>>> _fetchHistory(int stockPk) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/stocks/$stockPk/dispatch-history/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['dispatches'] ?? []);
    }
    return [];
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final String name = item['product_name'] ?? '';
    final int boxCount = item['stock_quantity'] ?? 0;
    final int? vertical = item['partition_stock']?['vertical'] is int
        ? item['partition_stock']['vertical']
        : int.tryParse('${item['partition_stock']?['vertical'] ?? ''}');
    final int stockPk = item['stock_pk'];

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
            if (vertical != null && vertical != 0) ...[
              const Divider(height: 24, thickness: 1),
              Text(
                'vertical = $vertical',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24, thickness: 1),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: Stack(
                children: [
                  // Edit Button - Left aligned (icon only)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () => _showEditDialog(context, item),
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
                      onPressed: () async {
                        final historyData = await _fetchHistory(stockPk);
                        if (!mounted) return;
                        _showHistoryDialog(
                          context,
                          name,
                          historyData: historyData,
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text("History"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  // Delete Button - Right aligned (icon only)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, name, () {
                          _deleteStock(stockPk);
                        });
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

  // ========== Dialogs ==========
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 80,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
                      setState(() {
                        selectedProduct = value;
                      });
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
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        child: const Text("Close"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedProduct != null &&
                              quantityController.text.isNotEmpty) {
                            final quantity = int.tryParse(
                              quantityController.text,
                            );
                            if (quantity != null) {
                              onAdd(selectedProduct!, quantity);
                              if (!mounted) return;
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
                  ),
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
    Map<String, dynamic> item,
  ) async {
    final TextEditingController stockController = TextEditingController(
      text: '${item['stock_quantity'] ?? ''}',
    );
    final TextEditingController manualDateController = TextEditingController();
    final TextEditingController verticalController = TextEditingController(
      text: item['partition_stock']?['vertical']?.toString() ?? '0',
    );
    String? selectedBuyer;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 80,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
                        "Edit Quantity for ${item['product_name']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
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
                            manualDateController.text = "${picked.toLocal()}"
                                .split(' ')[0];
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Party Name Dropdown with manual entry option
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return buyers;
                          }
                          return buyers.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          selectedBuyer = selection;
                        },
                        fieldViewBuilder:
                            (
                              BuildContext context,
                              TextEditingController fieldTextEditingController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              return TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Party Name',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  selectedBuyer = value;
                                },
                              );
                            },
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
                            onPressed: () {
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            child: const Text("Close"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              final int? stockQty = int.tryParse(
                                stockController.text,
                              );
                              final int? verticalQty = int.tryParse(
                                verticalController.text,
                              );
                              _editStock(
                                item,
                                stockQty ?? item['stock_quantity'],
                                manualDate: manualDateController.text,
                                partyName: selectedBuyer ?? '',
                                vertical: verticalQty ?? 0,
                              );
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Save changes"),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete '$productName'?"),
          actions: [
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (!mounted) return;
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 80,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
                            child: Text(
                              'Dispatch Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Dispatch Quantity',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'PO Given By',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ...historyData.map(
                        (entry) => TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                entry['dispatch_date']
                                        ?.toString()
                                        .split("T")
                                        .first ??
                                    '-',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                entry['dispatch_quantity']?.toString() ?? '0',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                entry['po__po_given_by']?.toString() ?? '-',
                              ),
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
                      onPressed: () {
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
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

  // ========== UI ==========

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on search
    final List<Map<String, dynamic>> filteredItems = items
        .where(
          (item) => item['product_name'].toString().toLowerCase().contains(
            searchText.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      drawer: const SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Stocks"),
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
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchText = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search...",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add Box Button
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddStockDialog(context, products, (
                              product,
                              quantity,
                            ) {
                              _addStock(product, quantity);
                            });
                          },
                          label: const Text("Add Stock"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A68F2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expanded ListView with scroll
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          filteredItems.length +
                          1, // One extra for bottom spacing
                      itemBuilder: (context, index) {
                        if (index == filteredItems.length) {
                          return const SizedBox(height: 60); // Bottom spacer
                        }
                        final item = filteredItems[index];
                        return _buildItemCard(item);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
