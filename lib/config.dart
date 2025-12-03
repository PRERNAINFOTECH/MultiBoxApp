// API Base URL Configuration
// For local testing: use your computer's IP (e.g., "http://192.168.0.116:8000")
// For hosted API: use your production URL (e.g., "https://api.multibox.co.in")
// To find your local IP: run 'hostname -I' in terminal
const String baseUrl = String.fromEnvironment('BACKEND_URL', defaultValue: "https://api.multibox.co.in");
const String razorpayKeyId = String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: "YOUR_RAZORPAY_KEY_ID");
