import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../screens/company_buyers/company_profile.dart';
import '../screens/company_buyers/buyers_list.dart';
import '../screens/plan_support/plans_and_pricing.dart';
import '../screens/plan_support/contact_support.dart';
import '../screens/information/about_us.dart';
import '../screens/information/privacy_policy.dart';
import '../screens/information/terms_and_conditions.dart';
import '../screens/information/refund_policy.dart';
import '../screens/information/faqs.dart';
import '../screens/authentication/login.dart';
import '../screens/authentication/signup.dart';
import '../screens/authentication/logout.dart';
import '../config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool useGradient;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.useGradient = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: useGradient
          ? const BoxDecoration(gradient: AppColors.headerGradient)
          : BoxDecoration(color: backgroundColor ?? AppColors.surface),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (showBackButton)
                _AnimatedBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                  isDark: useGradient,
                )
              else
                _AnimatedMenuButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  isDark: useGradient,
                ),
              Expanded(
                child: centerTitle
                    ? Center(
                        child: Text(
                          title,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: useGradient ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          title,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: useGradient ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
              ),
              if (actions != null)
                ...actions!
              else
                AppBarMenuButton(isDark: useGradient),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMenuButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;
  
  const _AnimatedMenuButton({
    required this.onPressed,
    this.isDark = false,
  });

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.menu_rounded,
            color: widget.isDark ? Colors.white : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;
  
  const _AnimatedBackButton({
    required this.onPressed,
    this.isDark = false,
  });

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: widget.isDark ? Colors.white : AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class AppBarMenuButton extends StatefulWidget {
  final bool isDark;
  
  const AppBarMenuButton({super.key, this.isDark = false});

  @override
  State<AppBarMenuButton> createState() => _AppBarMenuButtonState();
}

class _AppBarMenuButtonState extends State<AppBarMenuButton> {
  String? _tenantLogoUrl;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    
    if (authToken != null) {
      setState(() => _isLoggedIn = true);
      
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/tenant/register/'),
          headers: {'Authorization': 'Token $authToken'},
        );

        if (response.statusCode == 200 && mounted) {
          final data = jsonDecode(response.body);
          final logoUrl = data['tenant_info']?['tenant_logo'];
          if (logoUrl != null && logoUrl.toString().isNotEmpty) {
            setState(() {
              _tenantLogoUrl = '$baseUrl$logoUrl';
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading tenant logo: $e');
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleMenuClick(BuildContext context, String value) {
    final Map<String, Widget> screens = {
      'company_profile': const CompanyProfile(),
      'buyers_list': const BuyersListScreen(),
      'pricing': const PlansPricingScreen(),
      'support': const ContactSupportScreen(),
      'about': const AboutUsScreen(),
      'privacy': const PrivacyPolicyScreen(),
      'terms': const TermsConditionsScreen(),
      'refund': const RefundPolicyScreen(),
      'faq': const FAQsScreen(),
      'login': const LoginScreen(),
      'signup': const SignupScreen(),
      'logout': const LogoutScreen(),
    };

    if (screens.containsKey(value)) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screens[value]!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuClick(context, value),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      color: AppColors.surface,
      itemBuilder: (context) => _buildMenuItems(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: widget.isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _tenantLogoUrl != null
                    ? Image.network(
                        _tenantLogoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Icon(
        Icons.person_outline,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    return [
      _buildMenuItem('company_profile', Icons.business_outlined, 'Company Profile'),
      _buildMenuItem('buyers_list', Icons.people_outline, 'Buyers List'),
      const PopupMenuDivider(height: 16),
      _buildMenuItem('pricing', Icons.diamond_outlined, 'Pricing & Plans'),
      _buildMenuItem('support', Icons.headset_mic_outlined, 'Contact Support'),
      const PopupMenuDivider(height: 16),
      _buildMenuItem('about', Icons.info_outline, 'About Us'),
      _buildMenuItem('privacy', Icons.shield_outlined, 'Privacy Policy'),
      _buildMenuItem('terms', Icons.description_outlined, 'Terms & Conditions'),
      _buildMenuItem('refund', Icons.receipt_long_outlined, 'Refund Policy'),
      _buildMenuItem('faq', Icons.help_outline, 'FAQs'),
      const PopupMenuDivider(height: 16),
      if (_isLoggedIn)
        _buildMenuItem('logout', Icons.logout, 'Logout', isDestructive: true)
      else ...[
        _buildMenuItem('login', Icons.login, 'Login'),
        _buildMenuItem('signup', Icons.person_add_outlined, 'Sign Up'),
      ],
    ];
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDestructive ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  
  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              else
                Builder(
                  builder: (context) => IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (actions != null)
                ...actions!
              else
                AppBarMenuButton(isDark: true),
            ],
          ),
        ),
      ),
    );
  }
}
