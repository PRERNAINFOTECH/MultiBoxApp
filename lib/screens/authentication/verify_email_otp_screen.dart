import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import 'login.dart';

class VerifyEmailOtpScreen extends StatefulWidget {
  final String? email;
  final String? sessionToken;

  const VerifyEmailOtpScreen({super.key, this.email, this.sessionToken});

  @override
  State<VerifyEmailOtpScreen> createState() => _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends State<VerifyEmailOtpScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isVerifying = false;

  String? sessionToken;

  @override
  void initState() {
    super.initState();
    _initializeEmailAndToken();
  }

  Future<void> _initializeEmailAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = widget.email ?? prefs.getString('pending_email');
    final storedToken = widget.sessionToken ?? prefs.getString('pending_session_token');

    if (storedEmail != null) {
      emailController.text = storedEmail;
    }

    if (storedToken != null) {
      setState(() {
        sessionToken = storedToken;
      });
    }
  }

  Future<void> _verifyEmail() async {
    final otp = otpController.text.trim();
    final email = emailController.text.trim();

    if (email.isEmpty || otp.length != 6) {
      _showMessage("Enter valid email and 6-character code.");
      return;
    }

    setState(() => isVerifying = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/m-auth/verify-email/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "email": email,
          "code": otp,
        }),
      );

      final data = json.decode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pending_email');
        await prefs.remove('pending_session_token');

        _showMessage("Email verified successfully!");
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final error = data.values.first;
        _showMessage(error is List ? error.first.toString() : error.toString());
      }
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty || sessionToken == null || sessionToken!.isEmpty) {
      _showMessage("Missing email or session token.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/_allauth/app/v1/auth/email/verify/resend"),
        headers: {
          "Content-Type": "application/json",
          "X-Session-Token": sessionToken!,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_email', email);
        _showMessage("Verification code resent successfully!");
      } else if (response.statusCode == 409) {
        _showMessage("Verification is not pending. Already verified?");
      } else if (response.statusCode == 429) {
        _showMessage("Too many requests. Please wait before trying again.");
      } else {
        final error = data.values.first;
        _showMessage(error is List ? error.first.toString() : error.toString());
      }
    } catch (e) {
      _showMessage("Error resending code: $e");
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Verify Email"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0xFF4A68F2)),
                  const SizedBox(height: 20),
                  const Text("Enter Verification Code", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    "We've sent a 6-digit verification code to your email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    enabled: false, // 🔒 disable editing
                    decoration: InputDecoration(
                      hintText: "Your Email",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "Enter 6-character code",
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isVerifying ? null : _verifyEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Verify Email", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _resendVerificationEmail,
                    child: const Text("Resend Code"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
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
