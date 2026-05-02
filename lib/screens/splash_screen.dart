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

