import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/supabase_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = true;

  String _name = '';
  String _address = '';
  String? _avatarUrl;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'Versão ${packageInfo.version}+${packageInfo.buildNumber}';
        });
      }
    } catch (_) {
      // Falha silenciosa
    }
  }

  Future<void> _loadProfile() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;

      final data = await SupabaseService.client
          .from('users')
          .select('name, address, profile_image_url')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return;

      setState(() {
        _name = data['name'] ?? '';
        _address = data['address'] ?? '';
        _avatarUrl = data['profile_image_url'] as String?;
      });
    } catch (_) {
      // Falha silenciosa — dados ficam em branco
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryBlack),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Column(
                      children: [
                        // Foto real ou placeholder
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.borderGrey,
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? const Icon(Icons.person,
                                  size: 50, color: AppTheme.textGrey)
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Nome real
                        Text(
                          _name.isNotEmpty ? _name : 'Sem nome cadastrado',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlack,
                          ),
                        ),

                        // Endereço real (só exibe se preenchido)
                        if (_address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Endereço: $_address',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Lista de Opções
                  _buildOption(Icons.person_outline, 'Editar perfil', () async {
                    await Navigator.pushNamed(context, '/user_register');
                    // Recarrega ao voltar da edição
                    setState(() => _isLoading = true);
                    _loadProfile();
                  }),
                  _buildOption(
                      Icons.settings_outlined, 'Configurações da conta', () {}),
                  _buildOption(Icons.help_outline, 'Obter ajuda', () {}),
                  _buildOption(Icons.lock_outline, 'Privacidade', () {}),
                  _buildOption(Icons.logout, 'Sair da conta', () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
                  
                  const SizedBox(height: 40),
                  
                  // Rodapé com Versão
                  if (_appVersion.isNotEmpty)
                    Center(
                      child: Text(
                        _appVersion,
                        style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 20),
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
