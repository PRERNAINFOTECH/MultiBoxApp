import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart' as config;

class RazorpayService {
  static final Razorpay _razorpay = Razorpay();
  static const String _baseUrl = config.baseUrl;
  
  // Public getter for accessing the Razorpay instance
  static Razorpay get razorpay => _razorpay;

  static void initialize() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment success will be handled in the calling widget
    debugPrint('Payment Success: ${response.paymentId}');
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  static Future<Map<String, dynamic>?> createOrder({
    required int planId,
    required double amount,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/billing/create-order/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'plan_id': planId,
          'amount': amount,
          'currency': 'INR',
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        debugPrint('Error creating order: $body');
        // Return the error payload so the caller can show a useful message.
        return body;
      }
    } catch (e) {
      debugPrint('Exception creating order: $e');
      return null;
    }
  }

  static Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/billing/verify-payment/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception verifying payment: $e');
      return false;
    }
  }

  /// Fetch available billing plans for the authenticated user.
  ///
  /// The backend returns a JSON array of plan objects, so the return type here
  /// is `List<dynamic>?`. We keep it dynamic so that the caller can transform
  /// it into the UI-friendly structure it needs.
  static Future<List<dynamic>?> getPlans({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/billing/plans/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded;
        } else {
          debugPrint('Unexpected /billing/plans/ response shape: ${decoded.runtimeType}');
          return null;
        }
      }
      debugPrint(
          'Failed to load plans. Status: ${response.statusCode}, Body: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Exception getting plans: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSubscriptionStatus({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/billing/subscription/status/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Exception getting subscription status: $e');
      return null;
    }
  }

  static void openPayment({
    required String keyId,
    required String orderId,
    required String name,
    required String description,
    required double amount,
    required String prefillEmail,
    required String prefillContact,
    required Map<String, dynamic> options,
  }) {
    var razorpayOptions = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Convert to paise
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        'email': prefillEmail,
        'contact': prefillContact,
      },
      'theme': {
        'color': '#4A68F2',
      },
    };

    _razorpay.open(razorpayOptions);
  }

  static void dispose() {
    _razorpay.clear();
  }
}


