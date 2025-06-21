// screens/auth/set_password_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class SetPasswordScreen extends StatefulWidget {
  final String uid;
  final String token;

  const SetPasswordScreen({
    super.key,
    required this.uid,
    required this.token,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isSubmitting = false;

  void _resetPassword() async {
    final password = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Submit new password to backend
      // Example POST to /accounts/password/reset/confirm/ with { uid, token, new_password1, new_password2 }

      // await http.post(Uri.parse('https://yourdomain.com/accounts/password/reset/confirm/'), body: {
      //   "uid": widget.uid,
      //   "token": widget.token,
      //   "new_password1": password,
      //   "new_password2": confirmPassword,
      // });

      _showMessage("Password reset successful. Please login.");
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      _showMessage("Failed to reset password. Link may be expired.");
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
        title: const Text("Set New Password"),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.lock_outline, size: 80, color: Color(0xFF4A68F2)),
                  const SizedBox(height: 20),
                  const Text(
                    "Create a New Password",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your new password below.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  _buildPasswordField("New Password", newPasswordController),
                  const SizedBox(height: 12),
                  _buildPasswordField("Confirm New Password", confirmPasswordController),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _resetPassword,
                      style: _buttonStyle(),
                      child: isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text("Set Password", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                    child: const Text("Back to Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
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
