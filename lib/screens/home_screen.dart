import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/google_sign_in_button.dart';
import '../services/auth_service.dart';
import '../repositories/supabase_repository.dart';
import '../services/consent_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _userRepository = SupabaseUserRepository();
  final _consentService = ConsentService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await _authService.signInWithGoogle();
      final user = response.user;
      
      if (user != null && mounted) {
        // Verifica se o usuário já tem o perfil completo na tabela users
        final userModel = await _userRepository.getUser(user.id);
        
        if (!mounted) return;
        
        final acceptedTerms = await _consentService.hasAcceptedCurrentTerms();
        if (!mounted) return;

        if (!acceptedTerms) {
          Navigator.pushReplacementNamed(context, '/terms');
          return;
        }

        // Se o usuário não existe na tabela pública ou se faltam dados (ex: address), 
        // manda para a tela de completar o cadastro. 
        // Obs: assumindo que um usuário "completo" tenha endereço ou telefone preenchido
        if (userModel == null || userModel.address == null || userModel.address!.isEmpty) {
          Navigator.pushNamed(context, '/user_register');
        } else {
          Navigator.pushReplacementNamed(context, '/product_list');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro Google: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              
              // Logo com RichText para cores diferentes
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    fontFamily: 'Roboto',
                  ),
                  children: [
                    TextSpan(
                      text: 'LOCA',
                      style: TextStyle(color: AppTheme.primaryBlack),
                    ),
                    TextSpan(
                      text: 'TUDO',
                      style: TextStyle(color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomButton(
                          label: 'Entrar',
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                        ),
                        const SizedBox(height: 15),
                        CustomButton(
                          label: 'Cadastrar',
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // "or" separator
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.borderGrey, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppTheme.borderGrey, thickness: 1)),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        googleSignInButton(onPressed: _handleGoogleLogin),
                      ],
                    ),
                    
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
