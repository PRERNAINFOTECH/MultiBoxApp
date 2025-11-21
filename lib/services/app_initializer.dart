import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../config.dart' as config;
import 'subscription_service.dart';

class AppInitializer {
  static Future<void> initializeApp() async {
    // Check if user is logged in
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      // Check subscription status
      await _checkAndUpdateSubscriptionStatus(token);
    }
  }

  static Future<void> _checkAndUpdateSubscriptionStatus(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${config.baseUrl}/billing/subscription/status/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hasActiveSubscription = data['has_active_subscription'] ?? false;
        
        // Save subscription status locally
        await SubscriptionService.saveSubscriptionStatus(hasActiveSubscription);
        
        if (data['subscription'] != null) {
          await SubscriptionService.saveSubscription(data['subscription']);
        }
      }
    } catch (e) {
      // Handle error silently or log it
      developer.log(
        'Error checking subscription status: $e',
        name: 'AppInitializer',
        error: e,
      );
    }
  }
}


