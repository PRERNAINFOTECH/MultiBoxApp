import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/side_drawer.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/custom_app_bar.dart';
import '../config.dart';

class ProductionsScreen extends StatefulWidget {
  const ProductionsScreen({super.key});

  @override
  State<ProductionsScreen> createState() => _ProductionsScreenState();
}

class _ProductionsScreenState extends State<ProductionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  List<dynamic> productions = [];
  List<String> productNames = [];
  List<dynamic> reelsList = [];

  @override
  void initState() {
    super.initState();
    _fetchProductions();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchProductions() async {
    setState(() => _loading = true);
    final authToken = await _getAuthToken();

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/productions/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        productions = data['productions'] ?? [];
        productNames = List<String>.from(data['products'] ?? []);
        reelsList = data['reels'] ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      // Optionally, show an error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch productions.")),
      );
    }
  }

  Future<void> _addProductionLineDialog() async {
    String? selectedProduct;
    List<String> selectedReels = [];
    final qtyController = TextEditingController();
    String reelSearch = "";

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filtered reels based on search text
            final filteredReels = reelsList.where((reel) {
              final display =
                  '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg';
              return display.toLowerCase().contains(reelSearch.toLowerCase());
            }).toList();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Production Line",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Product Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Product",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedProduct,
                      items: productNames
                          .map(
                            (product) => DropdownMenuItem(
                              value: product,
                              child: Text(product),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProduct = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Reel Search Field
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Search Reel",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          reelSearch = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Reel MultiSelect
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Reels",
                        border: OutlineInputBorder(),
                      ),
                      child: filteredReels.isEmpty
                          ? const Text("No reels found.")
                          : Wrap(
                              spacing: 6,
                              children: filteredReels.map<Widget>((reel) {
                                final reelId = reel['reel_number'];
                                final reelDisplay =
                                    '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg';
                                final isSelected = selectedReels.contains(
                                  reelId,
                                );
                                return FilterChip(
                                  label: Text(reelDisplay),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedReels.add(reelId);
                                      } else {
                                        selectedReels.remove(reelId);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Production Quantity
                    TextFormField(
                      controller: qtyController,
                      decoration: const InputDecoration(
                        labelText: "Production Quantity",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A68F2),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final product = selectedProduct;
                            final reels = selectedReels;
                            final qty = qtyController.text;
                            if (product == null || qty.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all fields."),
                                ),
                              );
                              return;
                            }
                            final authToken = await _getAuthToken();
                            final response = await http.post(
                              Uri.parse('$baseUrl/corrugation/productions/'),
                              headers: {
                                'Accept': 'application/json',
                                'Authorization': 'Token $authToken',
                              },
                              body: {
                                'product': product,
                                'production_quantity': qty,
                                'reels': jsonEncode(reels),
                              },
                            );
                            if (!context.mounted) return;
                            if (response.statusCode == 201) {
                              Navigator.of(context).pop();
                              _fetchProductions();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Production added!"),
                                ),
                              );
                            } else {
                              final resp = jsonDecode(response.body);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    resp['detail'] ??
                                        "Failed to add production.",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text("Save changes"),
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
    );
  }

  Future<void> _editQuantityDialog(int pk, int oldQty) async {
    final qtyController = TextEditingController(text: oldQty.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Production Quantity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: qtyController,
                  decoration: const InputDecoration(
                    labelText: "New Quantity",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                        final qty = qtyController.text;
                        final authToken = await _getAuthToken();
                        final response = await http.patch(
                          Uri.parse('$baseUrl/corrugation/productions/$pk/'),
                          headers: {
                            'Accept': 'application/json',
                            'Authorization': 'Token $authToken',
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode({'production_quantity': qty}),
                        );
                        if (!context.mounted) return;
                        if (response.statusCode == 200) {
                          Navigator.pop(context);
                          _fetchProductions();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Quantity updated!")),
                          );
                        } else {
                          final resp = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                resp['detail'] ?? "Failed to update quantity.",
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Save"),
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

  Future<void> _addReelDialog(int pk) async {
    String? selectedReel;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Next Reel",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Reel",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedReel,
                  items: reelsList.map<DropdownMenuItem<String>>((reel) {
                    final display =
                        '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg';
                    return DropdownMenuItem<String>(
                      value: reel['reel_number'],
                      child: Text(display),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedReel = value;
                  },
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
                        if (selectedReel == null) return;
                        final authToken = await _getAuthToken();
                        final response = await http.post(
                          Uri.parse(
                            '$baseUrl/corrugation/productions/$pk/reels/',
                          ),
                          headers: {
                            'Accept': 'application/json',
                            'Authorization': 'Token $authToken',
                          },
                          body: {'reel_number': selectedReel},
                        );
                        if (!context.mounted) return;
                        if (response.statusCode == 201) {
                          Navigator.pop(context);
                          _fetchProductions();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reel added!")),
                          );
                        } else {
                          final resp = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                resp['detail'] ?? "Failed to add reel.",
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Add"),
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

  Future<void> _deleteConfirmationDialog(int pk) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Production"),
          content: const Text(
            "Are you sure you want to delete this production?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final authToken = await _getAuthToken();
                final response = await http.delete(
                  Uri.parse('$baseUrl/corrugation/productions/$pk/'),
                  headers: {
                    'Accept': 'application/json',
                    'Authorization': 'Token $authToken',
                  },
                );
                if (!context.mounted) return;
                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  _fetchProductions();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Production deleted!")),
                  );
                } else {
                  final resp = jsonDecode(response.body);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        resp['detail'] ?? "Failed to delete production.",
                      ),
                    ),
                  );
                }
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

  Widget _buildProductionCard(BuildContext context, dynamic prod) {
    final pk = prod['pk'];
    final productName = prod['product_name'] ?? '';
    final productionQuantity = prod['production_quantity'] ?? 0;
    final List<dynamic> usedReels = prod['reels'] ?? [];

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => _deleteConfirmationDialog(pk),
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Production Quantity Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PRODUCTION QUANTITY",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$productionQuantity",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: const BorderSide(color: Color(0xFF4A68F2)),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () =>
                          _editQuantityDialog(pk, productionQuantity),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFF4A68F2),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Reels Used Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "REELS USED",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...usedReels.map(
                          (reel) => Text(
                            '${reel['reel_number']} - ${reel['size']} - ${reel['weight']}kg',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () => _addReelDialog(pk),
                      child: const Icon(
                        Icons.add,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                  ],
                ),
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
      appBar: AppBar(
        title: const Text("Productions"),
        backgroundColor: Colors.white,
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
              scrollController: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _addProductionLineDialog,
                      child: const Text("Add Production Line"),
                    ),
                    const SizedBox(height: 16),

                    // Production Cards
                    ...productions.map(
                      (prod) => _buildProductionCard(context, prod),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
