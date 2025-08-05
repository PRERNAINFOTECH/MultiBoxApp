import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../config.dart';
import 'set_password.dart';
import 'login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController emailController = TextEditingController();
  bool isSubmitting = false;

  void _submitResetRequest() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage("Please enter your email address.");
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/m-auth/password-reset/send-otp/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (!mounted) return;
        _showMessage("Password reset OTP sent to your email.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SetPasswordScreen(email: email)),
        );
      } else {
        final error = data['error'] ?? data.values.first;
        _showMessage(error.toString());
      }
    } catch (e) {
      _showMessage("Failed to send reset OTP. Please try again.");
    } finally {
      setState(() => isSubmitting = false);
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
        title: const Text("Forgot Password"),
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
                  const Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Color(0xFF4A68F2),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Reset Your Password",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your email to receive a password reset OTP.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitResetRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Send OTP",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text("Back to Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
