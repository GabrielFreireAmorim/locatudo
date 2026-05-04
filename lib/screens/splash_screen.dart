import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../services/consent_service.dart';
import '../repositories/supabase_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _consentService = ConsentService();
  final _userRepository = SupabaseUserRepository();

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // Exibe a splash por 3 segundos
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        // Se houver sessão, verifica termos e perfil
        final acceptedTerms = await _consentService.hasAcceptedCurrentTerms();
        if (!mounted) return;

        if (!acceptedTerms) {
          Navigator.of(context).pushReplacementNamed('/terms');
          return;
        }

        final userModel = await _userRepository.getUser(session.user.id);
        if (!mounted) return;

        // Se o perfil estiver incompleto, manda para registro de usuário
        if (userModel == null || userModel.address == null || userModel.address!.isEmpty) {
          Navigator.of(context).pushReplacementNamed('/user_register');
        } else {
          Navigator.of(context).pushReplacementNamed('/product_list');
        }
      } else {
        // Se não houver sessão, vai para a home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo com RichText para cores diferentes
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  fontFamily: 'Roboto', // Fallback caso não tenha a fonte do mockup
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
            const SizedBox(height: 60),
            // Logo oficial (PNG)
            Image.asset(
              'assets/images/logo.png',
              width: 240,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

