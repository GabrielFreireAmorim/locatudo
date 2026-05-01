import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/rental_model.dart';
import '../services/supabase_service.dart';

/// Implementação Real dos Repositórios consumindo o Supabase
class SupabaseUserRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<UserModel?> getUser(String userId) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle(); // Retorna null se não encontrar

    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<void> updateUser(UserModel user) async {
    await _client.from('users').update({
      'name': user.name,
      'phone': user.phone,
      'address': user.address,
      'profile_image_url': user.profileImageUrl,
    }).eq('id', user.id);
  }
}

class SupabaseProductRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<ProductModel>> getAvailableProducts() async {
    final data = await _client
        .from('products')
        .select()
        .eq('is_available', true)
        .order('created_at', ascending: false);

    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final data = await _client
        .from('products')
        .select()
        .eq('category', category)
        .eq('is_available', true);

    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<void> createProduct(ProductModel product) async {
    await _client.from('products').insert(product.toJson());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _client.from('products').update(product.toJson()).eq('id', product.id);
  }
}

class SupabaseRentalRepository {
  final SupabaseClient _client = SupabaseService.client;

  // Busca locações onde o usuário atual é o locatário
  Future<List<RentalModel>> getTenantRentals(String tenantId) async {
    final data = await _client
        .from('rentals')
        .select()
        .eq('tenant_id', tenantId)
        .order('start_date', ascending: false);

    return data.map((json) => RentalModel.fromJson(json)).toList();
  }

  // Busca locações onde o usuário atual é o locador (dono do produto)
  Future<List<RentalModel>> getLandlordRentals(String landlordId) async {
    final data = await _client
        .from('rentals')
        .select()
        .eq('landlord_id', landlordId)
        .order('start_date', ascending: false);

    return data.map((json) => RentalModel.fromJson(json)).toList();
  }

  Future<void> createRental(RentalModel rental) async {
    await _client.from('rentals').insert(rental.toJson());
  }

  Future<void> updateRentalStatus(String rentalId, String newStatus) async {
    await _client.from('rentals').update({'status': newStatus}).eq('id', rentalId);
  }
}
