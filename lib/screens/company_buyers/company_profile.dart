import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:multi_box/screens/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../config.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  String? _tenantLogoUrl;
  final ScrollController scrollController = ScrollController();

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
      Fluttertoast.showToast(msg: "Invitation sent to \$email");
    } else {
      Fluttertoast.showToast(msg: "Failed to invite partner");
    }
  }

  void _invitePartnerDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Invite Partner"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: "Partner Email ID",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                invitePartner(email);
                Navigator.pop(context);
              }
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSliderTile(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()} days"),
        Slider(
          value: value,
          min: 10,
          max: 100,
          divisions: 90,
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A68F2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isLoggedIn ? const SideDrawer() : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Company Profile"),
        actions: isLoggedIn ? const [AppBarMenu()] : null,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollToTopWrapper(
              scrollController: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                child: isLoggedIn
                  ? Column(
                      children: [
                        if (!tenantExists) ...[
                          const Text("Join a Tenant Using Code", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _joinCodeController,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              labelText: "Enter 6 character code",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: acceptTenantInvite,
                            child: const Text("Join Tenant"),
                          ),
                          const Divider(height: 40),
                          const Text("Or create a new Tenant", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                        ],
                        buildTenantUI(),
                      ],
                    )
                  : const Center(child: Text("Please login to view your company profile."))
              ),
            ),
    );
  }

  Widget buildTenantUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: _tenantLogo != null
                    ? FileImage(_tenantLogo!)
                    : (_tenantLogoUrl != null
                        ? NetworkImage('$baseUrl$_tenantLogoUrl')
                        : const AssetImage('assets/logo.png')) as ImageProvider,
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _pickTenantLogo, child: const Text("Upload Tenant Logo")),
              const SizedBox(height: 10),
              Text(
                _tenantLogo != null ? _tenantLogo!.path.split('/').last : "No file chosen",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionTitle("Tenant Name and GST"),
        _buildTextField("Tenant Name", _tenantNameController),
        _buildTextField("Tenant GST", _tenantGSTController),
        const SizedBox(height: 24),
        _sectionTitle("Data Deletion Days"),
        _buildSliderTile("For Paper Reels", paperReelsDays, (v) => setState(() => paperReelsDays = v)),
        _buildSliderTile("For Program", programDays, (v) => setState(() => programDays = v)),
        _buildSliderTile("For Production", productionDays, (v) => setState(() => productionDays = v)),
        _buildSliderTile("For Purchase Order", purchaseOrderDays, (v) => setState(() => purchaseOrderDays = v)),
        const SizedBox(height: 24),
        _sectionTitle("Tenant Contacts"),
        _buildTextField("Email Id", _emailController),
        _buildTextField("Phone Number", _phoneController),
        const SizedBox(height: 24),
        _sectionTitle("Owner Settings"),
        Row(
          children: [
            Expanded(child: _buildTextField("Username", _usernameController, readOnly: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("Email Address", _ownerEmailController, readOnly: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField("First Name", _firstNameController)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("Last Name", _lastNameController)),
          ],
        ),
        const SizedBox(height: 24),
        _sectionTitle("Tenant Address"),
        _buildTextField("Plot No", _plotNoController),
        _buildTextField("Address Line 1", _address1Controller),
        _buildTextField("Address Line 2", _address2Controller),
        _buildTextField("City", _cityController),
        _buildTextField("State", _stateController),
        _buildTextField("Pincode", _pincodeController),
        _buildTextField("Country", _countryController),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveTenantDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A68F2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text("Save Tenant Information"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _invitePartnerDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF4A68F2)),
          ),
          child: const Text("Invite Partner", style: TextStyle(color: Color(0xFF4A68F2))),
        ),
        const SizedBox(height: 24),
        _sectionTitle("Invited Partners"),
        Wrap(
          spacing: 8,
          children: invitedPartners.map((name) => Chip(label: Text(name))).toList(),
        ),
        const SizedBox(height: 40),
      ],
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
