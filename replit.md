# MultiBox - Flutter Web Application

## Overview
MultiBox is a cross-platform mobile and web application built with Flutter. This is a business management application with features for managing stocks, products, productions, purchase orders, paper reels, and company buyers. It includes user authentication, subscription management, and payment processing via Razorpay.

## Project Architecture

### Technology Stack
- **Frontend Framework**: Flutter 3.32.0 (Web)
- **Language**: Dart 3.8.0
- **Backend**: External API (configured via environment variables)
- **Payment Gateway**: Razorpay

### Project Structure
```
lib/
├── screens/           # All screen/page components
│   ├── authentication/    # Login, signup, password reset, email verification
│   ├── company_buyers/    # Buyer management screens
│   ├── information/       # Static pages (about, FAQs, privacy, etc.)
│   ├── plan_support/      # Subscription plans and support
│   └── *.dart            # Main feature screens (stocks, products, etc.)
├── services/          # Business logic and API integration
│   ├── app_initializer.dart
│   ├── razorpay_service.dart
│   └── subscription_service.dart
├── widgets/           # Reusable UI components
├── config.dart        # Configuration (backend URL, API keys)
└── main.dart          # Application entry point
```

### Key Features
1. **Authentication System**: Login, signup, email verification, password reset
2. **Stock Management**: Track and manage inventory
3. **Product Management**: Product catalog with archive functionality
4. **Production Management**: Production tracking with archive
5. **Purchase Orders**: Order management with detailed views and archive
6. **Paper Reels**: Paper reel tracking and summaries
7. **Company/Buyers**: Buyer and company profile management
8. **Subscription Plans**: Integrated subscription management with Razorpay
9. **Information Pages**: About, FAQs, privacy policy, refund policy, terms

## Development Setup

### Environment Variables
The application uses the following environment variables (configured via `--dart-define` flags):

- **BACKEND_URL**: Backend API base URL (default: `http://localhost:8000`)
- **RAZORPAY_KEY_ID**: Razorpay payment gateway key ID

### Running the Application
The Flutter web development server is configured to run on port 5000:
```bash
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=5000 \
  --dart-define=BACKEND_URL=$BACKEND_URL \
  --dart-define=RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID
```

### Dependencies
Key Flutter packages used:
- `http`: API communication
- `shared_preferences`: Local data persistence
- `razorpay_flutter`: Payment integration
- `file_picker`: File selection
- `image_picker`: Image selection
- `share_plus`: Share functionality
- `path_provider`: File system access
- `fluttertoast`: Toast notifications

## Deployment

### Build Configuration
- **Deployment Type**: Static
- **Build Command**: `flutter build web`
- **Public Directory**: `build/web`

The application builds to static HTML/CSS/JavaScript files that can be hosted on any static hosting service.

## Recent Changes (December 2, 2025)
- Initial Replit environment setup
- Configured Flutter web development server on port 5000
- Set up environment variable support for backend URL and Razorpay key
- Configured deployment for static hosting
- Updated Dart SDK requirement to support 3.8.0+

## Backend Integration
The application expects a backend API running separately. The backend URL is configurable via the `BACKEND_URL` environment variable. The API handles:
- User authentication and session management
- Data persistence for all business entities
- Subscription and payment processing coordination

## User Preferences
- None specified yet
