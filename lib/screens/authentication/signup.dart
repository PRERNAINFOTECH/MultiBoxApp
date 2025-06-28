import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';
import '../authentication/verify_email_otp_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void _signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/_allauth/app/v1/auth/signup"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "username": name,
          "email": email,
          "password": password,
        }),
      );

      final data = json.decode(response.body);

      // ✅ Check if verify_email is pending in 401 response
      final isVerificationPending = response.statusCode == 401 &&
          data is Map &&
          data['data'] != null &&
          data['data']['flows'] is List &&
          (data['data']['flows'] as List).any((flow) =>
              flow['id'] == 'verify_email' && flow['is_pending'] == true);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          isVerificationPending) {
        if (!mounted) return;

        _showMessage("Signup successful! Please check your email to verify.");
        final sessionToken = data['meta']?['session_token'];
        // ✅ Navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailOtpScreen(email: email, sessionToken: sessionToken,),
          ),
        );
      } else {
        if (!mounted) return;

        // ✅ Show error from API
        if (data is Map && data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List) {
            _showMessage(firstValue.first.toString());
          } else if (firstValue is Map && firstValue.containsKey('detail')) {
            _showMessage(firstValue['detail'].toString());
          } else {
            _showMessage(firstValue.toString());
          }
        } else {
          _showMessage("Signup failed. Please try again.");
        }
      }
    } catch (e) {
      if (mounted) _showMessage("Error occurred: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Sign Up"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text("Create Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _buildInput("Name", nameController),
                  const SizedBox(height: 12),
                  _buildInput("Email", emailController),
                  const SizedBox(height: 12),
                  _buildInput("Password", passwordController, obscureText: true),
                  const SizedBox(height: 12),
                  _buildInput("Confirm Password", confirmPasswordController, obscureText: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _signup,
                      style: _buttonStyle(),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Sign Up", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                    child: const Text("Already have an account? Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4A68F2),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
