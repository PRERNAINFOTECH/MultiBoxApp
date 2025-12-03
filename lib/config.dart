// API Base URL Configuration
// TEMP: Point to local Django API for development & testing.
// - Android emulator: uses 10.0.2.2 to reach host machine's localhost.
// - If you're testing on a physical device, change this to your machine's LAN IP,
//   e.g. "http://192.168.0.116:8000".
const String baseUrl =
    String.fromEnvironment('BACKEND_URL', defaultValue: "http://10.0.2.2:8000");

/// Razorpay public key used by the Flutter app.
///
/// Best practice is to pass this at build/run time from the same `.env`
/// values that the Django backend uses, so both sides stay in sync:
/// - Backend: RAZORPAY_KEY_ID in `.env`
/// - Flutter: --dart-define=RAZORPAY_KEY_ID=&lt;same value&gt;
const String razorpayKeyId =
    String.fromEnvironment('RAZORPAY_KEY_ID');
