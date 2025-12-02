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

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> programs = [];
  List<dynamic> filteredPrograms = [];
  List<dynamic> productNames = [];
  List<GlobalKey> _cardKeys = [];
  List<bool> _hideButtonsList = [];
  bool _loading = true;
  String? authToken;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchPrograms();
  }

  Future<void> _fetchPrograms() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final resp = await http.get(
      Uri.parse('$baseUrl/corrugation/programs/'),
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
        productNames = body['products'] ?? [];
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
      _hideButtonsList =
          List.generate(filteredPrograms.length, (_) => false);
    });
  }

  Future<void> _deleteProgram(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final resp = await http.delete(
      Uri.parse('$baseUrl/corrugation/programs/$id/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );
    if (!mounted) return;
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Program deleted!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      await _fetchPrograms();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to delete program."),
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
          '${directory.path}/program_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'Program Details');
    } catch (e) {
      debugPrint("Error sharing program: $e");
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
          const GradientAppBar(title: 'Programs'),
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
                      onRefresh: _fetchPrograms,
                      color: AppColors.primary,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: FadeInWidget(
                              child: _buildSearchBar(),
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
                            child: SizedBox(height: 80),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleInWidget(
        delay: const Duration(milliseconds: 400),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddProgramDialog(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Program'),
          elevation: 4,
        ),
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
          hintText: 'Search programs...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty ? 'No programs found' : 'No programs yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Add a program to get started',
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
                gradient: AppColors.primaryGradient,
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
                            Text(
                              prog['product_name'] ?? '',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Qty: ${prog['program_quantity'] ?? ''}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!hideButtons)
                        Row(
                          children: [
                            _buildHeaderIconButton(
                              Icons.edit,
                              () => _showEditProgramDialog(context, program: prog),
                            ),
                            _buildHeaderIconButton(
                              Icons.share,
                              () => _shareProgramCard(cardKey, index),
                            ),
                            _buildHeaderIconButton(
                              Icons.delete,
                              () => _showDeleteConfirmationDialog(
                                context,
                                () => _deleteProgram(prog['id']),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        prog['program_date'] ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
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

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
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

  Future<void> _showAddProgramDialog(BuildContext context) async {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String? selectedProduct =
        productNames.isNotEmpty ? productNames[0].toString() : null;
    DateTime? selectedDate = DateTime.now();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add New Program',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildDialogDropdown(
                              label: 'Product Name',
                              value: selectedProduct,
                              items: productNames.map((e) => e.toString()).toList(),
                              onChanged: (val) => setState(() => selectedProduct = val),
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: quantityController,
                              label: 'Program Quantity',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(
                              label: 'Program Date',
                              date: selectedDate,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: notesController,
                              label: 'Program Notes',
                              icon: Icons.note,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDialogActions(
                      onCancel: () => Navigator.pop(dialogContext),
                      onSave: () => _saveProgram(
                        dialogContext,
                        selectedProduct,
                        quantityController.text,
                        selectedDate,
                        notesController.text,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditProgramDialog(
    BuildContext context, {
    required dynamic program,
  }) async {
    final TextEditingController quantityController = TextEditingController(
      text: program['program_quantity'].toString(),
    );
    final TextEditingController notesController = TextEditingController(
      text: program['program_notes'] ?? '',
    );
    String? selectedProduct = program['product_name'];
    DateTime? selectedDate = program['program_date'] != null
        ? DateTime.tryParse(program['program_date'])
        : DateTime.now();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Program',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildDialogDropdown(
                              label: 'Product Name',
                              value: selectedProduct,
                              items: productNames.map((e) => e.toString()).toList(),
                              onChanged: (val) => setState(() => selectedProduct = val),
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: quantityController,
                              label: 'Program Quantity',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(
                              label: 'Program Date',
                              date: selectedDate,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDialogTextField(
                              controller: notesController,
                              label: 'Program Notes',
                              icon: Icons.note,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDialogActions(
                      onCancel: () => Navigator.pop(dialogContext),
                      onSave: () => _updateProgram(
                        dialogContext,
                        program['id'],
                        selectedProduct,
                        quantityController.text,
                        selectedDate,
                        notesController.text,
                      ),
                      saveLabel: 'Save Changes',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDialogTextField({
    TextEditingController? controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textLight, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignLabelWithHint: maxLines != null && maxLines > 1,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.textLight, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: 2),
                Text(
                  date != null
                      ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                      : 'Select Date',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogActions({
    required VoidCallback onCancel,
    required VoidCallback onSave,
    String saveLabel = 'Save',
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(saveLabel),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProgram(
    BuildContext dialogContext,
    String? product,
    String quantity,
    DateTime? date,
    String notes,
  ) async {
    if (product == null || quantity.isEmpty || date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final postData = {
      'product_name': product,
      'program_quantity': quantity,
      'program_date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'program_notes': notes,
    };

    final resp = await http.post(
      Uri.parse('$baseUrl/corrugation/programs/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: jsonEncode(postData),
    );

    if (!dialogContext.mounted) return;
    if (resp.statusCode == 201) {
      Navigator.pop(dialogContext);
      await _fetchPrograms();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Program added!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      String msg = 'Failed to add program.';
      try {
        msg = jsonDecode(resp.body)['detail'] ?? msg;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _updateProgram(
    BuildContext dialogContext,
    int id,
    String? product,
    String quantity,
    DateTime? date,
    String notes,
  ) async {
    if (product == null || quantity.isEmpty || date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final postData = {
      'product_name': product,
      'program_quantity': quantity,
      'program_date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'program_notes': notes,
    };

    final resp = await http.patch(
      Uri.parse('$baseUrl/corrugation/programs/$id/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
      body: jsonEncode(postData),
    );

    if (!dialogContext.mounted) return;
    if (resp.statusCode == 200) {
      Navigator.pop(dialogContext);
      await _fetchPrograms();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Program updated!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      String msg = 'Failed to update program.';
      try {
        msg = jsonDecode(resp.body)['detail'] ?? msg;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    VoidCallback onDelete,
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Program',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this program? This action cannot be undone.',
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
                onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
