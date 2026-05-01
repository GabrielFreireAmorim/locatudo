import 'package:flutter/material.dart';
import '../app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // Exibe a splash por 3 segundos e navega com fade
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
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
            // Ilustração estilizada (Mãos e Chave de fenda)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryBlack, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                    width: 150,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppTheme.primaryBlack, width: 1.5),
                    ),
                  ),
                  const Icon(
                    Icons.handshake_outlined,
                    size: 60,
                    color: AppTheme.primaryOrange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

