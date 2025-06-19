import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key, required this.title});
  final String title;

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> items = [
    {"name": "PARLE G 100GM", "box": 365},
    {"name": "KTB", "box": 7265},
    {"name": "PARLE G 800GM", "box": 570, "vertical": 0},
    {"name": "XYZ Product", "box": 123, "vertical": 5},
  ];

  Widget _buildItemCard(String name, int boxCount, {int? vertical}) {
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
            if (vertical != null) ...[
              const Divider(height: 24, thickness: 1),
              Text(
                'vertical = $vertical',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24, thickness: 1),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 40, // Adjust height as needed
              child: Stack(
                children: [
                  // Edit Button - Left aligned (icon only)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        foregroundColor: const Color(0xFF4A68F2),
                      ),
                      child: const Icon(Icons.edit),
                    ),
                  ),
                  // History Button - Center aligned (icon + label)
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.history),
                      label: const Text("History"),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                    ),
                  ),
                  // Delete Button - Right aligned (icon only)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        foregroundColor: Colors.red,
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: SizedBox(
                      height: 45, // Desired height
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add Box Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implement Add Box logic
                    },
                    icon: const Icon(Icons.add_box),
                    label: const Text("Add Box"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A68F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded ListView with scroll
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length + 1, // One extra for bottom spacing
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const SizedBox(height: 60); // Bottom spacer
                  }
                  final item = items[index];
                  return _buildItemCard(
                    item['name'],
                    item['box'],
                    vertical: item['vertical'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
