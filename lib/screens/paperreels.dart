import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../config.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class PaperReelsScreen extends StatefulWidget {
  const PaperReelsScreen({super.key});

  @override
  State<PaperReelsScreen> createState() => _PaperReelsScreenState();
}

class _PaperReelsScreenState extends State<PaperReelsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> reels = [];
  int usedCount = 0;
  int unusedCount = 0;
  int totalPages = 1;
  int page = 1;
  String searchQuery = "";
  bool _loading = true;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPaperReels();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchPaperReels({int? gotoPage, String? query}) async {
    setState(() {
      _loading = true;
    });

    final authToken = await _getToken();
    String url;
    int newPage = gotoPage ?? page;
    String q = query ?? searchQuery;

    if (q.isNotEmpty) {
      url =
          '$baseUrl/corrugation/paper-reels/search/?q=${Uri.encodeComponent(q)}';
    } else {
      url = '$baseUrl/corrugation/paper-reels/?page=$newPage&limit=20';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        if (q.isNotEmpty) {
          reels = List<Map<String, dynamic>>.from(data['results'] ?? []);
          usedCount = 0;
          unusedCount = 0;
          totalPages = 1;
        } else {
          reels = List<Map<String, dynamic>>.from(data['reels'] ?? []);
          usedCount = data['used_reels'] ?? 0;
          unusedCount = data['unused_reels'] ?? 0;
          totalPages = data['total_pages'] ?? 1;
          page = data['current_page'] ?? newPage;
        }
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to fetch reels.')));
    }
  }

  Future<void> _markAsUsed(int id) async {
    final authToken = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/corrugation/paper-reels/$id/'),
      headers: {'Authorization': 'Token $authToken'},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      _fetchPaperReels();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Marked as used.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to mark as used.')));
    }
  }

  Future<void> _restoreReel(int id) async {
    final authToken = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/paper-reels/$id/restore/'),
      headers: {'Authorization': 'Token $authToken'},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      _fetchPaperReels();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reel restored.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to restore reel.')));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. Upload a Reel Dialog ---
  Future<void> _showAddReelDialog() async {
    final formKey = GlobalKey<FormState>();
    var supplierCtrl = TextEditingController();
    var reelNumberCtrl = TextEditingController();
    var bfCtrl = TextEditingController();
    var gsmCtrl = TextEditingController();
    var sizeCtrl = TextEditingController();
    var weightCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload a Reel'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: supplierCtrl,
                  decoration: const InputDecoration(labelText: "Supplier"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: reelNumberCtrl,
                  decoration: const InputDecoration(labelText: "Reel Number"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: bfCtrl,
                  decoration: const InputDecoration(labelText: "BF"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: gsmCtrl,
                  decoration: const InputDecoration(labelText: "GSM"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: sizeCtrl,
                  decoration: const InputDecoration(labelText: "Size"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: weightCtrl,
                  decoration: const InputDecoration(labelText: "Weight"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final token = await _getToken();
              final resp = await http.post(
                Uri.parse('$baseUrl/corrugation/paper-reels/'),
                headers: {
                  'Authorization': 'Token $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  "reel_number": reelNumberCtrl.text,
                  "bf": bfCtrl.text,
                  "gsm": gsmCtrl.text,
                  "size": sizeCtrl.text,
                  "weight": weightCtrl.text,
                  "supplier": supplierCtrl.text,
                }),
              );
              if (!context.mounted) return;
              if (!mounted) return;
              if (resp.statusCode == 201) {
                Navigator.pop(ctx);
                _fetchPaperReels();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Reel uploaded!')));
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: ${resp.body}')));
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  // --- 2. Bulk Upload Dialog ---
  Future<void> _showBulkUploadDialog() async {
    final formKey = GlobalKey<FormState>();
    var supplierCtrl = TextEditingController();
    PlatformFile? selectedFile;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Bulk Upload Reels'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: supplierCtrl,
                  decoration: const InputDecoration(labelText: "Supplier"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    selectedFile?.name ?? "Select Excel File",
                  ), // <--- Null safe
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xlsx', 'xls'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        selectedFile = result.files.first;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate() || selectedFile == null) {
                  return;
                }
                final authToken = await _getToken();
                final request = http.MultipartRequest(
                  'POST',
                  Uri.parse('$baseUrl/corrugation/paper-reels/bulk-upload/'),
                );
                request.headers['Authorization'] = 'Token $authToken';
                request.files.add(
                  await http.MultipartFile.fromPath(
                    'reel_file',
                    selectedFile!.path!,
                  ),
                );
                request.fields['supplier'] = supplierCtrl.text;
                final response = await request.send();
                final respStr = await response.stream.bytesToString();
                if (!context.mounted) return;
                if (!mounted) return;
                if (response.statusCode == 200) {
                  Navigator.pop(ctx);
                  _fetchPaperReels();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bulk upload successful!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bulk upload failed: $respStr')),
                  );
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Add this method to your _PaperReelsScreenState class ---
  Future<void> _showEditReelDialog(Map<String, dynamic> reel) async {
    final formKey = GlobalKey<FormState>();
    var supplierCtrl = TextEditingController(text: reel["supplier"] ?? "");
    var reelNumberCtrl = TextEditingController(text: "${reel["reel_number"]}");
    var bfCtrl = TextEditingController(text: "${reel["bf"]}");
    var gsmCtrl = TextEditingController(text: "${reel["gsm"]}");
    var sizeCtrl = TextEditingController(text: "${reel["size"]}");
    var weightCtrl = TextEditingController(text: "${reel["weight"]}");

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Paper Reel'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: supplierCtrl,
                  decoration: const InputDecoration(labelText: "Supplier"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: reelNumberCtrl,
                  decoration: const InputDecoration(labelText: "Reel Number"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: bfCtrl,
                  decoration: const InputDecoration(labelText: "BF"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: gsmCtrl,
                  decoration: const InputDecoration(labelText: "GSM"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: sizeCtrl,
                  decoration: const InputDecoration(labelText: "Size"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: weightCtrl,
                  decoration: const InputDecoration(labelText: "Weight"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final token = await _getToken();
              final resp = await http.patch(
                Uri.parse('$baseUrl/corrugation/paper-reels/${reel["id"]}/'),
                headers: {
                  'Authorization': 'Token $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  "reel_number": reelNumberCtrl.text,
                  "bf": bfCtrl.text,
                  "gsm": gsmCtrl.text,
                  "size": sizeCtrl.text,
                  "weight": weightCtrl.text,
                  "supplier": supplierCtrl.text,
                }),
              );
              if (!context.mounted) return;
              if (!mounted) return;
              if (resp.statusCode == 200) {
                Navigator.pop(ctx);
                _fetchPaperReels();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Reel updated!')));
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: ${resp.body}')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Paper Reels"),
        backgroundColor: Colors.white,
        actions: [const AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
              scrollController: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search and actions row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Reels',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              suffixIcon: Icon(Icons.search),
                            ),
                            onChanged: (val) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }
                              _debounce = Timer(
                                const Duration(milliseconds: 350),
                                () {
                                  if (!mounted) return;
                                  setState(() {
                                    searchQuery = val.trim();
                                    page = 1;
                                  });
                                  _fetchPaperReels();
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            tooltip: "Upload",
                            onPressed: _showAddReelDialog,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Bulk"),
                          onPressed: _showBulkUploadDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Used/Unused stats
                    Row(
                      children: [
                        Chip(
                          label: Text("Used: $usedCount"),
                          backgroundColor: Colors.red[300],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text("Unused: $unusedCount"),
                          backgroundColor: Colors.green[300],
                        ),
                        const Spacer(),
                        if (totalPages > 1)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: page > 1
                                    ? () {
                                        setState(() {
                                          page--;
                                        });
                                        _fetchPaperReels();
                                      }
                                    : null,
                              ),
                              Text("Page $page of $totalPages"),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: page < totalPages
                                    ? () {
                                        setState(() {
                                          page++;
                                        });
                                        _fetchPaperReels();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Table header
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                "Reel",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "BF",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "GSM",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Size",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Weight",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "Actions",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 0, thickness: 1),

                    // Table rows
                    // --- Paste below in place of your ListView.builder in Expanded ---
                    Expanded(
                      child: reels.isEmpty
                          ? const Center(child: Text('No paper reels found.'))
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: reels.length,
                              itemBuilder: (context, index) {
                                final reel = reels[index];
                                return GestureDetector(
                                  onLongPress: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Supplier: ${reel['supplier'] ?? '-'}",
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: reel['used'] == true
                                            ? Colors.red[100]
                                            : Colors.white,
                                        border: const Border(
                                          bottom: BorderSide(
                                            color: Color(0xFFF8F9FA),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${reel["reel_number"]}",
                                            ),
                                          ),
                                          Expanded(
                                            child: Text("${reel["bf"]}"),
                                          ),
                                          Expanded(
                                            child: Text("${reel["gsm"]}"),
                                          ),
                                          Expanded(
                                            child: Text("${reel["size"]}"),
                                          ),
                                          Expanded(
                                            child: Text("${reel["weight"]}"),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Wrap(
                                                spacing: 2,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    tooltip: "Edit",
                                                    onPressed: () =>
                                                        _showEditReelDialog(
                                                          reel,
                                                        ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 32,
                                                          minHeight: 32,
                                                          maxWidth: 36,
                                                          maxHeight: 36,
                                                        ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                  if (reel['used'] == true)
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.restore,
                                                        color: Colors.green,
                                                      ),
                                                      tooltip: "Restore",
                                                      onPressed: () =>
                                                          _restoreReel(
                                                            reel['id'],
                                                          ),
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(
                                                            minWidth: 32,
                                                            minHeight: 32,
                                                            maxWidth: 36,
                                                            maxHeight: 36,
                                                          ),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    )
                                                  else
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      tooltip: "Mark as Used",
                                                      onPressed: () =>
                                                          _markAsUsed(
                                                            reel['id'],
                                                          ),
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(
                                                            minWidth: 32,
                                                            minHeight: 32,
                                                            maxWidth: 36,
                                                            maxHeight: 36,
                                                          ),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
