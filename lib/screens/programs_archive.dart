import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/scroll_to_top_wrapper.dart';

class ProgramsArchiveScreen extends StatefulWidget {
  const ProgramsArchiveScreen({super.key});

  @override
  State<ProgramsArchiveScreen> createState() => _ProgramsArchiveScreenState();
}

class _ProgramsArchiveScreenState extends State<ProgramsArchiveScreen> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> programs = [];
  List<dynamic> filteredPrograms = [];
  List<GlobalKey> _cardKeys = [];
  List<bool> _hideButtonsList = [];
  bool _loading = true;
  String? authToken;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchArchivedPrograms();
  }

  Future<void> _fetchArchivedPrograms() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/programs/archive/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      setState(() {
        programs = body['programs'] ?? [];
        filteredPrograms = programs;
        _cardKeys = List.generate(filteredPrograms.length, (_) => GlobalKey());
        _hideButtonsList = List.generate(filteredPrograms.length, (_) => false);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _filterPrograms(String query) {
    setState(() {
      searchQuery = query;
      filteredPrograms = programs.where((prog) {
        return (prog['product_name']?.toLowerCase() ?? '')
                .contains(query.toLowerCase()) ||
            (prog['box_no']?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
            (prog['material_code']?.toLowerCase() ?? '')
                .contains(query.toLowerCase());
      }).toList();
      _cardKeys = List.generate(filteredPrograms.length, (_) => GlobalKey());
      _hideButtonsList = List.generate(filteredPrograms.length, (_) => false);
    });
  }

  Future<void> _restoreProgram(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final resp = await http.patch(
      Uri.parse('$baseUrl/corrugation/programs/restore/$id/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: jsonEncode({'active': true}),
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Program restored!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      await _fetchArchivedPrograms();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to restore program."),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _shareProgramCard(GlobalKey cardKey, int idx) async {
    setState(() => _hideButtonsList[idx] = true);
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      RenderRepaintBoundary boundary =
          cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/archive_program_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'Archived Program Details');
    } catch (e) {
      debugPrint("Error sharing archive program: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to share image."),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    setState(() => _hideButtonsList[idx] = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Archived Programs'),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : ScrollToTopWrapper(
                    scrollController: _scrollController,
                    child: RefreshIndicator(
                      onRefresh: _fetchArchivedPrograms,
                      color: AppColors.primary,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                FadeInWidget(
                                  child: _buildSearchBar(),
                                ),
                                const SizedBox(height: 12),
                                FadeInWidget(
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildArchiveInfoBanner(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (filteredPrograms.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final cardKey = _cardKeys.length > index
                                      ? _cardKeys[index]
                                      : GlobalKey();
                                  final hideBtns = _hideButtonsList.length > index
                                      ? _hideButtonsList[index]
                                      : false;
                                  return SlideInWidget(
                                    delay: Duration(milliseconds: 100 + (index * 50)),
                                    child: _buildProgramCard(
                                      filteredPrograms[index],
                                      cardKey,
                                      index,
                                      hideBtns,
                                    ),
                                  );
                                },
                                childCount: filteredPrograms.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: TextField(
        onChanged: _filterPrograms,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search archived programs...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildArchiveInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.archive_outlined,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These programs have been archived. Tap the restore button to bring them back.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty ? 'No programs found' : 'No archived programs',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Programs you archive will appear here',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(
    dynamic prog,
    GlobalKey cardKey,
    int index,
    bool hideButtons,
  ) {
    final partitions = prog['partitions'] ?? [];

    return RepaintBoundary(
      key: cardKey,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.medium,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.archive,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    prog['product_name'] ?? '',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Archived',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Qty: ${prog['program_quantity'] ?? ''}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!hideButtons)
                        Row(
                          children: [
                            _buildActionButton(
                              Icons.restore,
                              AppColors.success,
                              () => _showRestoreConfirmationDialog(
                                context,
                                () => _restoreProgram(prog['id']),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              Icons.share,
                              AppColors.primary,
                              () => _shareProgramCard(cardKey, index),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.textLight, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        prog['program_date'] ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTwoColumnGrid([
                    ['SIZE', prog['size'] ?? ''],
                    ['CODE', prog['material_code'] ?? ''],
                    ['OD', '${prog['outer_length'] ?? ''}X${prog['outer_breadth'] ?? ''}X${prog['outer_depth'] ?? ''}'],
                    ['GSM', prog['gsm']?.toString() ?? ''],
                    ['COLOUR', prog['color'] ?? ''],
                    ['WEIGHT', prog['weight']?.toString() ?? ''],
                  ]),
                  if ((prog['program_notes'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Notes',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prog['program_notes'],
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (partitions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Partitions',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...((partitions as List).asMap().entries.map((entry) {
                      final pidx = entry.key + 1;
                      final part = entry.value;
                      return _buildPartitionCard(pidx, part);
                    })),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildTwoColumnGrid(List<List<String>> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3.0,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      children: items.map((item) => _buildDetailItem(item[0], item[1])).toList(),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '-' : value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPartitionCard(int index, dynamic part) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Partition $index',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  part['partition_type']?.toString() ?? '',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTwoColumnGrid([
            ['SIZE', part['partition_size']?.toString() ?? ''],
            ['OD', part['partition_od']?.toString() ?? ''],
            ['DECKLE CUT', part['deckle_cut']?.toString() ?? ''],
            ['LENGTH CUT', part['length_cut']?.toString() ?? ''],
            ['PLY', part['ply_no']?.toString() ?? ''],
            ['WEIGHT', part['partition_weight']?.toString() ?? ''],
          ]),
        ],
      ),
    );
  }

  Future<void> _showRestoreConfirmationDialog(
    BuildContext context,
    VoidCallback onRestore,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restore, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Restore Program',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to restore this program? It will be moved back to your active programs.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onRestore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );
  }
}
