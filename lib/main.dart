import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart' as pls;
import 'screens/product_detail_screen.dart' as pds;
import 'screens/product_register_screen.dart' as prs;
import 'screens/tenant_rentings_screen.dart' as trs;
import 'screens/landlord_rentings_screen.dart' as lrs;
import 'screens/user_screen.dart';
import 'screens/user_register_screen.dart';
import 'services/supabase_service.dart';
import 'screens/signup_screen.dart';
import 'screens/terms_page.dart';

import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseService.initialize();
    // O plugin google_sign_in será inicializado e o webClientId será
    // passado diretamente na instância em AuthService.
  } catch (e) {
    debugPrint('Erro ao inicializar serviços: $e');
  }

  runApp(const LocaTudoApp());
}

class LocaTudoApp extends StatelessWidget {
  const LocaTudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocaTudo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Configuração das rotas iniciais
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignupScreen(),
        '/product_list': (context) => const pls.ProductListScreen(),
        '/product_detail': (context) => const pds.ProductDetailScreen(),
        '/product_register': (context) => const prs.ProductRegisterScreen(),
        '/landlord_rentings': (context) => const lrs.LandlordRentingsScreen(),
        '/tenant_rentings': (context) => const trs.TenantRentingsScreen(),
        '/user_profile': (context) => const UserScreen(),
        '/user_register': (context) => const UserRegisterScreen(),
        '/terms': (context) => const TermsPage(),
      },
    );
  }
}

// ==========================================
// Placeholders para as Telas
// ==========================================

// Telas movidas para arquivos próprios: SplashScreen e LoginScreen

// Telas movidas para arquivos próprios: SplashScreen, HomeScreen e LoginScreen

// Tela Login movida para screens/login_screen.dart

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold com fundo laranja para simular a tela de Cadastro
    return const Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      body: Center(
        child: Text(
          'Register Screen',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

// ProductListScreen movida para screens/product_list_screen.dart

// ProductDetailScreen movida para screens/product_detail_screen.dart
// ProductRegisterScreen movida para screens/product_register_screen.dart

// LandlordRentingsScreen movida para screens/landlord_rentings_screen.dart
// TenantRentingsScreen movida para screens/tenant_rentings_screen.dart

// UserScreen movida para screens/user_screen.dart
// UserRegisterScreen movida para screens/user_register_screen.dart
