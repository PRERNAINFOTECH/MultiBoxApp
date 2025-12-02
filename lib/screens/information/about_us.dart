import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'About Us'),
          Expanded(
            child: ScrollToTopWrapper(
              scrollController: _scrollController,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          FadeInWidget(child: _buildHeader()),
                          const SizedBox(height: 32),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 100),
                            child: _buildInfoCard(
                              icon: Icons.info_outline,
                              title: 'About Us',
                              content: 'Multibox is a Software as a Service (SaaS) platform that provides the best automated software for corrugated manufacturers to manage their stocks, products, production line, and much more. This includes reels inventory management with reel stock and summaries to easily organize their materials and products. Manufacturers can focus on their unit while the handling is done by the app, saving time and money.',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 200),
                            child: _buildInfoCard(
                              icon: Icons.flag_outlined,
                              title: 'Our Mission',
                              content: 'Our mission at Multibox is to provide the best automated software as a service for as many corrugation manufacturers as possible. We aim to empower manufacturers to streamline their operations, reduce costs, and increase efficiency by providing them with the services they need to succeed. We are committed to helping our clients achieve their goals by giving them software that is easy to use, reliable, and cost-effective.',
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 300),
                            child: _buildInfoCard(
                              icon: Icons.visibility_outlined,
                              title: 'Our Vision',
                              content: 'Our vision at Multibox is to become the leading provider of automated software for corrugation manufacturers. We aim to be the go-to solution for manufacturers looking to streamline their operations, reduce costs, and increase efficiency. We are committed to providing our clients with the best possible service and support, and to helping them achieve their goals by giving them the tools they need to succeed.',
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 400),
                            child: _buildAddressCard(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.medium,
          ),
          child: Image.asset(
            'assets/logo.png',
            height: 80,
            fit: BoxFit.contain,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'MultiBox',
          style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
          Text(
          'Smart Solutions for Corrugated Manufacturers',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textSecondary),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Our Operational Address',
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Prerna Infotech',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  "1166/A, 'PRERNA',\nSir Pattani Road,\nOpp. HCG Hospital,\nBhavnagar - 364001",
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
