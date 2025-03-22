import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(
                  Icons.nightlight_round,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Dreami Diary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('About Dreami Diary'),
            _buildSectionContent(
              'Dreami Diary is an app designed to help you record and expore your dreams with AI. '
              'Keep track of your dream patterns, emotions, and recurring themes to gain insights into your mind.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Features'),
            _buildFeatureItem('Record your dreams with details'),
            _buildFeatureItem('Get insights from your dreams with AI'),
            _buildFeatureItem('Analyze recurring themes'),
            _buildFeatureItem('Secure and private journal'),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact Us'),
            _buildSectionContent(
              'Have questions or suggestions? Reach out to us at:\ndreamydiaryai@gmail.com',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Privacy Policy'),
            _buildPrivacyPolicySection(),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '© 2025 Dreami Diary',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        height: 1.5,
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'We take your privacy seriously. Your dream data is stored securely and never shared with third parties without your consent. '
          'For more details, please visit our website.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        GestureDetector(
          onTap: () => _launchURL('https://dreamidiary.com'),
          child: const Text(
            'dreamidiary.com',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryBlue,
              decoration: TextDecoration.underline,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
