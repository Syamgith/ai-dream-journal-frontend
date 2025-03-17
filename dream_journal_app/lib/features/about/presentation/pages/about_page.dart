import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                'Dream Journal',
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
            _buildSectionTitle('About Dream Journal'),
            _buildSectionContent(
              'Dream Journal is an app designed to help you record and analyze your dreams. '
              'Keep track of your dream patterns, emotions, and recurring themes to gain insights into your subconscious mind.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Features'),
            _buildFeatureItem('Record your dreams with details'),
            _buildFeatureItem('Track dream patterns and emotions'),
            _buildFeatureItem('Analyze recurring themes'),
            _buildFeatureItem('Secure and private journal'),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact Us'),
            _buildSectionContent(
              'Have questions or suggestions? Reach out to us at:\nsupport@dreamjournal.app',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Privacy Policy'),
            _buildSectionContent(
              'We take your privacy seriously. Your dream data is stored securely and never shared with third parties without your consent. '
              'For more details, please visit our website.',
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '© 2023 Dream Journal',
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
}
