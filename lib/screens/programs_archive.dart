import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/side_drawer.dart';

class ProgramsArchiveScreen extends StatefulWidget {
  const ProgramsArchiveScreen({super.key});

  @override
  State<ProgramsArchiveScreen> createState() => _ProgramsArchiveScreenState();
}

class _ProgramsArchiveScreenState extends State<ProgramsArchiveScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _cardKey = GlobalKey();
  bool _hideButtons = false;

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
        title: const Text("Archive Programs"),
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
              RepaintBoundary(
                key: _cardKey,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("2025-06-20", style: TextStyle(color: Colors.grey)),
                            if (!_hideButtons)
                              Row(
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      side: const BorderSide(color: Colors.green),
                                    ),
                                    onPressed: () {
                                      _showRestoreConfirmationDialog(context, () {
                                        // Restore logic here
                                      });
                                    },
                                    child: const Icon(Icons.restore_from_trash, color: Colors.green, size: 20),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      side: const BorderSide(color: Colors.blueAccent),
                                    ),
                                    onPressed: _shareProgramCard,
                                    child: const Icon(Icons.share, color: Colors.blueAccent, size: 20),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        const Divider(height: 24),

                        _buildTwoColumnSection([
                          ["SIZE", "50X50/2"],
                          ["CODE", "CS-201"],
                          ["OD", "455X285X305"],
                          ["GSM", "140 (120) 2/18"],
                          ["COLOUR", "Black"],
                          ["WEIGHT", "450"],
                        ]),

                        const SizedBox(height: 16),
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

  Future<void> _showRestoreConfirmationDialog(BuildContext context, VoidCallback onRestore) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Restore Program"),
          content: const Text("Are you sure you want to restore this program?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onRestore();
              },
              child: const Text("Restore"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareProgramCard() async {
    setState(() => _hideButtons = true);
    await Future.delayed(const Duration(milliseconds: 100)); // let UI update

    try {
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/archive_program.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'Archived Program Details');
    } catch (e) {
      debugPrint("Error sharing archive program: $e");
    }

    setState(() => _hideButtons = false);
  }
}
