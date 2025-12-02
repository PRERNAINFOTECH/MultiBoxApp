import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar_widget.dart';
import '../../config.dart';
import 'login.dart';

class VerifyEmailOtpScreen extends StatefulWidget {
  final String? email;
  final String? sessionToken;

  const VerifyEmailOtpScreen({super.key, this.email, this.sessionToken});

  @override
  State<VerifyEmailOtpScreen> createState() => _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends State<VerifyEmailOtpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isVerifying = false;
  String? sessionToken;

  @override
  void initState() {
    super.initState();
    _initializeEmailAndToken();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
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

  @override
  void dispose() {
    _animationController.dispose();
    otpController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = otpController.text.trim();
    final email = emailController.text.trim();

    setState(() => isVerifying = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/m-auth/verify-email/"),
        headers: {"Content-Type": "application/json"},
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

        _showSuccessSnackBar("Email verified successfully!");
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
          (route) => false,
        );
      } else {
        final error = data.values.first;
        _showErrorSnackBar(error is List ? error.first.toString() : error.toString());
      }
    } catch (e) {
      _showErrorSnackBar("Verification failed. Please try again.");
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty || sessionToken == null || sessionToken!.isEmpty) {
      _showErrorSnackBar("Missing email or session information.");
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
        _showSuccessSnackBar("Verification code resent successfully!");
      } else if (response.statusCode == 409) {
        _showInfoSnackBar("Verification is not pending. Already verified?");
      } else if (response.statusCode == 429) {
        _showWarningSnackBar("Too many requests. Please wait before trying again.");
      } else {
        final error = data.values.first;
        _showErrorSnackBar(error is List ? error.first.toString() : error.toString());
      }
    } catch (e) {
      _showErrorSnackBar("Error resending code. Please try again.");
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_outlined, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomAppBar(title: '', showBackButton: true),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          _buildIcon(),
                          const SizedBox(height: 32),
                          _buildHeaderText(),
                          const SizedBox(height: 32),
                          _buildEmailDisplay(),
                          const SizedBox(height: 16),
                          _buildOtpField(),
                          const SizedBox(height: 32),
                          _buildVerifyButton(),
                          const SizedBox(height: 16),
                          _buildResendButton(),
                          const SizedBox(height: 24),
                          _buildBackToLogin(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.mark_email_read_outlined,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Verify Your Email',
          style: AppTextStyles.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "We've sent a 6-digit verification code to your email. Enter it below to verify your account.",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.email_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              emailController.text,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: AppShadows.small,
      ),
      child: TextFormField(
        controller: otpController,
        maxLength: 6,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineMedium.copyWith(
          letterSpacing: 8,
          fontWeight: FontWeight.bold,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the verification code';
          }
          if (value.length != 6) {
            return 'Code must be 6 characters';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: '------',
          hintStyle: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textLight,
            letterSpacing: 8,
          ),
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMd,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMd,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isVerifying ? null : _verifyEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
        ),
        child: isVerifying
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify Email',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.verified_outlined, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildResendButton() {
    return TextButton.icon(
      onPressed: _resendVerificationEmail,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text("Didn't receive the code? Resend"),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBackToLogin() {
    return TextButton.icon(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      icon: const Icon(Icons.arrow_back_ios, size: 16),
      label: const Text('Back to Login'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
      ),
    );
  }
}
