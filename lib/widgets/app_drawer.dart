import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/products.dart';
import '../screens/products_archive.dart';
import '../screens/paperreels.dart';
import '../screens/paperreels_summary.dart';
import '../screens/stocks.dart';
import '../screens/purchaseorders.dart';
import '../screens/purchaseorders_archive.dart';
import '../screens/productions.dart';
import '../screens/productions_archive.dart';
import '../screens/programs.dart';
import '../screens/programs_archive.dart';
import '../screens/plan_support/plans_and_pricing.dart';
import '../services/subscription_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  String? _currentlyExpandedTileId;
  bool hasActiveSubscription = false;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;
  final List<AnimationController> _itemControllers = [];
  
  final List<Map<String, dynamic>> _menuItems = [
    {'id': 'plans', 'icon': Icons.diamond_outlined, 'title': 'Plans & Pricing', 'isPaid': false},
    {'id': 'stock', 'icon': Icons.inventory_2_outlined, 'title': 'Stock', 'isPaid': true},
    {
      'id': 'reels',
      'icon': Icons.receipt_long_outlined,
      'title': 'Paper Reels',
      'isPaid': true,
      'subItems': [
        {'title': 'Summary', 'screen': 'PaperReelsSummaryScreen'},
        {'title': 'Reels', 'screen': 'PaperReelsScreen'},
      ]
    },
    {
      'id': 'po',
      'icon': Icons.shopping_cart_outlined,
      'title': 'Purchase Order',
      'isPaid': true,
      'subItems': [
        {'title': 'Purchase Orders', 'screen': 'PurchaseOrdersScreen'},
        {'title': 'Archive', 'screen': 'PurchaseOrdersArchiveScreen'},
      ]
    },
    {
      'id': 'production',
      'icon': Icons.precision_manufacturing_outlined,
      'title': 'Production',
      'isPaid': true,
      'subItems': [
        {'title': 'Productions', 'screen': 'ProductionsScreen'},
        {'title': 'Archive', 'screen': 'ProductionsArchiveScreen'},
      ]
    },
    {
      'id': 'programs',
      'icon': Icons.event_note_outlined,
      'title': 'Program',
      'isPaid': true,
      'subItems': [
        {'title': 'Programs', 'screen': 'ProgramsScreen'},
        {'title': 'Archive', 'screen': 'ProgramsArchiveScreen'},
      ]
    },
    {
      'id': 'products',
      'icon': Icons.all_inbox_outlined,
      'title': 'Products',
      'isPaid': true,
      'subItems': [
        {'title': 'Products', 'screen': 'ProductsScreen'},
        {'title': 'Archive', 'screen': 'ProductsArchiveScreen'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
    _initAnimations();
  }
  
  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    
    for (int i = 0; i < _menuItems.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _itemControllers.add(controller);
    }
    
    _headerController.forward();
    _staggerMenuAnimations();
  }
  
  void _staggerMenuAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _itemControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) _itemControllers[i].forward();
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    final status = await SubscriptionService.hasActiveSubscription();
    if (mounted) {
      setState(() {
        hasActiveSubscription = status;
      });
    }
  }
  
  @override
  void dispose() {
    _headerController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Widget _getScreen(String screenName) {
    switch (screenName) {
      case 'PaperReelsSummaryScreen':
        return const PaperReelsSummaryScreen();
      case 'PaperReelsScreen':
        return const PaperReelsScreen();
      case 'PurchaseOrdersScreen':
        return const PurchaseOrdersScreen();
      case 'PurchaseOrdersArchiveScreen':
        return const PurchaseOrdersArchiveScreen();
      case 'ProductionsScreen':
        return const ProductionsScreen();
      case 'ProductionsArchiveScreen':
        return const ProductionsArchiveScreen();
      case 'ProgramsScreen':
        return const ProgramsScreen();
      case 'ProgramsArchiveScreen':
        return const ProgramsArchiveScreen();
      case 'ProductsScreen':
        return const ProductsScreen();
      case 'ProductsArchiveScreen':
        return const ProductsArchiveScreen();
      default:
        return const StocksScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    return AnimatedBuilder(
                      animation: _itemControllers[index],
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _itemControllers[index],
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.3, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _itemControllers[index],
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: item.containsKey('subItems')
                          ? _buildExpandableItem(item, index)
                          : _buildMenuItem(item, index),
                    );
                  },
                ),
              ),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_headerAnimation),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MultiBox',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasActiveSubscription
                            ? AppColors.success.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasActiveSubscription ? 'Pro Plan' : 'Free Plan',
                        style: TextStyle(
                          color: hasActiveSubscription
                              ? AppColors.accentLight
                              : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, int index) {
    final bool isPaid = item['isPaid'] ?? false;
    final bool hasAccess = !isPaid || hasActiveSubscription;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pop();
            if (item['id'] == 'plans') {
              Navigator.of(context).push(
                _createRoute(const PlansPricingScreen()),
              );
            } else if (item['id'] == 'stock') {
              if (hasAccess) {
                Navigator.of(context).push(
                  _createRoute(const StocksScreen()),
                );
              } else {
                _showSubscriptionDialog();
              }
            }
          },
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isPaid && !hasActiveSubscription)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableItem(Map<String, dynamic> item, int index) {
    final String id = item['id'];
    final bool isExpanded = _currentlyExpandedTileId == id;
    final bool isPaid = item['isPaid'] ?? false;
    final bool hasAccess = !isPaid || hasActiveSubscription;
    final List<Map<String, dynamic>> subItems =
        List<Map<String, dynamic>>.from(item['subItems'] ?? []);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _currentlyExpandedTileId = isExpanded ? null : id;
                });
              },
              splashColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isPaid && !hasActiveSubscription)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: subItems.map((subItem) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).pop();
                        if (hasAccess) {
                          Navigator.of(context).push(
                            _createRoute(_getScreen(subItem['screen'] as String)),
                          );
                        } else {
                          _showSubscriptionDialog();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              subItem['title'] as String,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upgrade to Pro',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This feature is available for Pro subscribers. Upgrade now to unlock all features.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Maybe Later'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            _createRoute(const PlansPricingScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('View Plans'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
