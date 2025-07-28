import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class PaperReelsSummaryScreen extends StatefulWidget {
  const PaperReelsSummaryScreen({super.key});

  @override
  State<PaperReelsSummaryScreen> createState() => _PaperReelsSummaryScreenState();
}

class _PaperReelsSummaryScreenState extends State<PaperReelsSummaryScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> reels = [];
  int totalReels = 0;
  double totalWeight = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaperReelSummary();
  }

  Future<void> _fetchPaperReelSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/corrugation/paper-reels/summary/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        totalReels = data['total_reels'];
        totalWeight = (data['total_weight'] as num).toDouble();
        reels = List<Map<String, dynamic>>.from(data['paper_reel_summary']);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      // Handle error if needed
    }
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
        title: const Text("Paper Reels Summary"),
        backgroundColor: Colors.white,
        actions: const [
          AppBarMenu(),
        ],
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
                    // Summary section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Total Un-Used Reels: $totalReels\nTotal Weight: ${totalWeight.toStringAsFixed(2)}',
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.white),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text("${reel["size"]}")),
                                Expanded(child: Text("${reel["gsm"]}")),
                                Expanded(child: Text("${reel["bf"]}")),
                                Expanded(flex: 2, child: Text("${reel["total_weight"]}")),
                                Expanded(child: Text("${reel["total_reels"]}")),
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
