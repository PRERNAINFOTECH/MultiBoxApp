import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/authentication/login.dart';
import 'screens/authentication/verify_email_otp_screen.dart';
import 'screens/stocks.dart';
import 'services/app_initializer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _determineStartScreen() async {
    final prefs = await SharedPreferences.getInstance();

    final authToken = prefs.getString('auth_token');
    final pendingEmail = prefs.getString('pending_email');
    final pendingSessionToken = prefs.getString('pending_session_token');

    if (pendingEmail != null && pendingSessionToken != null) {
      return VerifyEmailOtpScreen(
        email: pendingEmail,
        sessionToken: pendingSessionToken,
      );
    }

    if (authToken != null && authToken.isNotEmpty) {
      // Initialize app data including subscription status
      await AppInitializer.initializeApp();
      return const StocksScreen(); // Logged-in home screen
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _determineStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data ?? const LoginScreen();
          }
        },
      ),
    );
  }
}
