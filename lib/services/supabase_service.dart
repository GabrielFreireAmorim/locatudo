import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    // Carrega o arquivo .env
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase URL ou Anon Key não encontrados no arquivo .env');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // PKCE é obrigatório para o fluxo nativo do Google Sign-In no Android/iOS.
      // Garante que o signInWithIdToken funcione corretamente com o Supabase.
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // Atalho para acessar o client em qualquer parte do app
  static SupabaseClient get client => Supabase.instance.client;
}
