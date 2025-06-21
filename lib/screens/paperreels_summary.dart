import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class PaperReelsSummaryScreen extends StatefulWidget {
  const PaperReelsSummaryScreen({super.key});

  @override
  State<PaperReelsSummaryScreen> createState() => _PaperReelsSummaryScreenState(); // ✅ FIXED here
}

class _PaperReelsSummaryScreenState extends State<PaperReelsSummaryScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> reels = [
    {"Size": "27.25", "GSM": 180, "BF": 18, "Weight": 711, "Reels": 2},
    {"Size": "27.25", "GSM": 220, "BF": 20, "Weight": 2096, "Reels": 5},
    {"Size": "27.5", "GSM": 220, "BF": 20, "Weight": 2873, "Reels": 6},
    {"Size": "27.5", "GSM": 250, "BF": 18, "Weight": 1229, "Reels": 3},
    {"Size": "28.25", "GSM": 250, "BF": 18, "Weight": 1321, "Reels": 3},
    {"Size": "28.25", "GSM": 220, "BF": 20, "Weight": 846, "Reels": 2},
    {"Size": "29.5", "GSM": 220, "BF": 18, "Weight": 2225, "Reels": 5},
    {"Size": "30.5", "GSM": 140, "BF": 18, "Weight": 461, "Reels": 1},
    {"Size": "30.5", "GSM": 220, "BF": 18, "Weight": 477, "Reels": 1},
    {"Size": "31.5", "GSM": 220, "BF": 18, "Weight": 483, "Reels": 1},
    {"Size": "32.5", "GSM": 180, "BF": 20, "Weight": 504, "Reels": 1},
    {"Size": "32.5", "GSM": 250, "BF": 18, "Weight": 1352, "Reels": 3},
    {"Size": "32.75", "GSM": 220, "BF": 20, "Weight": 532, "Reels": 1},
    {"Size": "33.25", "GSM": 220, "BF": 18, "Weight": 486, "Reels": 1},
    {"Size": "36.0", "GSM": 140, "BF": 18, "Weight": 2648, "Reels": 6},
  ];

  static const int totalReels = 159;
  static const int totalWeight = 88271;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(), // ✅ Added side drawer
      appBar: AppBar(
        title: const Text("Paper Reels Summary"),
        backgroundColor: Colors.white,
        actions: const [
          AppBarMenu(),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Summary section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total Un-Used Reels: $totalReels\nTotal Weight: $totalWeight',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Table Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Text("Size", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("GSM", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("BF", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("Total Weight", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Total Reels", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const Divider(height: 0, thickness: 1),

              // Table rows
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: reels.length,
                  itemBuilder: (context, index) {
                    final reel = reels[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(reel["Size"])),
                          Expanded(child: Text("${reel["GSM"]}")),
                          Expanded(child: Text("${reel["BF"]}")),
                          Expanded(flex: 2, child: Text("${reel["Weight"]}")),
                          Expanded(child: Text("${reel["Reels"]}")),
                        ],
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
