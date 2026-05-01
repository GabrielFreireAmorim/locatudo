import 'dart:convert';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/rental_model.dart';

/// Simulamos um banco de dados local armazenando strings JSON.
/// Na vida real, estas seriam respostas de uma API REST ou documentos do Firebase.
class MockDatabase {
  static const String userJson = '''
  {
    "id": "u1",
    "name": "João Locatário",
    "email": "joao@example.com",
    "phone": "(11) 98765-4321",
    "address": "Rua das Flores, 123",
    "createdAt": "2023-01-15T10:00:00.000Z"
  }
  ''';

  static const String productsJson = '''
  [
    {
      "id": "p1",
      "ownerId": "u2",
      "title": "Betoneira 400L",
      "description": "Betoneira em ótimo estado para sua obra.",
      "pricePerDay": 80.0,
      "category": "Ferramentas",
      "isAvailable": true,
      "createdAt": "2023-02-10T14:30:00.000Z"
    },
    {
      "id": "p2",
      "ownerId": "u3",
      "title": "Pula Pula Infantil",
      "description": "Pula pula colorido de 2,3m. Acompanha rede de proteção.",
      "pricePerDay": 85.0,
      "category": "Festa",
      "isAvailable": true,
      "createdAt": "2023-03-05T09:15:00.000Z"
    }
  ]
  ''';

  static const String rentalsJson = '''
  [
    {
      "id": "r1",
      "productId": "p2",
      "tenantId": "u1",
      "landlordId": "u3",
      "startDate": "2026-10-12T13:00:00.000Z",
      "endDate": "2026-10-12T19:00:00.000Z",
      "status": "CONFIRMED",
      "totalPrice": 85.0,
      "address": "Rua das Flores, 123 - Salão de Festas",
      "createdAt": "2026-10-01T10:00:00.000Z"
    }
  ]
  ''';
}

/// Repositório de Usuários
class UserRepository {
  // Simula uma requisição HTTP com delay
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final Map<String, dynamic> data = jsonDecode(MockDatabase.userJson);
    return UserModel.fromJson(data);
  }

  // Simula salvar/atualizar um usuário (converte para JSON)
  Future<void> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final jsonStr = jsonEncode(user.toJson());
    // print("Usuário salvo no banco: $jsonStr");
  }
}

/// Repositório de Produtos
class ProductRepository {
  Future<List<ProductModel>> getAvailableProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    final List<dynamic> data = jsonDecode(MockDatabase.productsJson);
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<void> createProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final jsonStr = jsonEncode(product.toJson());
    // print("Produto cadastrado no banco: $jsonStr");
  }
}

/// Repositório de Locações
class RentalRepository {
  Future<List<RentalModel>> getUserRentals(String userId) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final List<dynamic> data = jsonDecode(MockDatabase.rentalsJson);

    // Filtramos localmente para simular query do banco
    return data
        .map((json) => RentalModel.fromJson(json))
        .where((rental) =>
            rental.tenantId == userId || rental.landlordId == userId)
        .toList();
  }

  Future<void> updateRentalStatus(String rentalId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simularia buscar a locação e atualizar no banco
    // print("Locação $rentalId atualizada para status: $newStatus");
  }
}
