import 'package:flutter/material.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/custom_app_bar.dart';

class BuyersListScreen extends StatefulWidget {
  const BuyersListScreen({super.key});

  @override
  State<BuyersListScreen> createState() => _BuyersListScreenState();
}

class _BuyersListScreenState extends State<BuyersListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> buyers = ['Wallmart', 'Costco', 'Hersheys'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Buyers"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Buyers",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _addBuyer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text("Add Buyer"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(120),
      },
      border: TableBorder.all(color: Colors.white),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildHeaderRow(),
        ...buyers.asMap().entries.map(
          (entry) => _buildBuyerRow(entry.key + 1, entry.value),
        ),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFF1F3F5)),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Buyer name', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  TableRow _buildBuyerRow(int index, String buyer) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(index.toString()),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(buyer),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF4A68F2)),
                onPressed: () {
                  _editBuyer(index - 1, buyer);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteDialog(buyer);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addBuyer() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Buyer'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Buyer Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() => buyers.add(name));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editBuyer(int index, String oldName) {
    final TextEditingController controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Buyer'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Buyer Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() => buyers[index] = newName);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String buyer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Buyer'),
        content: Text('Are you sure you want to delete $buyer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => buyers.remove(buyer));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
