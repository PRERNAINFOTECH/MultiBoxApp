import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/company_buyers/company_profile.dart';
import '../screens/company_buyers/buyers_list.dart';
import '../screens/plan_support/plans_and_pricing.dart';
import '../screens/plan_support/contact_support.dart';
import '../screens/information/about_us.dart';
import '../screens/information/privacy_policy.dart';
import '../screens/information/terms_and_conditions.dart';
import '../screens/information/refund_policy.dart';
import '../screens/information/faqs.dart';
import '../screens/authentication/login.dart';
import '../screens/authentication/signup.dart';
import '../screens/authentication/logout.dart';
import '../screens/authentication/verify_email_otp_screen.dart';
import '../screens/authentication/forgot_password.dart';
import '../screens/authentication/set_password.dart';
import '../config.dart'; // Ensure baseUrl is imported

class AppBarMenu extends StatelessWidget {
  const AppBarMenu({super.key});

  Future<Map<String, dynamic>> _getTenantLogoAndAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    String? tenantLogoUrl;
    bool isLoggedIn = authToken != null;

    if (isLoggedIn) {
      final url = Uri.parse('$baseUrl/tenant/register/');
      final response = await http.get(url, headers: {
        'Authorization': 'Token $authToken',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final logoUrl = data['tenant_info']?['tenant_logo'];
        if (logoUrl != null && logoUrl.toString().isNotEmpty) {
          tenantLogoUrl = '$baseUrl$logoUrl';
        }
      }
    }
    return {
      'logoUrl': tenantLogoUrl,
      'isLoggedIn': isLoggedIn,
    };
  }

  void handleMenuClick(BuildContext context, String value) {
    switch (value) {
      case 'company_profile':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CompanyProfile()));
        break;
      case 'buyers_list':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BuyersListScreen()));
        break;
      case 'pricing':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlansPricingScreen()));
        break;
      case 'support':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactSupportScreen()));
        break;
      case 'about':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
        break;
      case 'privacy':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
        break;
      case 'terms':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
        break;
      case 'refund':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RefundPolicyScreen()));
        break;
      case 'faq':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQsScreen()));
        break;
      case 'login':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        break;
      case 'signup':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
        break;
      case 'logout':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LogoutScreen()));
        break;
      case 'verify_email':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyEmailOtpScreen()));
        break;
      case 'forgot_password':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
        break;
      case 'set_password':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SetPasswordScreen(
              uid: 'exampleUID',
              token: 'exampleTOKEN',
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getTenantLogoAndAuthStatus(),
      builder: (context, snapshot) {
        Widget avatar;
        bool isLoggedIn = false;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          isLoggedIn = snapshot.data!['isLoggedIn'] ?? false;
          String? logoUrl = snapshot.data!['logoUrl'];
          if (logoUrl != null) {
            avatar = CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(logoUrl),
              backgroundColor: Colors.white,
            );
          } else {
            avatar = const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/logo.png'),
              backgroundColor: Colors.white,
            );
          }
        } else {
          avatar = const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage('assets/logo.png'),
            backgroundColor: Colors.white,
          );
        }

        // Build menu items
        List<PopupMenuEntry<String>> menuItems = [
          const PopupMenuItem(value: 'company_profile', child: Text('Company Profile')),
          const PopupMenuItem(value: 'buyers_list', child: Text('Buyers List')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'pricing', child: Text('Pricing & Plans')),
          const PopupMenuItem(value: 'support', child: Text('Contact Support')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'about', child: Text('About Us')),
          const PopupMenuItem(value: 'privacy', child: Text('Privacy Policy')),
          const PopupMenuItem(value: 'terms', child: Text('Terms and Conditions')),
          const PopupMenuItem(value: 'refund', child: Text('Refund Policy')),
          const PopupMenuItem(value: 'faq', child: Text("FAQ's")),
          const PopupMenuDivider(),
        ];

        if (isLoggedIn) {
          // Show only logout for auth section
          menuItems.add(const PopupMenuItem(
            value: 'logout',
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ));
        } else {
          // Show only login/signup for auth section
          menuItems.addAll([
            const PopupMenuItem(value: 'login', child: Text('Login')),
            const PopupMenuItem(value: 'signup', child: Text('Signup')),
          ]);
        }

        return PopupMenuButton<String>(
          onSelected: (value) => handleMenuClick(context, value),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) => menuItems,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: avatar,
          ),
        );
      },
    );
  }
}
