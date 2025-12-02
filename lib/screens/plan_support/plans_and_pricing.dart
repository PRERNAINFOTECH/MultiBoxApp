import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';
import '../../services/razorpay_service.dart';
import '../../services/subscription_service.dart';
import '../../config.dart' as config;

class PlansPricingScreen extends StatefulWidget {
  const PlansPricingScreen({super.key});

  @override
  State<PlansPricingScreen> createState() => _PlansPricingScreenState();
}

class _PlansPricingScreenState extends State<PlansPricingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isMonthly = true;
  bool isLoading = false;
  bool hasActiveSubscription = false;
  List<Map<String, dynamic>> plans = [];
  String? userToken;
  String? userEmail;
  String? userPhone;

  final planData = {
    'monthly': [
      {
        'planId': 1,
        'title': 'STANDARD',
        'displayPrice': '₹798',
        'amountPaise': 79800,
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.info,
        'features': [
          "Stock Management without History",
          "Single Reel Addition",
          "Products management",
          "Production Line Handling",
          "Daily Program Management",
          "Purchase Order Management",
        ]
      },
      {
        'planId': 2,
        'title': 'ENTERPRISE',
        'displayPrice': '₹1098',
        'amountPaise': 109800,
        'icon': Icons.rocket_launch_outlined,
        'color': AppColors.primary,
        'popular': true,
        'features': [
          "Stock Management with History",
          "Bulk Reel Addition",
          "Advanced Reel Filtering",
          "Reels Stocks and Order Management",
          "Products Management",
          "Products Filtering",
          "Production Line Handling",
          "Daily Program Management",
          "Daily Program Sharing",
          "Purchase Order Management",
          "Monthly Report",
          "Database Copy",
        ]
      },
    ],
    'yearly': [
      {
        'planId': 3,
        'title': 'STANDARD',
        'displayPrice': '₹7980',
        'amountPaise': 798000,
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.info,
        'features': [
          "Stock Management without History",
          "Single Reel Addition",
          "Products management",
          "Production Line Handling",
          "Daily Program Management",
          "Purchase Order Management",
        ]
      },
      {
        'planId': 4,
        'title': 'ENTERPRISE',
        'displayPrice': '₹10980',
        'amountPaise': 1098000,
        'icon': Icons.rocket_launch_outlined,
        'color': AppColors.primary,
        'popular': true,
        'features': [
          "Stock Management with History",
          "Bulk Reel Addition",
          "Advanced Reel Filtering",
          "Reels Stocks and Order Management",
          "Products Management",
          "Products Filtering",
          "Production Line Handling",
          "Daily Program Management",
          "Daily Program Sharing",
          "Purchase Order Management",
          "Monthly Report",
          "Database Copy",
        ]
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    RazorpayService.initialize();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadUserData();
    await _checkSubscriptionStatus();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token');
      userEmail = prefs.getString('email');
      userPhone = prefs.getString('phone');
    });
  }

  Future<void> _checkSubscriptionStatus() async {
    if (userToken == null) return;

    setState(() => isLoading = true);

    try {
      final status = await RazorpayService.getSubscriptionStatus(token: userToken!);
      if (status != null) {
        setState(() {
          hasActiveSubscription = status['has_active_subscription'] ?? false;
        });
        await SubscriptionService.saveSubscriptionStatus(hasActiveSubscription);
      }
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handlePayment(Map<String, dynamic> plan) async {
    if (userToken == null) {
      Fluttertoast.showToast(msg: 'Please login first');
      return;
    }

    setState(() => isLoading = true);

    try {
      final orderData = await RazorpayService.createOrder(
        planId: plan['id'],
        amount: plan['price'],
        token: userToken!,
      );

      if (orderData == null) {
        Fluttertoast.showToast(msg: 'Failed to create order');
        return;
      }

      RazorpayService.openPayment(
        keyId: config.razorpayKeyId,
        orderId: orderData['order_id'],
        name: 'MultiBox',
        description: '${plan['name']} Plan - ${isMonthly ? 'Monthly' : 'Yearly'}',
        amount: plan['price'],
        prefillEmail: userEmail ?? '',
        prefillContact: userPhone ?? '',
        options: {},
      );

      RazorpayService.razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
        await _verifyPayment(response);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Payment failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyPayment(PaymentSuccessResponse response) async {
    try {
      final success = await RazorpayService.verifyPayment(
        paymentId: response.paymentId!,
        orderId: response.orderId!,
        signature: response.signature!,
        token: userToken!,
      );

      if (success) {
        Fluttertoast.showToast(msg: 'Payment successful! Subscription activated.');
        await _checkSubscriptionStatus();
      } else {
        Fluttertoast.showToast(msg: 'Payment verification failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Payment verification failed: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    RazorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Plans & Pricing'),
          Expanded(
            child: ScrollToTopWrapper(
              scrollController: _scrollController,
              child: RefreshIndicator(
                onRefresh: _checkSubscriptionStatus,
                color: AppColors.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            FadeInWidget(
                              child: _buildHeader(),
                            ),
                            const SizedBox(height: 24),
                            FadeInWidget(
                              delay: const Duration(milliseconds: 100),
                              child: _buildToggle(),
                            ),
                            const SizedBox(height: 32),
                            _buildPlansSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.workspace_premium, color: AppColors.primary, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose Your Plan',
          style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Select the plan that best fits your business needs\nand unlock powerful features',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight, height: 1.5),
          textAlign: TextAlign.center,
        ),
        if (hasActiveSubscription) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'You have an active subscription',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Monthly', isMonthly, () => setState(() => isMonthly = true)),
          _buildToggleButton('Yearly', !isMonthly, () => setState(() => isMonthly = false), showBadge: true),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap, {bool showBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (showBadge && !isMonthly) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.success,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '2 Free',
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlansSection() {
    var plans = isMonthly ? planData['monthly']! : planData['yearly']!;
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return isMobile
            ? Column(
                children: [
                  for (int i = 0; i < plans.length; i++)
                    SlideInWidget(
                      delay: Duration(milliseconds: 200 + (i * 100)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildPlanCard(plans[i], i),
                      ),
                    ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < plans.length; i++)
                    SlideInWidget(
                      delay: Duration(milliseconds: 200 + (i * 100)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: 340,
                          child: _buildPlanCard(plans[i], i),
                        ),
                      ),
                    ),
                ],
              );
      },
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    final bool isPopular = plan['popular'] == true;
    final Color planColor = plan['color'] as Color? ?? AppColors.primary;
    final IconData planIcon = plan['icon'] as IconData? ?? Icons.star;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isPopular ? AppShadows.medium : AppShadows.small,
        border: isPopular ? Border.all(color: planColor, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'MOST POPULAR',
                    style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: planColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(planIcon, color: planColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['title'] as String,
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isMonthly ? 'Monthly billing' : 'Annual billing',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan['displayPrice'] as String,
                      style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold, color: planColor),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        isMonthly ? '/month' : '/year',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 20),
                Text(
                  'Features included:',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...(plan['features'] as List<String>).map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: isPopular
                      ? GradientButton(
                          text: hasActiveSubscription ? 'Active Plan' : 'Get Started',
                          onPressed: hasActiveSubscription
                              ? null
                              : () => _handlePayment({
                                    'id': plan['planId'],
                                    'name': plan['title'],
                                    'price': plan['amountPaise'],
                                  }),
                          icon: hasActiveSubscription ? Icons.check : Icons.arrow_forward,
                          isLoading: isLoading,
                        )
                      : OutlinedButton(
                          onPressed: hasActiveSubscription
                              ? null
                              : () => _handlePayment({
                                    'id': plan['planId'],
                                    'name': plan['title'],
                                    'price': plan['amountPaise'],
                                  }),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: hasActiveSubscription ? AppColors.textLight : planColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                hasActiveSubscription ? 'Active Plan' : 'Get Started',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: hasActiveSubscription ? AppColors.textLight : planColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!hasActiveSubscription) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18, color: planColor),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
