import 'package:flutter/material.dart';
import '../app_theme.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryBlack),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 20),

            // Card do Perfil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              child: const Column(
                children: [
                  // Foto (Placeholder)
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.borderGrey,
                      child: Icon(Icons.person,
                          size: 50, color: AppTheme.textGrey),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Gabriel Freire',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Endereço: Rua RD13, número 184,\nResidêncial Drummond',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Lista de Opções
            _buildOption(Icons.person_outline, 'Editar perfil', () {
              Navigator.pushNamed(context, '/user_register');
            }),
            _buildOption(
                Icons.settings_outlined, 'Configurações da conta', () {}),
            _buildOption(Icons.help_outline, 'Obter ajuda', () {}),
            _buildOption(Icons.lock_outline, 'Privacidade', () {}),
            _buildOption(Icons.logout, 'Sair da conta', () {
              Navigator.pushReplacementNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryBlack),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryBlack,
        ),
      ),
    );
  }
}
