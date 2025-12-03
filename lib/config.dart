// API Base URL Configuration
// Production: Point to remote hosted API
const String baseUrl =
    String.fromEnvironment('BACKEND_URL', defaultValue: "https://api.multibox.co.in");

/// Razorpay public key used by the Flutter app.
///
/// Best practice is to pass this at build/run time from the same `.env`
/// values that the Django backend uses, so both sides stay in sync:
/// - Backend: RAZORPAY_KEY_ID in `.env`
/// - Flutter: --dart-define=RAZORPAY_KEY_ID=&lt;same value&gt;
const String razorpayKeyId =
    String.fromEnvironment('RAZORPAY_KEY_ID');
