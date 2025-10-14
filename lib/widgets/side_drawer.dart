import 'package:flutter/material.dart';
import '../screens/products.dart';
import '../screens/products_archive.dart';
import '../screens/paperreels.dart';
import '../screens/paperreels_summary.dart';
import '../screens/stocks.dart';
import '../screens/purchaseorders.dart';
import '../screens/purchaseorders_archive.dart';
import '../screens/productions.dart';
import '../screens/productions_archive.dart';
import '../screens/programs.dart';
import '../screens/programs_archive.dart';
import '../screens/plan_support/plans_and_pricing.dart';
import '../services/subscription_service.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String? _currentlyExpandedTileId;
  bool hasActiveSubscription = false;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    final status = await SubscriptionService.hasActiveSubscription();
    setState(() {
      hasActiveSubscription = status;
    });
  }

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

            // Plans and Pricing - Always accessible
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.white),
              title: const Text('Plans & Pricing', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PlansPricingScreen()),
                );
              },
            ),

            // Stock item without accordion - Paid feature
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.white),
              title: const Text('Stock', style: TextStyle(color: Colors.white)),
              onTap: hasActiveSubscription ? () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StocksScreen()),
                );
              } : () {
                Navigator.of(context).pop();
                _showSubscriptionRequiredDialog(context);
              },
            ),

            // Accordion sections - All paid features
            _buildAccordionItem(context, 'reels', Icons.receipt_long, 'Paper Reels', [
              {'title': 'Summary', 'screen': PaperReelsSummaryScreen()},
              {'title': 'Reels', 'screen': PaperReelsScreen()},
            ], hasActiveSubscription),
            _buildAccordionItem(context, 'po', Icons.shopping_cart, 'Purchase Order', [
              {'title': 'Purchase Orders', 'screen': PurchaseOrdersScreen()},
              {'title': 'Archive', 'screen': PurchaseOrdersArchiveScreen()},
            ], hasActiveSubscription),
            _buildAccordionItem(context, 'production', Icons.build, 'Production', [
              {'title': 'Productions', 'screen': ProductionsScreen()},
              {'title': 'Archive', 'screen': ProductionsArchiveScreen()},
            ], hasActiveSubscription),
            _buildAccordionItem(context, 'programs', Icons.event_note, 'Program', [
              {'title': 'Programs', 'screen': ProgramsScreen()},
              {'title': 'Archive', 'screen': ProgramsArchiveScreen()},
            ], hasActiveSubscription),
            _buildAccordionItem(context, 'products', Icons.all_inbox, 'Products', [
              {'title': 'Products', 'screen': ProductsScreen()},
              {'title': 'Archive', 'screen': ProductsArchiveScreen()},
            ], hasActiveSubscription),

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
                    border: Border.all(color: Colors.white, width: 1),
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
    bool hasAccess,
  ) {
    final bool isExpanded = _currentlyExpandedTileId == id;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Colors.white,
      ),
      child: ExpansionTile(
        key: PageStorageKey(id),
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
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
                    onTap: hasAccess ? () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => item['screen']),
                      );
                    } : () {
                      Navigator.of(context).pop();
                      _showSubscriptionRequiredDialog(context);
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

  void _showSubscriptionRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscription Required'),
          content: const Text(
            'This feature is available for paid subscribers only. Please purchase a plan to access all features.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PlansPricingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A68F2),
                foregroundColor: Colors.white,
              ),
              child: const Text('View Plans'),
            ),
          ],
        );
      },
    );
  }
}
