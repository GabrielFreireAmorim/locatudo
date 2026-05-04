import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import 'dart:io';

class UserRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar perfil do usuário: $e');
    }
  }

  Future<void> submitLocadorApplication({
    required String userId,
    required String personType,
    required String phone,
    required String whatsapp,
    required String storeName,
    required String storeDescription,
    required String storeCategory,
    required String addressCep,
    required String addressStreet,
    required String addressNumber,
    required String addressCity,
    required String addressState,
    required bool acceptedTerms,
    File? documentFile,
    String? existingDocUrl,
  }) async {
    try {
      String? documentUrl = existingDocUrl;

      // 1. Upload document if provided
      if (documentFile != null) {
        final fileExt = documentFile.path.split('.').last.toLowerCase();
        final filePath = '$userId/locador_doc.$fileExt';
        final mimeType = fileExt == 'pdf' 
            ? 'application/pdf' 
            : (fileExt == 'jpg' ? 'image/jpeg' : 'image/$fileExt');

        await _client.storage.from('locador_docs').uploadBinary(
              filePath,
              await documentFile.readAsBytes(),
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: true,
              ),
            );

        // Locador docs is private, but we store the path or signed url.
        // For private buckets, getPublicUrl doesn't work for unauthorized users, 
        // but it's fine to just save the path or the public URL format since the admin/user will use createSignedUrl to view it later.
        documentUrl = filePath; 
      }

      // 2. Update users table
      await _client.from('users').update({
        'locador_status': 'pending',
        'person_type': personType,
        'phone': phone,
        'whatsapp': whatsapp,
        'document_url': documentUrl,
        'store_name': storeName,
        'store_description': storeDescription,
        'store_category': storeCategory,
        'accepted_locador_terms': acceptedTerms,
        'address_cep': addressCep,
        'address_street': addressStreet,
        'address_number': addressNumber,
        'address_city': addressCity,
        'address_state': addressState,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Erro ao enviar solicitação de locador: $e');
    }
  }
}
