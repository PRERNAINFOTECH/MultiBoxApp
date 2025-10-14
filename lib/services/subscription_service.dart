import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SubscriptionService {
  static const String _subscriptionKey = 'user_subscription';
  static const String _subscriptionStatusKey = 'subscription_status';

  // Save subscription data locally
  static Future<void> saveSubscription(Map<String, dynamic> subscription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionKey, jsonEncode(subscription));
  }

  // Get subscription data from local storage
  static Future<Map<String, dynamic>?> getSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionJson = prefs.getString(_subscriptionKey);
    if (subscriptionJson != null) {
      return jsonDecode(subscriptionJson);
    }
    return null;
  }

  // Save subscription status
  static Future<void> saveSubscriptionStatus(bool hasActiveSubscription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_subscriptionStatusKey, hasActiveSubscription);
  }

  // Get subscription status
  static Future<bool> hasActiveSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_subscriptionStatusKey) ?? false;
  }

  // Clear subscription data
  static Future<void> clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_subscriptionKey);
    await prefs.remove(_subscriptionStatusKey);
  }

  // Check if user has access to paid features
  static Future<bool> canAccessPaidFeatures() async {
    final subscription = await getSubscription();
    if (subscription == null) return false;
    
    // Check if subscription is active and not expired
    final status = subscription['status'] as String?;
    final endDate = subscription['end_date'] as String?;
    
    if (status != 'active' || endDate == null) return false;
    
    final endDateTime = DateTime.parse(endDate);
    return endDateTime.isAfter(DateTime.now());
  }
}


