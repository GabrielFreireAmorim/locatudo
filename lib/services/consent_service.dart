import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../repositories/consent_repository.dart';
import '../services/supabase_service.dart';

/// Versão atual dos Termos de Uso.
/// Altere este valor para forçar uma nova rodada de aceite.
const String kCurrentTermsVersion = 'v1.0';

/// Serviço responsável pela lógica de negócio dos Termos de Uso.
/// Abstrai a verificação e o registro de aceite dos termos,
/// mantendo a UI e o repositório desacoplados.
class ConsentService {
  final ConsentRepository _repository;

  ConsentService({ConsentRepository? repository})
      : _repository = repository ?? ConsentRepository();

  // ----------------------------------------------------------------
  // Verificação
  // ----------------------------------------------------------------

  /// Retorna `true` se o usuário autenticado já aceitou a versão
  /// atual dos termos. Retorna `false` se não aceitou ou se não
  /// há usuário logado.
  Future<bool> hasAcceptedCurrentTerms() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return false;

      final consent = await _repository.findConsent(
        userId: user.id,
        termsVersion: kCurrentTermsVersion,
      );

      return consent != null;
    } catch (e) {
      debugPrint('[ConsentService] Erro ao verificar termos: $e');
      // Em caso de falha de rede, não bloqueamos o usuário silenciosamente;
      // a TermsPage tratará o erro ao tentar salvar.
      return false;
    }
  }

  // ----------------------------------------------------------------
  // Aceite
  // ----------------------------------------------------------------

  /// Registra o aceite dos termos pelo usuário autenticado.
  /// Tenta capturar o IP do cliente; em caso de falha, persiste sem IP.
  Future<void> acceptTerms() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado. Faça login e tente novamente.');
    }

    final ip = await _fetchClientIp();

    await _repository.saveConsent(
      userId: user.id,
      termsVersion: kCurrentTermsVersion,
      ipAddress: ip,
    );
  }

  // ----------------------------------------------------------------
  // IP
  // ----------------------------------------------------------------

  /// Captura o IP público do dispositivo via ipify.org.
  /// Retorna `null` em caso de falha (timeout, sem rede, etc.).
  Future<String?> _fetchClientIp() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (e) {
      debugPrint('[ConsentService] Falha ao obter IP: $e');
    }
    return null;
  }
}
