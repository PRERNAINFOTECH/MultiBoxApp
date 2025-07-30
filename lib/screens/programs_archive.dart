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

class ProgramsArchiveScreen extends StatefulWidget {
  const ProgramsArchiveScreen({super.key});

  @override
  State<ProgramsArchiveScreen> createState() => _ProgramsArchiveScreenState();
}

class _ProgramsArchiveScreenState extends State<ProgramsArchiveScreen> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> programs = [];
  List<dynamic> filteredPrograms = [];
  List<GlobalKey> _cardKeys = [];
  List<bool> _hideButtonsList = [];
  bool _loading = true;
  String? authToken;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchArchivedPrograms();
  }

  Future<void> _fetchArchivedPrograms() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/programs/archive/'),
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
        _cardKeys = List.generate(filteredPrograms.length, (_) => GlobalKey());
        _hideButtonsList = List.generate(filteredPrograms.length, (_) => false);
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
        return (prog['product_name']?.toLowerCase() ?? '').contains(query.toLowerCase())
            || (prog['box_no']?.toLowerCase() ?? '').contains(query.toLowerCase())
            || (prog['material_code']?.toLowerCase() ?? '').contains(query.toLowerCase());
      }).toList();
      _cardKeys = List.generate(filteredPrograms.length, (_) => GlobalKey());
      _hideButtonsList = List.generate(filteredPrograms.length, (_) => false);
    });
  }

  Future<void> _restoreProgram(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final resp = await http.patch(
      Uri.parse('$baseUrl/corrugation/programs/restore/$id/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: jsonEncode({'active': true}),
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Program restored!"), backgroundColor: Colors.green),
      );
      await _fetchArchivedPrograms();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to restore."), backgroundColor: Colors.red),
      );
    }
  }

  // Individual card share logic, _hideButtonsList used per index
  Future<void> _shareProgramCard(GlobalKey cardKey, int idx) async {
    setState(() => _hideButtonsList[idx] = true);
    await Future.delayed(const Duration(milliseconds: 200)); // let UI update

    try {
      RenderRepaintBoundary boundary = cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/archive_program_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'Archived Program Details');
    } catch (e) {
      debugPrint("Error sharing archive program: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to share image."), backgroundColor: Colors.red),
      );
    }

    setState(() => _hideButtonsList[idx] = false);
  }

  Widget _buildTwoColumnSection(List<List<String>> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      children: items.map((item) => _buildDetailItem(item[0], item[1])).toList(),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return RichText(
      text: TextSpan(
        text: "$title\n",
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreConfirmationDialog(BuildContext context, VoidCallback onRestore) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Restore Program"),
          content: const Text("Are you sure you want to restore this program?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onRestore();
              },
              child: const Text("Restore"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ----------- UI -----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Archive Programs"),
        backgroundColor: Colors.white,
        actions: const [
          AppBarMenu(),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Archived Programs...",
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
                ],
              ),
              const SizedBox(height: 16),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPrograms.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text("No Archived Programs"),
                        )
                      : Column(
                          children: filteredPrograms.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final prog = entry.value;
                            final cardKey = _cardKeys.length > idx ? _cardKeys[idx] : GlobalKey();
                            final hideBtns = _hideButtonsList.length > idx ? _hideButtonsList[idx] : false;

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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                prog['product_name'] ?? "",
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                "Quantity - ${prog['program_quantity'] ?? ''}",
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),

                                          // Date & Restore/Share
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(prog['program_date'] ?? "", style: const TextStyle(color: Colors.grey)),
                                              if (!hideBtns)
                                                Row(
                                                  children: [
                                                    OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        shape: const CircleBorder(),
                                                        side: const BorderSide(color: Colors.green),
                                                      ),
                                                      onPressed: () {
                                                        _showRestoreConfirmationDialog(context, () {
                                                          _restoreProgram(prog['id']);
                                                        });
                                                      },
                                                      child: const Icon(Icons.restore_from_trash, color: Colors.green, size: 20),
                                                    ),
                                                    OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        shape: const CircleBorder(),
                                                        side: const BorderSide(color: Colors.blueAccent),
                                                      ),
                                                      onPressed: () {
                                                        _shareProgramCard(cardKey, idx);
                                                      },
                                                      child: const Icon(Icons.share, color: Colors.blueAccent, size: 20),
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
                                            ["OD", "${prog['outer_length'] ?? ""}X${prog['outer_breadth'] ?? ""}X${prog['outer_depth'] ?? ""}"],
                                            ["GSM", prog['gsm']?.toString() ?? ""],
                                            ["COLOUR", prog['color'] ?? ""],
                                            ["WEIGHT", prog['weight']?.toString() ?? ""],
                                          ]),

                                          const SizedBox(height: 16),
                                          if ((prog['program_notes'] ?? "").isNotEmpty)
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "Note:\n${prog['program_notes']}",
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          const SizedBox(height: 16),

                                          // Partition display
                                          if ((prog['partitions'] ?? []).isNotEmpty)
                                            const Text("Partitions", style: TextStyle(fontWeight: FontWeight.bold)),
                                          if ((prog['partitions'] ?? []).isNotEmpty)
                                            const SizedBox(height: 12),
                                          if ((prog['partitions'] ?? []).isNotEmpty)
                                            ...((prog['partitions'] as List).asMap().entries.map((entry) {
                                              final pidx = entry.key + 1;
                                              final part = entry.value;
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Partition $pidx",
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        part['partition_type']?.toString() ?? "",
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  _buildTwoColumnSection([
                                                    ["SIZE", part['partition_size']?.toString() ?? ""],
                                                    ["OD", part['partition_od']?.toString() ?? ""],
                                                    ["DECKLE CUT", part['deckle_cut']?.toString() ?? ""],
                                                    ["LENGTH CUT", part['length_cut']?.toString() ?? ""],
                                                    ["PLY", part['ply_no']?.toString() ?? ""],
                                                    ["WEIGHT", part['partition_weight']?.toString() ?? ""],
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
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
