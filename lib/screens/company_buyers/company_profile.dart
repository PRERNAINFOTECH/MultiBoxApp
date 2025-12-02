import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:multi_box/screens/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';
import '../../config.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  String? _tenantLogoUrl;
  final ScrollController _scrollController = ScrollController();

  final _tenantNameController = TextEditingController();
  final _tenantGSTController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _usernameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _plotNoController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _joinCodeController = TextEditingController();

  double paperReelsDays = 30;
  double programDays = 30;
  double productionDays = 30;
  double purchaseOrderDays = 30;

  File? _tenantLogo;
  List<String> invitedPartners = [];
  bool isLoading = false;
  String? authToken;
  bool tenantExists = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    loadAndFetch();
  }

  Future<void> loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');

    if (!mounted) return;

    if (authToken == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    setState(() => isLoggedIn = true);
    await fetchTenantDetails();
  }

  Future<void> fetchTenantDetails() async {
    setState(() => isLoading = true);

    final url = Uri.parse('$baseUrl/tenant/register/');
    final response = await http.get(url, headers: {
      'Authorization': 'Token $authToken',
    });
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      tenantExists = true;

      _tenantNameController.text = data['tenant_info']['name'] ?? '';
      _tenantGSTController.text = data['tenant_info']['tenant_gst_number'] ?? '';
      _emailController.text = data['tenant_info']['email'] ?? '';
      _phoneController.text = data['tenant_info']['phone'] ?? '';
      _tenantLogoUrl = data['tenant_info']['tenant_logo'];
      _usernameController.text = data['user_info']['username'] ?? '';
      _ownerEmailController.text = data['user_info']['email'] ?? '';
      _firstNameController.text = data['user_info']['first_name'] ?? '';
      _lastNameController.text = data['user_info']['last_name'] ?? '';

      final address = data['tenant_address'];
      if (address != null) {
        _plotNoController.text = address['plot_no'] ?? '';
        _address1Controller.text = address['address_line_1'] ?? '';
        _address2Controller.text = address['address_line_2'] ?? '';
        _cityController.text = address['city'] ?? '';
        _stateController.text = address['state'] ?? '';
        _pincodeController.text = address['pincode'] ?? '';
        _countryController.text = address['country'] ?? '';
      }

      final genInfo = data['tenant_general_info'];
      if (genInfo != null) {
        paperReelsDays = genInfo['reels_delete_before_days']?.toDouble() ?? 30;
        programDays = genInfo['program_delete_before_days']?.toDouble() ?? 30;
        productionDays = genInfo['production_delete_before_days']?.toDouble() ?? 30;
        purchaseOrderDays = genInfo['purchase_order_delete_before_days']?.toDouble() ?? 30;
      }

      invitedPartners = List<String>.from(
        data['tenant_partners'].map((p) => "${p['first_name']} ${p['last_name']}") ?? [],
      );
    } else {
      _usernameController.text = data['user_info']['username'] ?? '';
      _ownerEmailController.text = data['user_info']['email'] ?? '';
      tenantExists = false;
    }

    setState(() => isLoading = false);
  }

  Future<void> acceptTenantInvite() async {
    final code = _joinCodeController.text.trim();
    if (code.length != 6) {
      Fluttertoast.showToast(msg: "Please enter a valid 6 character code.");
      return;
    }

    final url = Uri.parse('$baseUrl/tenant/accept-invite/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"code": code}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Joined tenant successfully!");
      fetchTenantDetails();
    } else {
      Fluttertoast.showToast(msg: "Failed to join tenant. ${response.body}");
    }
  }

  Future<void> invitePartner(String email) async {
    final url = Uri.parse('$baseUrl/tenant/invite/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      setState(() => invitedPartners.add(email));
      Fluttertoast.showToast(msg: "Invitation sent to $email");
    } else {
      Fluttertoast.showToast(msg: "Failed to invite partner");
    }
  }

  void _invitePartnerDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_add, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Invite Partner', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: emailController,
                label: 'Partner Email ID',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.textLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: 'Invite',
                      onPressed: () {
                        final email = emailController.text.trim();
                        if (email.isNotEmpty) {
                          invitePartner(email);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: readOnly ? AppColors.background : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: readOnly ? null : AppShadows.small,
            ),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              style: AppTextStyles.bodyMedium.copyWith(
                color: readOnly ? AppColors.textLight : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(String label, double value, ValueChanged<double> onChanged, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.toInt()} days',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 10,
              max: 100,
              divisions: 90,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isLoggedIn ? const AppDrawer() : null,
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Company Profile'),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : ScrollToTopWrapper(
                    scrollController: _scrollController,
                    child: RefreshIndicator(
                      onRefresh: fetchTenantDetails,
                      color: AppColors.primary,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: isLoggedIn
                                  ? Column(
                                      children: [
                                        if (!tenantExists) ...[
                                          FadeInWidget(child: _buildJoinTenantCard()),
                                          const SizedBox(height: 24),
                                        ],
                                        FadeInWidget(
                                          delay: const Duration(milliseconds: 100),
                                          child: _buildTenantUI(),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        'Please login to view your company profile.',
                                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                                      ),
                                    ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinTenantCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.group_add, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Join a Tenant', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Enter a 6 character code to join an existing tenant',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _joinCodeController,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: AppTextStyles.headlineSmall.copyWith(color: AppColors.textLight, letterSpacing: 8),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: 'Join Tenant',
            onPressed: acceptTenantInvite,
            icon: Icons.login,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: AppTextStyles.caption),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Create a new Tenant below', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildTenantUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogoSection(),
        _sectionTitle('Company Information', Icons.business),
        _buildTextField('Tenant Name', _tenantNameController, icon: Icons.business),
        _buildTextField('Tenant GST', _tenantGSTController, icon: Icons.receipt_long),
        _sectionTitle('Data Retention Settings', Icons.schedule),
        _buildSliderTile('Paper Reels', paperReelsDays, (v) => setState(() => paperReelsDays = v), Icons.inventory),
        _buildSliderTile('Programs', programDays, (v) => setState(() => programDays = v), Icons.list_alt),
        _buildSliderTile('Productions', productionDays, (v) => setState(() => productionDays = v), Icons.precision_manufacturing),
        _buildSliderTile('Purchase Orders', purchaseOrderDays, (v) => setState(() => purchaseOrderDays = v), Icons.receipt_long),
        _sectionTitle('Contact Information', Icons.contact_phone),
        _buildTextField('Email Address', _emailController, icon: Icons.email_outlined),
        _buildTextField('Phone Number', _phoneController, icon: Icons.phone_outlined),
        _sectionTitle('Owner Settings', Icons.person),
        Row(
          children: [
            Expanded(child: _buildTextField('Username', _usernameController, readOnly: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Email', _ownerEmailController, readOnly: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('First Name', _firstNameController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Last Name', _lastNameController)),
          ],
        ),
        _sectionTitle('Address', Icons.location_on),
        _buildTextField('Plot No', _plotNoController),
        _buildTextField('Address Line 1', _address1Controller),
        _buildTextField('Address Line 2', _address2Controller),
        Row(
          children: [
            Expanded(child: _buildTextField('City', _cityController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('State', _stateController)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('Pincode', _pincodeController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Country', _countryController)),
          ],
        ),
        const SizedBox(height: 24),
        GradientButton(
          text: 'Save Tenant Information',
          onPressed: saveTenantDetails,
          icon: Icons.save,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _invitePartnerDialog,
          icon: Icon(Icons.person_add, color: AppColors.primary),
          label: Text('Invite Partner', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (invitedPartners.isNotEmpty) ...[
          _sectionTitle('Invited Partners', Icons.group),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: invitedPartners
                .map((name) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(name, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 4),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: _tenantLogo != null
                      ? FileImage(_tenantLogo!)
                      : (_tenantLogoUrl != null
                          ? NetworkImage('$baseUrl$_tenantLogoUrl')
                          : const AssetImage('assets/logo.png')) as ImageProvider,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.small,
                ),
                child: InkWell(
                  onTap: _pickTenantLogo,
                  child: Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _tenantNameController.text.isNotEmpty ? _tenantNameController.text : 'Company Name',
            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _tenantLogo != null ? _tenantLogo!.path.split('/').last : 'Tap to upload logo',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTenantLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _tenantLogo = File(image.path));
    }
  }

  Future<void> saveTenantDetails() async {
    final url = Uri.parse('$baseUrl/tenant/register/');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Token $authToken'
      ..fields['tenant_name'] = _tenantNameController.text
      ..fields['tenant_gst_number'] = _tenantGSTController.text
      ..fields['tenant_email'] = _emailController.text
      ..fields['tenant_phone'] = _phoneController.text
      ..fields['first_name'] = _firstNameController.text
      ..fields['last_name'] = _lastNameController.text
      ..fields['tenant_plot_no'] = _plotNoController.text
      ..fields['tenant_address_line_1'] = _address1Controller.text
      ..fields['tenant_address_line_2'] = _address2Controller.text
      ..fields['tenant_city'] = _cityController.text
      ..fields['tenant_state'] = _stateController.text
      ..fields['tenant_pincode'] = _pincodeController.text
      ..fields['tenant_country'] = _countryController.text
      ..fields['tenant_reels_delete_before_days'] = paperReelsDays.toInt().toString()
      ..fields['tenant_program_delete_before_days'] = programDays.toInt().toString()
      ..fields['tenant_production_delete_before_days'] = productionDays.toInt().toString()
      ..fields['tenant_purchase_order_delete_before_days'] = purchaseOrderDays.toInt().toString();

    if (_tenantLogo != null) {
      request.files.add(await http.MultipartFile.fromPath('tenant_logo', _tenantLogo!.path));
    }

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 201) {
      Fluttertoast.showToast(msg: "Tenant info saved successfully!");
      await fetchTenantDetails();
    } else {
      Fluttertoast.showToast(msg: "Failed to save tenant info: ${responseData.body}");
    }
  }
}
