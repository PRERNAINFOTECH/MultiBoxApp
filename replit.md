# MultiBox - Flutter Web Application

## Overview
MultiBox is a cross-platform mobile and web application built with Flutter. This is a business management application with features for managing stocks, products, productions, purchase orders, paper reels, and company buyers. It includes user authentication, subscription management, and payment processing via Razorpay.

## Project Architecture

### Technology Stack
- **Frontend Framework**: Flutter 3.32.0 (Web)
- **Language**: Dart 3.8.0
- **Backend**: External API (configured via environment variables)
- **Payment Gateway**: Razorpay
- **Design System**: Material 3 with custom theme

### Project Structure
```
lib/
├── screens/               # All screen/page components
│   ├── authentication/    # Login, signup, password reset, email verification
│   ├── company_buyers/    # Buyer and company profile management
│   ├── information/       # Static pages (about, FAQs, privacy, etc.)
│   ├── plan_support/      # Subscription plans and support
│   └── *.dart            # Main feature screens (stocks, products, etc.)
├── services/              # Business logic and API integration
│   ├── app_initializer.dart
│   ├── razorpay_service.dart
│   └── subscription_service.dart
├── theme/                 # Design system
│   └── app_theme.dart     # Colors, typography, shadows, gradients
├── widgets/               # Reusable UI components
│   ├── animated_widgets.dart    # Custom animated buttons, inputs, cards
│   ├── custom_app_bar.dart      # Gradient app bar with menu
│   ├── side_drawer.dart         # Navigation drawer
│   └── page_transitions.dart    # Custom page route animations
├── config.dart            # Configuration (backend URL, API keys)
└── main.dart              # Application entry point with splash screen
```

### Key Features
1. **Authentication System**: Login, signup, email verification, password reset
2. **Stock Management**: Track and manage inventory with animated cards
3. **Product Management**: Product catalog with archive functionality
4. **Production Management**: Production tracking with archive
5. **Purchase Orders**: Order management with detailed views and archive
6. **Paper Reels**: Paper reel tracking and summaries
7. **Company/Buyers**: Buyer and company profile management
8. **Subscription Plans**: Integrated subscription management with Razorpay
9. **Information Pages**: About, FAQs, privacy policy, refund policy, terms

## Design System

### Theme Configuration
- **Primary Color**: #4A68F2 (Blue)
- **Primary Gradient**: Linear gradient from #4A68F2 to #6B82F7
- **Background**: #F8F9FB
- **Surface**: #FFFFFF
- **Typography**: System fonts with Material 3 type scale

### UI Components
- **GradientButton**: Primary action button with gradient background
- **AnimatedCard**: Card with shadow and tap animations
- **StyledTextField**: Input field with icons and validation
- **StatusChip**: Colored chips for status indicators
- **InfoCard**: Card with icon, title, and description

### Animations
- **Page Transitions**: FadeSlide, Scale, SlideUp custom routes
- **Splash Screen**: Animated logo with fade and scale effects
- **Card Interactions**: Scale and shadow on tap
- **Loading States**: Smooth CircularProgressIndicator

## Development Setup

### Environment Variables
The application uses the following environment variables (configured via `--dart-define` flags):

- **BACKEND_URL**: Backend API base URL (default: `http://localhost:8000`)
- **RAZORPAY_KEY_ID**: Razorpay payment gateway key ID

### Running the Application
The Flutter web development server builds a release version and serves on port 5000:
```bash
flutter build web --release --pwa-strategy=none && python3 -m http.server 5000 --directory build/web --bind 0.0.0.0
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
- **Build Command**: `flutter build web --release`
- **Public Directory**: `build/web`

The application builds to static HTML/CSS/JavaScript files that can be hosted on any static hosting service.

## Recent Changes (December 2, 2025)

### Complete UI/UX Redesign
- Created comprehensive theme system (AppColors, AppTextStyles, AppShadows)
- Built animated reusable widgets library
- Redesigned all 30+ screens with Material 3 design
- Added smooth page transitions throughout the app
- Created animated splash screen with logo

### Screens Redesigned
1. **Authentication (6 screens)**: Login, Signup, Forgot Password, Set Password, Verify Email, Logout
2. **Stocks**: Main stock management with animated cards
3. **Paper Reels (2 screens)**: Reels list and summary
4. **Products (4 screens)**: List, archive, details, add/edit
5. **Productions (2 screens)**: List and archive
6. **Programs (2 screens)**: List and archive
7. **Purchase Orders (4 screens)**: List, archive, details, add/edit
8. **Company Profile**: Profile editing with save functionality
9. **Buyers List**: Buyer management
10. **Plans & Pricing**: Subscription plans with Razorpay (amounts in paise)
11. **Contact Support**: Support form and contact info
12. **Information (5 screens)**: About, FAQs, Privacy, Refund, Terms

### Technical Improvements
- Fixed Razorpay integration with proper amountPaise values (INR × 100)
- Added AlwaysScrollableScrollPhysics for RefreshIndicator support
- Implemented CustomScrollView patterns for empty state handling
- Cupertino page transitions for smooth navigation

## Backend Integration
The application expects a backend API running separately. The backend URL is configurable via the `BACKEND_URL` environment variable. The API handles:
- User authentication and session management
- Data persistence for all business entities
- Subscription and payment processing coordination

## Play Store Readiness
- Material 3 design system implemented
- Consistent color scheme and typography
- Smooth animations and transitions
- Professional empty states
- Error handling with user-friendly messages
- Loading states for all async operations

## User Preferences
- None specified yet
