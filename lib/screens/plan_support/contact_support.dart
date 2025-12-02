import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportState();
}

class _ContactSupportState extends State<ContactSupportScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Contact Support'),
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
                          FadeInWidget(
                            delay: const Duration(milliseconds: 100),
                            child: _buildContactForm(),
                          ),
                          const SizedBox(height: 32),
                          FadeInWidget(
                            delay: const Duration(milliseconds: 200),
                            child: _buildContactInfo(),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.support_agent, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'How can we help?',
          style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Our support team is here to assist you\nwith any questions or issues',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Send us a message',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _nameController,
            label: 'Your Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _subjectController,
            label: 'Subject',
            hint: 'What is this regarding?',
            icon: Icons.topic_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _messageController,
            label: 'Message',
            hint: 'Describe your issue or question in detail...',
            icon: Icons.message_outlined,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Send Message',
            onPressed: _sendMessage,
            icon: Icons.send,
            isLoading: _isSending,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.primary, size: 20) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: maxLines > 1 ? 16 : 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Other ways to reach us',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'support@multibox.com',
            color: AppColors.info,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: '+91 1234 567890',
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.access_time,
            title: 'Business Hours',
            subtitle: 'Mon - Fri, 9:00 AM - 6:00 PM IST',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _isSending = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSending = false);
    _showSnackBar('Message sent successfully! We\'ll get back to you soon.');

    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
