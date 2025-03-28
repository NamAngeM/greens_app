import 'package:flutter/material.dart';
import 'package:greens_app/widgets/menu.dart';

import '../../widgets/menu.dart';

class LegaleNoticeView extends StatefulWidget {
  const LegaleNoticeView({Key? key}) : super(key: key);

  @override
  State<LegaleNoticeView> createState() => _LegaleNoticeViewState();
}

class _LegaleNoticeViewState extends State<LegaleNoticeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  _buildContent(),
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomMenu(
                currentIndex: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background image
        Container(
          height: 250,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backgrounds/legal_notice_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlay
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
        // Logo and title
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Legal Notices &',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      transform: Matrix4.translationValues(0, -30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Legal Notices',
            'At Green Minds, we prioritize your trust and are dedicated to protecting your personal data. This section outlines the legal framework governing our services and the measures we take to ensure your privacy is respected.\n\n'
            'We explain how your data is collected, stored, and used, and provide information about your rights under applicable laws.\n\n'
            'Transparency is our priority, and we encourage you to review our Legal Notices and Privacy Policy to understand how we operate responsibly.',
          ),
          const SizedBox(height: 30),
          _buildSection(
            'Privacy Policy',
            'At Green Minds, we prioritize your trust and are dedicated to protecting your personal data. This section outlines the legal framework governing our services and the measures we take to ensure your privacy is respected.\n\n'
            'We explain how your data is collected, stored, and used, and provide information about your rights under applicable laws.\n\n'
            'Transparency is our priority, and we encourage you to review our Legal Notices and Privacy Policy to understand how we operate responsibly.\n\n'
            'For any questions or concerns regarding this policy, feel free to contact us. We encourage all users to regularly review our Privacy Policy for updates, as changes may occur in response to evolving legal requirements or service improvements.[...]',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3140),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF5D6A75),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}