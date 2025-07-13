import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../widgets/side_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../config.dart';
import 'login.dart';
import 'dart:convert';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  final ScrollController scrollController = ScrollController();
  bool isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        _showMessage("No active session.");
        _redirectToLogin();
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/m-auth/logout/"),
        headers: {
          'Authorization': 'Token $authToken',
        },
      );

      // Clear token from local storage regardless of server response
      await prefs.remove('auth_token');
      await prefs.remove('pending_email');
      await prefs.remove('pending_session_token');

      if (response.statusCode == 200 || response.statusCode == 401) {
        _showMessage("Logged out successfully");
        _redirectToLogin();
      } else {
        final data = json.decode(response.body);
        final error = data.values.first;
        _showMessage(error is List ? error.first.toString() : error.toString());
      }
    } catch (e) {
      _showMessage("Logout failed: $e");
    } finally {
      if (mounted) setState(() => isLoggingOut = false);
    }
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
        title: const Text("Logout"),
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
                  const Icon(Icons.logout, size: 80, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  const Text(
                    "Are you sure you want to log out?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoggingOut ? null : _logout,
                      style: _buttonStyle(Colors.redAccent),
                      child: isLoggingOut
                          ? const CircularProgressIndicator()
                          : const Text("Logout", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
