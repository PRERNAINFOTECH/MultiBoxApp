import 'package:flutter/material.dart';
import '../screens/products.dart';
import '../screens/products_archive.dart';
import '../screens/paperreels.dart';
import '../screens/paperreels_summary.dart';
import '../screens/paperreels_stock.dart';
import '../screens/stocks.dart';
import '../screens/purchaseorders.dart';
import '../screens/purchaseorders_archive.dart';
import '../screens/productions.dart';
import '../screens/programs.dart';
import '../screens/programs_archive.dart';
import '../screens/challans.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String? _currentlyExpandedTileId;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF4A68F2),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF4A68F2)),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', height: 50),
                  const SizedBox(width: 10),
                  const Text(
                    'MultiBox',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Stock item without accordion
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.white70),
              title: const Text('Stock', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StocksScreen(title: "Stocks")),
                );
              },
            ),

            // Accordion sections
            _buildAccordionItem(context, 'reels', Icons.receipt_long, 'Paper Reels', [
              {'title': 'Summary', 'screen': PaperReelsSummaryScreen()},
              {'title': 'Reels', 'screen': PaperReelsScreen()},
              {'title': 'Stock', 'screen': PaperReelStockScreen()},
            ]),
            _buildAccordionItem(context, 'po', Icons.shopping_cart, 'Purchase Order', [
              {'title': 'Purchase Orders', 'screen': PurchaseOrdersScreen()},
              {'title': 'Archive', 'screen': PurchaseOrdersArchiveScreen()},
            ]),
            _buildAccordionItem(context, 'production', Icons.build, 'Production', [
              {'title': 'Productions', 'screen': ProductionsScreen()},
              {'title': 'Archive', 'screen': ProductionsScreen()},
            ]),
            _buildAccordionItem(context, 'programs', Icons.event_note, 'Program', [
              {'title': 'Programs', 'screen': ProgramsScreen()},
              {'title': 'Archive', 'screen': ProgramsArchiveScreen()},
            ]),
            _buildAccordionItem(context, 'products', Icons.all_inbox, 'Products', [
              {'title': 'Products', 'screen': ProductsScreen()},
              {'title': 'Archive', 'screen': ProductsArchiveScreen()},
            ]),
            _buildAccordionItem(context, 'challans', Icons.description, 'Challan', [
              {'title': 'Challans', 'screen': ChallansScreen()},
              {'title': 'Archive', 'screen': ChallansScreen()},
            ]),

            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white60, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionItem(
    BuildContext context,
    String id,
    IconData icon,
    String title,
    List<Map<String, dynamic>> subItems,
  ) {
    final bool isExpanded = _currentlyExpandedTileId == id;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Colors.white70,
      ),
      child: ExpansionTile(
        key: PageStorageKey(id),
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _currentlyExpandedTileId = expanded ? id : null;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: subItems.map((item) {
                  return ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                    title: Text(item['title'], style: const TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => item['screen']),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
