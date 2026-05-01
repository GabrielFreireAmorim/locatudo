import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  // Retorna o usuário logado atualmente (ou nulo se não houver)
  User? get currentUser => _client.auth.currentUser;

  // Retorna um Stream do estado da autenticação para atualizar o app em tempo real
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Login com Google (Fluxo Nativo para Android/iOS - Compatível com google_sign_in 7.x)
  Future<AuthResponse> signInWithGoogle() async {
    // Para funcionar no Android com Supabase, é OBRIGATÓRIO passar o serverClientId (seu Web Client ID do Google Cloud)
    // IMPORTANTE: Use SEMPRE o Web Client ID (tipo "Web application" no Google Cloud Console).
    // O Android Client ID (fg9088) NÃO funciona como serverClientId — ele é usado
    // apenas internamente pelo SDK nativo. O Web Client ID (dpnc5) é validado pelo Supabase.
    const webClientId = String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: '438351340431-0qprm7kojtrjl1tnc5547567l3tdpnc5.apps.googleusercontent.com',
    );

    // 1. Inicializa a instância única com o serverClientId (Web Client ID)
    await GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
    );

    // 2. Inicia o fluxo de autenticação
    final googleUser = await GoogleSignIn.instance.authenticate();
    
    // 3. Obtém os tokens
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'Não foi possível obter o ID Token do Google. Certifique-se de que o serverClientId está correto.';
    }

    // Pede autorização para obter o accessToken (necessário para o Supabase em alguns fluxos)
    final authorizedUser = await googleUser.authorizationClient.authorizeScopes([
      'email',
      'profile',
      'openid',
    ]);
    
    final accessToken = authorizedUser.accessToken;

    // 4. Autentica no Supabase usando os tokens obtidos
    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Cadastro de um novo usuário (E-mail e Senha)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  /// Login com E-mail e Senha
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Deslogar
  Future<void> signOut() async {
    await Future.wait([
      _client.auth.signOut(),
      GoogleSignIn.instance.signOut(), 
    ]);
  }

  /// Recuperação de Senha
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
