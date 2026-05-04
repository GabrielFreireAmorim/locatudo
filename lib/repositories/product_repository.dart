import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';

class ProductRepository {
  final SupabaseClient _client = SupabaseService.client;
  final Uuid _uuid = const Uuid();

  /// Salva um novo produto no banco. Faz o upload da imagem e retorna o modelo atualizado.
  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required String categoryId,
    required String pricingType,
    required double price,
    required int stockQuantity,
    required bool pickupLocally,
    String? pickupTimeStart,
    String? pickupTimeEnd,
    String? pickupDays,
    required List<File> imageFiles,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    if (imageFiles.isEmpty) throw Exception('Nenhuma imagem selecionada');

    // 1. Upload da capa (primeira imagem)
    final coverFile = imageFiles.first;
    final fileExt = coverFile.path.split('.').last;
    final fileName = '${_uuid.v4()}.$fileExt';
    final filePath = '${user.id}/$fileName';

    await _client.storage.from('product_images').upload(
          filePath,
          coverFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final imageUrl = _client.storage.from('product_images').getPublicUrl(filePath);

    // 2. Inserir no Banco
    final response = await _client.from('products').insert({
      'owner_id': user.id,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'pricing_type': pricingType,
      'price': price,
      'stock_quantity': stockQuantity,
      'pickup_locally': pickupLocally,
      'pickup_time_start': pickupTimeStart,
      'pickup_time_end': pickupTimeEnd,
      'pickup_days': pickupDays,
    }).select().single();

    final productId = response['id'] as String;

    // 3. Upload das demais imagens e inserção na tabela product_images
    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      String url = imageUrl;

      if (i > 0) {
        final ext = file.path.split('.').last;
        final name = '${_uuid.v4()}.$ext';
        final path = '${user.id}/$name';
        await _client.storage.from('product_images').upload(
          path,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        url = _client.storage.from('product_images').getPublicUrl(path);
      }

      await _client.from('product_images').insert({
        'product_id': productId,
        'image_url': url,
        'order_index': i,
      });
    }

    return ProductModel.fromJson(response);
  }

  // --- Galeria e Q&A ---

  Future<List<String>> getProductImages(String productId) async {
    final response = await _client
        .from('product_images')
        .select('image_url')
        .eq('product_id', productId)
        .order('order_index', ascending: true);
    return (response as List).map((e) => e['image_url'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getProductQuestions(String productId) async {
    final response = await _client
        .from('product_questions')
        .select()
        .eq('product_id', productId)
        .order('upvotes', ascending: false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addProductQuestion(String productId, String questionText) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Não autenticado');
    await _client.from('product_questions').insert({
      'product_id': productId,
      'user_id': user.id,
      'question_text': questionText,
    });
  }

  Future<void> voteQuestion(String questionId, String voteType) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Não autenticado');
    
    try {
      await _client.from('question_votes').insert({
        'question_id': questionId,
        'user_id': user.id,
        'vote_type': voteType,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique violation
        await _client.from('question_votes')
            .update({'vote_type': voteType})
            .eq('question_id', questionId)
            .eq('user_id', user.id);
      } else {
        rethrow;
      }
    }
  }

  /// Atualiza um produto existente. Como não permitimos mudar a categoria, ela não é passada aqui.
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _client.from('products').update({
      'title': product.title,
      'description': product.description,
      'pricing_type': product.pricingType,
      'price': product.price,
      'stock_quantity': product.stockQuantity,
      'pickup_locally': product.pickupLocally,
      'pickup_time_start': product.pickupTimeStart,
      'pickup_time_end': product.pickupTimeEnd,
      'pickup_days': product.pickupDays,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', product.id).select().single();

    return ProductModel.fromJson(response);
  }

  /// Busca os produtos no banco. Pode filtrar por categoryId opcionalmente.
  Future<List<ProductModel>> getProducts({String? categoryId, String? searchQuery}) async {
    var query = _client.from('products').select();

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }
}
