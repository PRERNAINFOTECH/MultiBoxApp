import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../config.dart'; // baseUrl should be defined here

class BuyersListScreen extends StatefulWidget {
  const BuyersListScreen({super.key});

  @override
  State<BuyersListScreen> createState() => _BuyersListScreenState();
}

class _BuyersListScreenState extends State<BuyersListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _buyers = [];
  bool _isLoading = true;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchBuyers();
  }

  Future<void> _loadTokenAndFetchBuyers() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');

    if (_authToken != null) {
      await _fetchBuyers();
    } else {
      setState(() => _isLoading = false);
      _showError("User not authenticated.");
    }
  }

  Future<void> _fetchBuyers() async {
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse('$baseUrl/tenant/buyers/'),
      headers: {'Authorization': 'Token $_authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _buyers = data.map((item) => {
              'id': item['id'],
              'name': item['buyer_name'],
            }).toList();
        _isLoading = false;
      });
    } else {
      _showError("Failed to load buyers.");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBuyer(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenant/buyers/'),
      headers: {
        'Authorization': 'Token $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'buyer_name': name}),
    );

    if (response.statusCode == 201) {
      _fetchBuyers();
    } else {
      _showError(json.decode(response.body)['detail'] ?? 'Add failed');
    }
  }

  Future<void> _editBuyer(int id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tenant/buyers/$id/'),
      headers: {
        'Authorization': 'Token $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'buyer_name': name}),
    );

    if (response.statusCode == 200) {
      _fetchBuyers();
    } else {
      _showError(json.decode(response.body)['detail'] ?? 'Update failed');
    }
  }

  Future<void> _deleteBuyer(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tenant/buyers/$id/'),
      headers: {'Authorization': 'Token $_authToken'},
    );

    if (response.statusCode == 200) {
      _fetchBuyers();
    } else {
      _showError(json.decode(response.body)['detail'] ?? 'Delete failed');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Buyers"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Buyers",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showAddBuyerDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Add Buyer"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buyers.isEmpty
                        ? const Text("No buyers found.")
                        : _buildTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(120),
      },
      border: TableBorder.all(color: Colors.white),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildHeaderRow(),
        ..._buyers.asMap().entries.map(
          (entry) => _buildBuyerRow(entry.key + 1, entry.value),
        ),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFF1F3F5)),
      children: [
        Padding(padding: EdgeInsets.all(8.0), child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Buyer name', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  TableRow _buildBuyerRow(int index, Map<String, dynamic> buyer) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(index.toString())),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(buyer['name'])),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF4A68F2)),
                onPressed: () => _showEditBuyerDialog(buyer['id'], buyer['name']),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteBuyerDialog(buyer['id'], buyer['name']),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddBuyerDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Buyer'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Buyer Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _addBuyer(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditBuyerDialog(int id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Buyer'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Buyer Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                _editBuyer(id, newName);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteBuyerDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Buyer'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _deleteBuyer(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
