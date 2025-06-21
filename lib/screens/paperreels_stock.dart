import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_app_bar.dart';

class PaperReelStockScreen extends StatelessWidget {
  const PaperReelStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Paper Reel Stock"),
        backgroundColor: Colors.white,
        actions: const [
          AppBarMenu(),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.build_circle_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  "This feature is coming soon!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "We’re working on something awesome. Stay tuned!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
