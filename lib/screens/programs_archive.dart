import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';

class ProgramsArchiveScreen extends StatefulWidget {
  const ProgramsArchiveScreen({super.key});

  @override
  State<ProgramsArchiveScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsArchiveScreen> {
  final ScrollController _scrollController = ScrollController();

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
        title: const Text("Programs"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Product Card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: Product Name and Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Product 1",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Quantity - 2500",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row: Date and Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "2025-06-20",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  side: const BorderSide(color: Colors.green),
                                ),
                                onPressed: () {},
                                child: const Icon(Icons.restore_from_trash, color: Colors.green, size: 20),
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  side: const BorderSide(color: Colors.green),
                                ),
                                onPressed: () {},
                                child: const Icon(Icons.share, color: Colors.green, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Product Details (2-column layout)
                      _buildTwoColumnSection([
                        ["SIZE", "50X50/2"],
                        ["CODE", "CS-201"],
                        ["OD", "455X285X305"],
                        ["GSM", "140 (120) 2/18"],
                        ["COLOUR", "Black"],
                        ["WEIGHT", "450"],
                      ]),

                      const SizedBox(height: 16),

                      // Note
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Note:\nYou may increase till 2650 quantity of boxes.",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Partitions
                      const Text("Partitions", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      _buildTwoColumnSection([
                        ["SIZE", "423X15"],
                        ["OD", "25x35x33"],
                        ["CUTS", "D - 2, L - 5"],
                        ["TYPE", "Vertical"],
                        ["PLY", "3 Ply"],
                        ["WEIGHT", "50"],
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
