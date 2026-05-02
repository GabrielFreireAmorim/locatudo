import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_consent_model.dart';
import '../services/supabase_service.dart';

/// Acessa a tabela `user_consents` no Supabase.
/// Todas as operações são vinculadas ao usuário autenticado (RLS).
class ConsentRepository {
  static const String _table = 'user_consents';

  final SupabaseClient _client = SupabaseService.client;

  /// Verifica se o usuário já aceitou uma determinada versão dos termos.
  /// Retorna [UserConsentModel] se existir, ou null caso não haja registro.
  Future<UserConsentModel?> findConsent({
    required String userId,
    required String termsVersion,
  }) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('terms_version', termsVersion)
        .maybeSingle();

    if (response == null) return null;
    return UserConsentModel.fromJson(response);
  }

  /// Salva o aceite do usuário na tabela `user_consents`.
  /// Retorna o [UserConsentModel] recém-criado.
  Future<UserConsentModel> saveConsent({
    required String userId,
    required String termsVersion,
    String? ipAddress,
  }) async {
    final response = await _client
        .from(_table)
        .insert({
          'user_id': userId,
          'terms_version': termsVersion,
          'ip_address': ipAddress,
          // `accepted_at` tem DEFAULT now() no banco; incluímos aqui por clareza
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();

    return UserConsentModel.fromJson(response);
  }
}
