import 'package:flutter/material.dart';
import '../screens/products.dart';
import '../screens/paperreels.dart';
import '../screens/stocks.dart';
import '../screens/purchaseorders.dart';
import '../screens/productions.dart';
import '../screens/programs.dart';
import '../screens/challans.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF4A68F2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4A68F2)),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
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
            _buildDrawerItem(context, Icons.inventory, 'Stock', StocksScreen(title: "Stocks",)),
            _buildDrawerItem(context, Icons.receipt_long, 'Paper Reels', PaperReelsScreen()),
            _buildDrawerItem(context, Icons.shopping_cart, 'Purchase Order', PurchaseOrdersScreen()),
            _buildDrawerItem(context, Icons.build, 'Production', ProductionsScreen()),
            _buildDrawerItem(context, Icons.event_note, 'Program', ProgramsScreen()),
            _buildDrawerItem(context, Icons.all_inbox, 'Products', ProductsScreen()),
            _buildDrawerItem(context, Icons.description, 'Challan', ChallansScreen()),
            Spacer(),
            const SizedBox(height: 20), // space before the close button
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // close drawer
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
            const SizedBox(height: 20), // space below the button
            SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget targetScreen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: TextStyle(color: Colors.white70)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => targetScreen)
        );
      },
    );
  }
}
