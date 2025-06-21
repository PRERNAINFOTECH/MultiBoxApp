import 'package:flutter/material.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';

class ProductsDetailScreen extends StatefulWidget {
  final String productName;

  const ProductsDetailScreen({super.key, required this.productName});

  @override
  State<ProductsDetailScreen> createState() => _ProductsDetailScreenState();
}

class _ProductsDetailScreenState extends State<ProductsDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showPartitionDialog({Map<String, String>? initialData}) async {
    final TextEditingController sizeController =
        TextEditingController(text: initialData?["size"] ?? "");
    final TextEditingController odController =
        TextEditingController(text: initialData?["od"] ?? "");
    final TextEditingController deckleController =
        TextEditingController(text: initialData?["deckle"] ?? "");
    final TextEditingController lengthController =
        TextEditingController(text: initialData?["length"] ?? "");
    final TextEditingController typeController =
        TextEditingController(text: initialData?["type"] ?? "Vertical");
    final TextEditingController plyController =
        TextEditingController(text: initialData?["ply"] ?? "3 Ply");
    final TextEditingController weightController =
        TextEditingController(text: initialData?["weight"] ?? "");
    final TextEditingController gsmController =
        TextEditingController(text: initialData?["gsm"] ?? "");
    final TextEditingController bfController =
        TextEditingController(text: initialData?["bf"] ?? "");

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Partition Details",
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildDialogField("Partition Size", sizeController),
                  _buildDialogField("Partition OD", odController),
                  _buildDialogField("Deckle Cut", deckleController),
                  _buildDialogField("Length Cut", lengthController),
                  _buildDialogField("Partition Type", typeController),
                  _buildDialogField("Ply Number", plyController),
                  _buildDialogField("Partition Weight", weightController),
                  _buildDialogField("Ply GSM", gsmController),
                  _buildDialogField("Ply BF", bfController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A68F2),
                            foregroundColor: Colors.white,
                          ),
                        onPressed: () {
                          // Save partition logic
                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditProductDialog({Map<String, String>? initialData}) async {
    final nameController = TextEditingController(text: initialData?['name'] ?? widget.productName);
    final codeController = TextEditingController(text: initialData?['code'] ?? "BH-507");
    final materialCodeController = TextEditingController(text: initialData?['material'] ?? "MC001");
    final sizeController = TextEditingController(text: initialData?['size'] ?? "445x280x295");
    final idController = TextEditingController(text: initialData?['id'] ?? "ID");
    final odController = TextEditingController(text: initialData?['od'] ?? "448x283x301");
    final colorController = TextEditingController(text: initialData?['color'] ?? "Dark Green");
    final weightController = TextEditingController(text: initialData?['weight'] ?? "439gm");
    final plyController = TextEditingController(text: initialData?['ply'] ?? "3");
    final csController = TextEditingController(text: initialData?['cs'] ?? "130");
    final gsmController = TextEditingController(text: initialData?['gsm'] ?? "140");
    final bfController = TextEditingController(text: initialData?['bf'] ?? "18");

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    CloseButton(),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDialogField("Product Name", nameController),
                _buildDialogField("Box Number", codeController),
                _buildDialogField("Material Code", materialCodeController),
                _buildDialogField("Size", sizeController),
                _buildDialogField("ID", idController),
                _buildDialogField("OD", odController),
                _buildDialogField("Color", colorController),
                _buildDialogField("Weight", weightController),
                _buildDialogField("Ply", plyController),
                _buildDialogField("CS", csController),
                _buildDialogField("GSM", gsmController),
                _buildDialogField("BF", bfController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Save logic here
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String itemType, VoidCallback onConfirm) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $itemType"),
        content: Text("Are you sure you want to delete this $itemType?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () {
            Navigator.pop(context);
            onConfirm();
          }, child: const Text("Delete", style: TextStyle(color: Colors.red)))
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _coloredCircleButton(IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: color),
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(title: Text(widget.productName)),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildLabeledCard(
                headerLeft: widget.productName,
                headerRight: "Code - BH-507",
                children: [
                  _buildTwoColumnRow("MATERIAL CODE", "SIZE", isHeader: true),
                  _buildTwoColumnRow("ID", "OD"),
                  _buildTwoColumnRow("445x280x295", "448x283x301"),
                  _buildTwoColumnRow("COLOR", "WEIGHT", isHeader: true),
                  _buildTwoColumnRow("Dark Green", "439gm"),
                  _buildTwoColumnRow("PLY", "CS", isHeader: true),
                  _buildTwoColumnRow("3", "130"),
                  _buildTwoColumnRow("GSM", "BF", isHeader: true),
                  _buildTwoColumnRow("140", "18"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _coloredCircleButton(Icons.add_box, Colors.green, () => _showPartitionDialog()),
                      _coloredCircleButton(Icons.edit, Colors.blue, () {
                        _showEditProductDialog(initialData: {
                          "name": widget.productName,
                          "code": "BH-507",
                          "material": "MC001",
                          "size": "445x280x295",
                          "id": "ID",
                          "od": "448x283x301",
                          "color": "Dark Green",
                          "weight": "439gm",
                          "ply": "3",
                          "cs": "130",
                          "gsm": "140",
                          "bf": "18",
                        });
                      }),
                      _coloredCircleButton(Icons.delete, Colors.red, () {
                        _showDeleteConfirmationDialog("product", () {
                          // handle delete
                        });
                      }),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1.5, color: Colors.blueGrey),
              const SizedBox(height: 20),
              _buildLabeledCard(
                headerLeft: "Partition - vertical",
                headerRightWidget: Row(
                  children: [
                    _coloredCircleButton(Icons.delete, Colors.red, () {
                      _showDeleteConfirmationDialog("partition", () {
                        // delete partition logic
                      });
                    }),
                    _coloredCircleButton(Icons.edit, Colors.blue, () {
                      _showPartitionDialog(initialData: {
                        "size": "47x32.5 /12",
                        "od": "275x298",
                        "deckle": "4",
                        "length": "3",
                        "type": "Vertical",
                        "ply": "3 Ply",
                        "weight": "40",
                        "gsm": "140",
                        "bf": "18",
                      });
                    }),
                  ],
                ),
                children: [
                  _buildTwoColumnRow("PARTITION SIZE", "PARTITION OD", isHeader: true),
                  _buildTwoColumnRow("47x32.5 /12", "275x298"),
                  _buildTwoColumnRow("DECKLE CUT", "LENGTH CUT", isHeader: true),
                  _buildTwoColumnRow("4", "3"),
                  _buildTwoColumnRow("PLY NO.", "PARTITION WEIGHT", isHeader: true),
                  _buildTwoColumnRow("3 Ply", "40"),
                  _buildTwoColumnRow("GSM", "BF", isHeader: true),
                  _buildTwoColumnRow("140", "18"),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledCard({
    required String headerLeft,
    String? headerRight,
    Widget? headerRightWidget,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headerLeft,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                headerRightWidget ??
                    Text(
                      headerRight ?? "",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    )
              ],
            ),
            const SizedBox(height: 12),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnRow(String left, String right, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.blue : Colors.black,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.blue : Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
