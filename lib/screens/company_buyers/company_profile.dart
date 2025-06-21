import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/custom_app_bar.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  final ScrollController scrollController = ScrollController();

  double paperReelsDays = 15;
  double programDays = 15;
  double productionDays = 15;
  double purchaseOrderDays = 15;

  final List<String> invitedPartners = ["Amar", "Upen", "Dhiren"];

  File? _tenantLogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Company Profile"),
        actions: const [
          AppBarMenu(),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                          : const AssetImage('assets/logo.png') as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickTenantLogo,
                      child: const Text("Upload Tenant Logo"),
                    ),
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
              _buildTextField("Tenant Name"),
              _buildTextField("Tenant GST"),
              const SizedBox(height: 24),
              _sectionTitle("Data Deletion Days"),
              _buildSliderTile("For Paper Reels", paperReelsDays, (value) {
                setState(() => paperReelsDays = value);
              }),
              _buildSliderTile("For Program", programDays, (value) {
                setState(() => programDays = value);
              }),
              _buildSliderTile("For Production", productionDays, (value) {
                setState(() => productionDays = value);
              }),
              _buildSliderTile("For Purchase Order", purchaseOrderDays, (value) {
                setState(() => purchaseOrderDays = value);
              }),
              const SizedBox(height: 24),
              _sectionTitle("Tenant Contacts"),
              _buildTextField("Email Id"),
              _buildTextField("Phone Number"),
              const SizedBox(height: 24),
              _sectionTitle("Owner Settings"),
              Row(
                children: [
                  Expanded(child: _buildTextField("Username", initialValue: "MultiBoxAdmin")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField("Email Address", initialValue: "admin@prernainfotec")),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField("First Name", initialValue: "MultiBox")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField("Last Name", initialValue: "Admin")),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle("Tenant Address"),
              _buildTextField("Plot No"),
              _buildTextField("Address Line 1"),
              _buildTextField("Address Line 2"),
              _buildTextField("City"),
              _buildTextField("State"),
              _buildTextField("Pincode"),
              _buildTextField("Country"),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: invitedPartners.map(
                      (name) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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

  Widget _buildTextField(String label, {String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: initialValue,
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

  Future<void> _pickTenantLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _tenantLogo = File(image.path));
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
                setState(() => invitedPartners.add(email));
                Navigator.pop(context);
              }
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }
}
