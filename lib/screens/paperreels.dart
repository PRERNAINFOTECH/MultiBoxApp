import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../config.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bar_widget.dart';

class PaperReelsScreen extends StatefulWidget {
  const PaperReelsScreen({super.key});

  @override
  State<PaperReelsScreen> createState() => _PaperReelsScreenState();
}

class _PaperReelsScreenState extends State<PaperReelsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  
  List<Map<String, dynamic>> reels = [];
  int usedCount = 0;
  int unusedCount = 0;
  int totalPages = 1;
  int page = 1;
  String searchQuery = "";
  bool _loading = true;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fetchPaperReels();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchPaperReels({int? gotoPage, String? query}) async {
    setState(() {
      _loading = true;
    });

    final authToken = await _getToken();
    String url;
    int newPage = gotoPage ?? page;
    String q = query ?? searchQuery;

    if (q.isNotEmpty) {
      url = '$baseUrl/corrugation/paper-reels/search/?q=${Uri.encodeComponent(q)}';
    } else {
      url = '$baseUrl/corrugation/paper-reels/?page=$newPage&limit=20';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Token $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (q.isNotEmpty) {
            reels = List<Map<String, dynamic>>.from(data['results'] ?? []);
            usedCount = 0;
            unusedCount = 0;
            totalPages = 1;
          } else {
            reels = List<Map<String, dynamic>>.from(data['reels'] ?? []);
            usedCount = data['used_reels'] ?? 0;
            unusedCount = data['unused_reels'] ?? 0;
            totalPages = data['total_pages'] ?? 1;
            page = data['current_page'] ?? newPage;
          }
          _loading = false;
        });
        _animationController.forward(from: 0);
      } else {
        setState(() => _loading = false);
        if (!mounted) return;
        _showErrorSnackBar('Failed to fetch reels.');
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      _showErrorSnackBar('Connection error. Please try again.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _markAsUsed(int id) async {
    final authToken = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/corrugation/paper-reels/$id/'),
      headers: {'Authorization': 'Token $authToken'},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      _fetchPaperReels();
      _showSuccessSnackBar('Marked as used.');
    } else {
      _showErrorSnackBar('Failed to mark as used.');
    }
  }

  Future<void> _restoreReel(int id) async {
    final authToken = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/corrugation/paper-reels/$id/restore/'),
      headers: {'Authorization': 'Token $authToken'},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      _fetchPaperReels();
      _showSuccessSnackBar('Reel restored.');
    } else {
      _showErrorSnackBar('Failed to restore reel.');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showAddReelDialog() async {
    final formKey = GlobalKey<FormState>();
    var supplierCtrl = TextEditingController();
    var reelNumberCtrl = TextEditingController();
    var bfCtrl = TextEditingController();
    var gsmCtrl = TextEditingController();
    var sizeCtrl = TextEditingController();
    var weightCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_circle_outline, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Upload a Reel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _buildTextField(supplierCtrl, 'Supplier', Icons.business),
                        const SizedBox(height: 16),
                        _buildTextField(reelNumberCtrl, 'Reel Number', Icons.numbers, isNumber: true),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(bfCtrl, 'BF', Icons.straighten, isNumber: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(gsmCtrl, 'GSM', Icons.scale, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(sizeCtrl, 'Size', Icons.square_foot, isNumber: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(weightCtrl, 'Weight', Icons.fitness_center, isNumber: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final token = await _getToken();
                          final resp = await http.post(
                            Uri.parse('$baseUrl/corrugation/paper-reels/'),
                            headers: {
                              'Authorization': 'Token $token',
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode({
                              "reel_number": reelNumberCtrl.text,
                              "bf": bfCtrl.text,
                              "gsm": gsmCtrl.text,
                              "size": sizeCtrl.text,
                              "weight": weightCtrl.text,
                              "supplier": supplierCtrl.text,
                            }),
                          );
                          if (!ctx.mounted) return;
                          if (resp.statusCode == 201) {
                            Navigator.pop(ctx);
                            _fetchPaperReels();
                            _showSuccessSnackBar('Reel uploaded!');
                          } else {
                            _showErrorSnackBar('Error: ${resp.body}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Upload'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Future<void> _showBulkUploadDialog() async {
    final formKey = GlobalKey<FormState>();
    var supplierCtrl = TextEditingController();
    PlatformFile? selectedFile;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.upload_file, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Bulk Upload Reels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _buildTextField(supplierCtrl, 'Supplier', Icons.business),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['xlsx', 'xls'],
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setDialogState(() {
                                selectedFile = result.files.first;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedFile != null ? AppColors.success : AppColors.border,
                                width: selectedFile != null ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: selectedFile != null ? AppColors.success : AppColors.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedFile?.name ?? 'Tap to select Excel file',
                                  style: TextStyle(
                                    color: selectedFile != null ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: selectedFile != null ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate() || selectedFile == null) {
                              return;
                            }
                            final authToken = await _getToken();
                            final request = http.MultipartRequest(
                              'POST',
                              Uri.parse('$baseUrl/corrugation/paper-reels/bulk-upload/'),
                            );
                            request.headers['Authorization'] = 'Token $authToken';
                            request.files.add(
                              await http.MultipartFile.fromPath(
                                'reel_file',
                                selectedFile!.path!,
                              ),
                            );
                            request.fields['supplier'] = supplierCtrl.text;
                            final response = await request.send();
                            final respStr = await response.stream.bytesToString();
                            if (!ctx.mounted) return;
                            if (response.statusCode == 200) {
                              Navigator.pop(ctx);
                              _fetchPaperReels();
                              _showSuccessSnackBar('Bulk upload successful!');
                            } else {
                              _showErrorSnackBar('Bulk upload failed: $respStr');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditReelDialog(Map<String, dynamic> reel) async {
    final formKey = GlobalKey<FormState>();
    var supplierCtrl = TextEditingController(text: reel["supplier"] ?? "");
    var reelNumberCtrl = TextEditingController(text: "${reel["reel_number"]}");
    var bfCtrl = TextEditingController(text: "${reel["bf"]}");
    var gsmCtrl = TextEditingController(text: "${reel["gsm"]}");
    var sizeCtrl = TextEditingController(text: "${reel["size"]}");
    var weightCtrl = TextEditingController(text: "${reel["weight"]}");

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Paper Reel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _buildTextField(supplierCtrl, 'Supplier', Icons.business),
                        const SizedBox(height: 16),
                        _buildTextField(reelNumberCtrl, 'Reel Number', Icons.numbers, isNumber: true),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(bfCtrl, 'BF', Icons.straighten, isNumber: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(gsmCtrl, 'GSM', Icons.scale, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(sizeCtrl, 'Size', Icons.square_foot, isNumber: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(weightCtrl, 'Weight', Icons.fitness_center, isNumber: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final token = await _getToken();
                          final resp = await http.patch(
                            Uri.parse('$baseUrl/corrugation/paper-reels/${reel["id"]}/'),
                            headers: {
                              'Authorization': 'Token $token',
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode({
                              "reel_number": reelNumberCtrl.text,
                              "bf": bfCtrl.text,
                              "gsm": gsmCtrl.text,
                              "size": sizeCtrl.text,
                              "weight": weightCtrl.text,
                              "supplier": supplierCtrl.text,
                            }),
                          );
                          if (!ctx.mounted) return;
                          if (resp.statusCode == 200) {
                            Navigator.pop(ctx);
                            _fetchPaperReels();
                            _showSuccessSnackBar('Reel updated!');
                          } else {
                            _showErrorSnackBar('Error: ${resp.body}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Paper Reels'),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _fetchPaperReels(),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                FadeInWidget(
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildSearchBar(),
                                ),
                                const SizedBox(height: 16),
                                FadeInWidget(
                                  delay: const Duration(milliseconds: 200),
                                  child: _buildStatsRow(),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        if (reels.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No paper reels found',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap + to add a new reel',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final reel = reels[index];
                                  return SlideInWidget(
                                    delay: Duration(milliseconds: 100 + (index * 50)),
                                    child: _buildReelCard(reel),
                                  );
                                },
                                childCount: reels.length,
                              ),
                            ),
                          ),
                        if (totalPages > 1)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildPagination(),
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleInWidget(
        delay: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: _showAddReelDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add),
          label: const Text('Add Reel'),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reels...',
                hintStyle: TextStyle(color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) {
                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () {
                    if (!mounted) return;
                    setState(() {
                      searchQuery = val.trim();
                      page = 1;
                    });
                    _fetchPaperReels();
                  },
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.upload_file, color: AppColors.primary),
              tooltip: 'Bulk Upload',
              onPressed: _showBulkUploadDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white.withValues(alpha: 0.8), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Unused',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$unusedCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.white.withValues(alpha: 0.8), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Used',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$usedCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReelCard(Map<String, dynamic> reel) {
    final bool isUsed = reel['is_used'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
        border: Border.all(
          color: isUsed ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditReelDialog(reel),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUsed ? AppColors.errorLight : AppColors.primaryLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: isUsed ? AppColors.error : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reel #${reel['reel_number']}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: isUsed ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reel['supplier'] ?? 'Unknown Supplier',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUsed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Used',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildReelStat('BF', '${reel['bf']}'),
                    _buildReelStat('GSM', '${reel['gsm']}'),
                    _buildReelStat('Size', '${reel['size']}'),
                    _buildReelStat('Weight', '${reel['weight']}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isUsed) ...[
                      TextButton.icon(
                        onPressed: () => _showEditReelDialog(reel),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _markAsUsed(reel['id']),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Mark Used'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ] else
                      TextButton.icon(
                        onPressed: () => _restoreReel(reel['id']),
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('Restore'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReelStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 1
                ? () {
                    setState(() => page--);
                    _fetchPaperReels();
                  }
                : null,
            color: page > 1 ? AppColors.primary : AppColors.textLight,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Page $page of $totalPages',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: page < totalPages
                ? () {
                    setState(() => page++);
                    _fetchPaperReels();
                  }
                : null,
            color: page < totalPages ? AppColors.primary : AppColors.textLight,
          ),
        ],
      ),
    );
  }
}
