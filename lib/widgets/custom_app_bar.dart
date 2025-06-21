// app_bar_menu.dart
import 'package:flutter/material.dart';

class AppBarMenu extends StatelessWidget {
  const AppBarMenu({super.key});

  void handleMenuClick(BuildContext context, String value) {
    switch (value) {
      case 'company_profile':
        // Navigator.pushNamed(context, '/companyProfile');
        break;
      case 'buyers_list':
        break;
      case 'pricing':
        break;
      case 'support':
        break;
      case 'about':
        break;
      case 'privacy':
        break;
      case 'terms':
        break;
      case 'refund':
        break;
      case 'faq':
        break;
      case 'logout':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => handleMenuClick(context, value),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => [
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
        const PopupMenuItem(
          value: 'logout',
          child: Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage('assets/logo.png'),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
