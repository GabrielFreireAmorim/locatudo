import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _authService = AuthService();
  bool _isLoading = true;

  String _name = '';
  String _address = '';
  String? _avatarUrl;
  String _appVersion = '';
  String _locadorStatus = 'inactive';

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
          .select('name, address, profile_image_url, locador_status')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return;

      setState(() {
        _name = data['name'] ?? '';
        _address = data['address'] ?? '';
        _avatarUrl = data['profile_image_url'] as String?;
        _locadorStatus = data['locador_status'] ?? 'inactive';
      });
    } catch (_) {
      // Falha silenciosa
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLocadorStatus() {
    String text = '';
    Color color = AppTheme.primaryBlack;
    IconData icon = Icons.storefront;

    if (_locadorStatus == 'pending') {
      text = 'Locador: Em Análise';
      color = Colors.orange;
      icon = Icons.hourglass_empty;
    } else if (_locadorStatus == 'approved') {
      text = 'Painel do Locador';
      color = Colors.green;
      icon = Icons.store_mall_directory;
    } else if (_locadorStatus == 'rejected') {
      text = 'Locador: Rejeitado (Tentar Novamente)';
      color = Colors.red;
    } else {
      text = 'Tornar-se Locador';
    }

    return _buildOption(icon, text, () async {
      if (_locadorStatus == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sua solicitação está em análise.')),
        );
        return;
      }
      
      if (_locadorStatus == 'approved') {
        // TODO: Navigate to Locador Dashboard when created
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Painel do Locador em breve.')),
        );
        return;
      }

      await Navigator.pushNamed(context, '/locador_register');
      setState(() => _isLoading = true);
      _loadProfile();
    }, color: color);
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

                        Text(
                          _name.isNotEmpty ? _name : 'Sem nome cadastrado',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlack,
                          ),
                        ),

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
                    setState(() => _isLoading = true);
                    _loadProfile();
                  }),
                  _buildLocadorStatus(),
                  _buildOption(Icons.help_outline, 'Obter ajuda', () {}),
                  _buildOption(Icons.gavel_outlined, 'JURÍDICO', () {
                    Navigator.pushNamed(context, '/legal');
                  }),
                  _buildOption(Icons.logout, 'Sair da conta', () async {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
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

  Widget _buildOption(IconData icon, String title, VoidCallback onTap, {Color color = AppTheme.primaryBlack}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

