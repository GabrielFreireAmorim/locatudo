import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../services/supabase_service.dart';

class CategoryRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
  }
}
