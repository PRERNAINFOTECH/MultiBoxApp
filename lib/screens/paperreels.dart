import 'package:flutter/material.dart';
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
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _reelsPerPage = 20;
  String _searchQuery = '';

  final List<Map<String, dynamic>> reels = [
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 707, "Weight": 906},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 706, "Weight": 903},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 686, "Weight": 814},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 688, "Weight": 817},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 667, "Weight": 918},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 676, "Weight": 821},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 692, "Weight": 913},
    {"Size": 39.5, "GSM": 140, "BF": 18, "RNo": 596, "Weight": 604, "highlight": true},
    {"Size": 39.5, "GSM": 140, "BF": 18, "RNo": 595, "Weight": 607, "highlight": true},
    // duplicated for pagination testing
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 608, "Weight": 900},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 609, "Weight": 901},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 610, "Weight": 902},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 611, "Weight": 903},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 612, "Weight": 904},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 613, "Weight": 905},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 614, "Weight": 906},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 615, "Weight": 907},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 616, "Weight": 908},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 617, "Weight": 909},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 618, "Weight": 910},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 619, "Weight": 911},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 620, "Weight": 912},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 621, "Weight": 913},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 707, "Weight": 906},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 706, "Weight": 903},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 686, "Weight": 814},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 688, "Weight": 817},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 667, "Weight": 918},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 676, "Weight": 821},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 692, "Weight": 913},
    {"Size": 39.5, "GSM": 140, "BF": 18, "RNo": 596, "Weight": 604, "highlight": true},
    {"Size": 39.5, "GSM": 140, "BF": 18, "RNo": 595, "Weight": 607, "highlight": true},
    // duplicated for pagination testing
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 608, "Weight": 900},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 609, "Weight": 901},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 610, "Weight": 902},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 611, "Weight": 903},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 612, "Weight": 904},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 613, "Weight": 905},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 614, "Weight": 906},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 615, "Weight": 907},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 616, "Weight": 908},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 617, "Weight": 909},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 618, "Weight": 910},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 619, "Weight": 911},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 620, "Weight": 912},
    {"Size": 47.0, "GSM": 140, "BF": 18, "RNo": 621, "Weight": 913},
  ];

  List<Map<String, dynamic>> get _filteredReels {
    if (_searchQuery.isEmpty) return reels;
    return reels.where((reel) {
      return reel.values.any((val) => val.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  List<Map<String, dynamic>> get _paginatedReels {
    final filtered = _filteredReels;
    final start = _currentPage * _reelsPerPage;
    final end = start + _reelsPerPage;
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildRow(int index, Map<String, dynamic> reel) {
    final bool highlight = reel['highlight'] == true;

    return Container(
      color: highlight ? Colors.red[100] : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      margin: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Expanded(child: Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 13)))),
          Expanded(flex: 1, child: Center(child: Text('${reel["Size"]}', style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 1, child: Center(child: Text('${reel["BF"]}', style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 1, child: Center(child: Text('${reel["GSM"]}', style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 2, child: Center(child: Text('${reel["RNo"]}', style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 2, child: Center(child: Text('${reel["Weight"]}', style: const TextStyle(fontSize: 12)))),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => _showEditPaperReelDialog(context, reel),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(28, 28),
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Color(0xFF4A68F2)),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Color(0xFF4A68F2)),
                ),
                OutlinedButton(
                  onPressed: () => _showDeleteReelDialog(context, reel["RNo"], isHighlighted: highlight),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(28, 28),
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: highlight ? Colors.green : Colors.red),
                  ),
                  child: Icon(
                    highlight ? Icons.restore_from_trash : Icons.delete,
                    size: 16,
                    color: highlight ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
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
        actions: const [
          AppBarMenu(),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 36, // Controls overall height of the TextField
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 0;
                    });
                  },
                  style: const TextStyle(fontSize: 13), // Optional: smaller text
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Search reels...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              color: Colors.white,
              child: Row(
                children: const [
                  Expanded(child: Center(child: Text("No.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                  Expanded(flex: 1, child: Center(child: Text("Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                  Expanded(flex: 1, child: Center(child: Text("BF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                  Expanded(flex: 1, child: Center(child: Text("GSM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                  Expanded(flex: 2, child: Center(child: Text("R.No", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                  Expanded(flex: 2, child: Center(child: Text("Weight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                  Expanded(flex: 3, child: Center(child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                ],
              ),
            ),
            const Divider(height: 0, thickness: 1),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _paginatedReels.length,
                      itemBuilder: (context, index) {
                        return _buildRow(index + _currentPage * _reelsPerPage, _paginatedReels[index]);
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                minimumSize: const Size(36, 36),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Page ${_currentPage + 1} of ${(_filteredReels.length / _reelsPerPage).ceil()}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: (_currentPage + 1) * _reelsPerPage < _filteredReels.length
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                minimumSize: const Size(36, 36),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          ],
                        ),
                      ),
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
}

Future<void> _showEditPaperReelDialog(BuildContext context, Map<String, dynamic> reel) async {
  final TextEditingController supplierController = TextEditingController(text: reel["Supplier"] ?? "Umason");
  final TextEditingController reelNoController = TextEditingController(text: reel["RNo"]?.toString() ?? "");
  final TextEditingController bfController = TextEditingController(text: reel["BF"]?.toString() ?? "");
  final TextEditingController gsmController = TextEditingController(text: reel["GSM"]?.toString() ?? "");
  final TextEditingController sizeController = TextEditingController(text: reel["Size"]?.toString() ?? "");
  final TextEditingController weightController = TextEditingController(text: reel["Weight"]?.toString() ?? "");

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Paper Reel",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                const SizedBox(height: 10),
                TextField(
                  controller: supplierController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reelNoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reel Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bfController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'BF',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gsmController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'GSM',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Size (Inch)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A68F2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Save Changes"),
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

Future<void> _showDeleteReelDialog(BuildContext context, int reelNumber, {bool isHighlighted = false}) async {
  final String actionText = isHighlighted ? "Make Unused" : "Make Used";
  final Color buttonColor = isHighlighted ? Colors.green : Colors.red;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Delete Paper Reel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Divider(),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    const TextSpan(text: "Are you sure you want to make the reel "),
                    TextSpan(
                      text: "$reelNumber",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: isHighlighted ? " unused?" : " used?"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle toggle logic here (used ↔ unused)
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(actionText),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
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
