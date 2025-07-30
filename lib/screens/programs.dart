import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hideButtons = false;

  List<dynamic> programs = [];
  List<dynamic> filteredPrograms = [];
  List<dynamic> productNames = [];
  bool _loading = true;
  String? authToken;
  String searchQuery = "";

  // For sharing: One key per card
  List<GlobalKey> _cardKeys = [];

  @override
  void initState() {
    super.initState();
    _fetchPrograms();
  }

  Future<void> _fetchPrograms() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/programs/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      setState(() {
        programs = body['programs'] ?? [];
        filteredPrograms = programs;
        productNames = body['products'] ?? [];
        _cardKeys = List.generate(filteredPrograms.length, (_) => GlobalKey());
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _filterPrograms(String query) {
    setState(() {
      searchQuery = query;
      filteredPrograms = programs.where((prog) {
        return (prog['product_name']?.toLowerCase() ?? '').contains(
          query.toLowerCase(),
        );
      }).toList();
      _cardKeys = List.generate(filteredPrograms.length, (_) => GlobalKey());
    });
  }

  Future<void> _deleteProgram(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final resp = await http.delete(
      Uri.parse('$baseUrl/corrugation/programs/$id/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Program archived!"),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchPrograms();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to archive program."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ---- SHARING LOGIC ----
  Future<void> _shareProgramCard(GlobalKey cardKey) async {
    setState(() => _hideButtons = true);
    await Future.delayed(
      const Duration(milliseconds: 200),
    ); // Let UI hide the buttons

    try {
      RenderRepaintBoundary boundary =
          cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/program_card.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'Program details');
    } catch (e) {
      debugPrint("Error sharing program: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to share image."),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _hideButtons = false);
  }

  Widget _buildTwoColumnSection(List<List<String>> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      children: items
          .map((item) => _buildDetailItem(item[0], item[1]))
          .toList(),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return RichText(
      text: TextSpan(
        text: "$title\n",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          fontSize: 12,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 14,
            ),
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

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Programs"),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search bar and Add button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search Programs...",
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
                            onChanged: _filterPrograms,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A68F2),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showAddProgramDialog(context),
                          child: const Text("Add Program"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // All program cards
                    if (filteredPrograms.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text("No Programs Found"),
                      ),
                    ...filteredPrograms.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final prog = entry.value;
                      final cardKey = _cardKeys.length > idx
                          ? _cardKeys[idx]
                          : GlobalKey();

                      return Column(
                        children: [
                          RepaintBoundary(
                            key: cardKey,
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Name & Quantity
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          prog['product_name'] ?? "",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Quantity - ${prog['program_quantity'] ?? ''}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Date & Buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          prog['program_date'] ?? "",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (!_hideButtons)
                                          Row(
                                            children: [
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  shape: const CircleBorder(),
                                                  side: const BorderSide(
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _showEditProgramDialog(
                                                    context,
                                                    program: prog,
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.orange,
                                                  size: 20,
                                                ),
                                              ),
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  shape: const CircleBorder(),
                                                  side: const BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _showDeleteConfirmationDialog(
                                                    context,
                                                    () {
                                                      _deleteProgram(
                                                        prog['id'],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  shape: const CircleBorder(),
                                                  side: const BorderSide(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _shareProgramCard(cardKey);
                                                },
                                                child: const Icon(
                                                  Icons.share,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    // Product Details
                                    _buildTwoColumnSection([
                                      ["SIZE", prog['size'] ?? ""],
                                      ["CODE", prog['material_code'] ?? ""],
                                      [
                                        "OD",
                                        "${prog['outer_length'] ?? ""}X${prog['outer_breadth'] ?? ""}X${prog['outer_depth'] ?? ""}",
                                      ],
                                      ["GSM", prog['gsm']?.toString() ?? ""],
                                      ["COLOUR", prog['color'] ?? ""],
                                      [
                                        "WEIGHT",
                                        prog['weight']?.toString() ?? "",
                                      ],
                                    ]),
                                    const SizedBox(height: 16),
                                    if ((prog['program_notes'] ?? "")
                                        .isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          "Note:\n${prog['program_notes']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    // Partitions
                                    if ((prog['partitions'] ?? []).isNotEmpty)
                                      const Text(
                                        "Partitions",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if ((prog['partitions'] ?? []).isNotEmpty)
                                      const SizedBox(height: 12),
                                    if ((prog['partitions'] ?? []).isNotEmpty)
                                      ...((prog['partitions'] as List)
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final idx = entry.key + 1;
                                            final part = entry.value;
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Partition $idx",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      part['partition_type']
                                                              ?.toString() ??
                                                          "",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                _buildTwoColumnSection([
                                                  [
                                                    "SIZE",
                                                    part['partition_size']
                                                            ?.toString() ??
                                                        "",
                                                  ],
                                                  [
                                                    "OD",
                                                    part['partition_od']
                                                            ?.toString() ??
                                                        "",
                                                  ],
                                                  [
                                                    "DECKLE CUT",
                                                    part['deckle_cut']
                                                            ?.toString() ??
                                                        "",
                                                  ],
                                                  [
                                                    "LENGTH CUT",
                                                    part['length_cut']
                                                            ?.toString() ??
                                                        "",
                                                  ],
                                                  [
                                                    "PLY",
                                                    part['ply_no']
                                                            ?.toString() ??
                                                        "",
                                                  ],
                                                  [
                                                    "WEIGHT",
                                                    part['partition_weight']
                                                            ?.toString() ??
                                                        "",
                                                  ],
                                                ]),
                                                const SizedBox(height: 14),
                                              ],
                                            );
                                          })),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  // Add Program Dialog
  Future<void> _showAddProgramDialog(BuildContext context) async {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String? selectedProduct = productNames.isNotEmpty
        ? productNames[0].toString()
        : null;
    DateTime? selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Add Program"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedProduct,
                  decoration: const InputDecoration(labelText: "Product Name"),
                  items: productNames
                      .map(
                        (product) => DropdownMenuItem<String>(
                          value: product.toString(),
                          child: Text(product.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedProduct = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: "Program Quantity",
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Program Date",
                    hintText: selectedDate != null
                        ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                        : "Select Date",

                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Program Notes",
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () async {
                // API call to add
                if (selectedProduct == null ||
                    quantityController.text.isEmpty ||
                    selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final prefs = await SharedPreferences.getInstance();
                final authToken = prefs.getString('auth_token');
                final Map<String, dynamic> postData = {
                  'product_name': selectedProduct,
                  'program_quantity': quantityController.text,
                  'program_date':
                      "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                  'program_notes': notesController.text,
                };
                final resp = await http.post(
                  Uri.parse('$baseUrl/corrugation/programs/'),
                  headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'Authorization': 'Token $authToken',
                  },
                  body: jsonEncode(postData),
                );
                if (!context.mounted) return;
                if (resp.statusCode == 201) {
                  Navigator.of(context).pop();
                  await _fetchPrograms();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Program Added!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  String msg = "Failed to add program.";
                  try {
                    msg = jsonDecode(resp.body)['detail'] ?? msg;
                  } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A68F2),
                foregroundColor: Colors.white,
              ),
              child: const Text("Save Program"),
            ),
          ],
        );
      },
    );
  }

  // Edit Program Dialog
  Future<void> _showEditProgramDialog(
    BuildContext context, {
    required dynamic program,
  }) async {
    final TextEditingController quantityController = TextEditingController(
      text: program['program_quantity'].toString(),
    );
    final TextEditingController notesController = TextEditingController(
      text: program['program_notes'] ?? "",
    );
    String? selectedProduct = program['product_name'];
    DateTime? selectedDate = program['program_date'] != null
        ? DateTime.tryParse(program['program_date'])
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Edit Program"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedProduct,
                  decoration: const InputDecoration(labelText: "Product Name"),
                  items: productNames
                      .map(
                        (product) => DropdownMenuItem<String>(
                          value: product.toString(),
                          child: Text(product.toString()),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    selectedProduct = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: "Program Quantity",
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Program Date",
                    hintText: selectedDate != null
                        ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                        : "Select Date",

                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Program Notes",
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A68F2),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // API call to update
                if (selectedProduct == null ||
                    quantityController.text.isEmpty ||
                    selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final prefs = await SharedPreferences.getInstance();
                final authToken = prefs.getString('auth_token');
                final Map<String, dynamic> postData = {
                  'product_name': selectedProduct,
                  'program_quantity': quantityController.text,
                  'program_date':
                      "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                  'program_notes': notesController.text,
                };
                final resp = await http.patch(
                  Uri.parse('$baseUrl/corrugation/programs/${program['id']}/'),
                  headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'Authorization': 'Token $authToken',
                  },
                  body: jsonEncode(postData),
                );
                if (!context.mounted) return;
                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await _fetchPrograms();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Program Updated!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  String msg = "Failed to update program.";
                  try {
                    msg = jsonDecode(resp.body)['detail'] ?? msg;
                  } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  // Delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    VoidCallback onDelete,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Delete Program"),
          content: const Text("Are you sure you want to delete this program?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
