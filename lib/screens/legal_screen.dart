import 'package:flutter/material.dart';
import '../app_theme.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Jurídico',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryBlack),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderGrey, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _buildLegalOption(
            context,
            Icons.description_outlined,
            'Termos de Uso',
            'Leia as regras de utilização da plataforma',
            '/legal_terms',
          ),
          _buildLegalOption(
            context,
            Icons.privacy_tip_outlined,
            'Política de Privacidade',
            'Como cuidamos dos seus dados pessoais',
            '/legal_privacy',
          ),
        ],
      ),
    );
  }

  Widget _buildLegalOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, route),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryOrange),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlack,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textGrey,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.borderGrey),
    );
  }
}
