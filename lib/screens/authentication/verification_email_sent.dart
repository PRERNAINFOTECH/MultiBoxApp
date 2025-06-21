import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';

class VerificationEmailSentScreen extends StatefulWidget {
  const VerificationEmailSentScreen({super.key});

  @override
  State<VerificationEmailSentScreen> createState() => _VerificationEmailSentScreenState();
}

class _VerificationEmailSentScreenState extends State<VerificationEmailSentScreen> {
  final ScrollController scrollController = ScrollController();
  bool isResending = false;

  void _resendVerificationEmail() async {
    setState(() => isResending = true);

    try {
      // Call your backend endpoint to resend email verification
      // Example: await http.post(Uri.parse('https://yourdomain.com/accounts/email/resend/'));

      _showMessage("Verification email resent. Please check your inbox.");
    } catch (e) {
      _showMessage("Failed to resend verification email.");
    } finally {
      setState(() => isResending = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.email_outlined, size: 80, color: Color(0xFF4A68F2)),
                  const SizedBox(height: 20),
                  const Text(
                    "Email Verification Sent",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Please check your email inbox and follow the link to verify your email address.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isResending ? null : _resendVerificationEmail,
                      icon: const Icon(Icons.refresh),
                      label: isResending
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : const Text("Resend Verification Email"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A68F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
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
}
