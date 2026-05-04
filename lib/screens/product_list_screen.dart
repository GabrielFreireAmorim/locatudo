import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/product_card.dart';
import '../services/supabase_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../utils/category_icons.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _categoryRepo = CategoryRepository();
  final _productRepo = ProductRepository();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  
  String? _selectedCategoryId;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _loadData();
  }

  Future<void> _loadAvatar() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;

      final data = await SupabaseService.client
          .from('users')
          .select('profile_image_url')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() => _avatarUrl = data['profile_image_url'] as String?);
      }
    } catch (_) {
      // Falha silenciosa
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categoryRepo.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
      // Após carregar categorias, carrega produtos da primeira
      await _fetchProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: AppTheme.statusRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productRepo.getProducts(
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
      );
      if (mounted) {
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produtos: $e'), backgroundColor: AppTheme.statusRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _searchController.clear();
      _searchQuery = '';
    });
    _fetchProducts();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // Um debounce seria ideal aqui, mas para simplicidade faz a busca direta ou usa um botão.
    // Vamos fazer a busca quando o usuário digitar.
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _columnCount(double screenWidth) {
    if (screenWidth >= 1024) return 4;
    if (screenWidth >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int columns = _columnCount(screenWidth);

    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          // ── Categorias ──────────────────────────────────────────────────
          if (_categories.isNotEmpty)
            SliverToBoxAdapter(
              child: _CategoryBar(
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: _onCategorySelected,
              ),
            ),

          // ── Barra de Busca ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ),

          // ── Título da Seção ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Produtos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
              ),
            ),
          ),

          // ── Grade de Produtos ou Loading ──────────────────────────────
          if (_isLoading && _products.isEmpty)
             const SliverFillRemaining(
               child: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
             )
          else if (_products.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: columns >= 3 ? 0.68 : 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _products[index];
                    return ProductCard(
                      title: product.title,
                      price: product.price, 
                      pricingType: product.pricingType,
                      imageUrl: product.imageUrl,
                      onTap: () {
                         Navigator.pushNamed(context, '/product_detail', arguments: product);
                      },
                    );
                  },
                  childCount: _products.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/product_register').then((_) {
            // Recarrega a lista se voltar do cadastro
            _fetchProducts();
        }),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: AppTheme.primaryWhite,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryWhite,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppTheme.primaryBlack),
        onPressed: () {},
        tooltip: 'Menu',
      ),
      title: const Text(
        'LocaTudo',
        style: TextStyle(
          color: AppTheme.primaryBlack,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/user_profile');
              _loadAvatar();
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.borderGrey,
              backgroundImage:
                  _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null
                  ? const Icon(Icons.person, color: AppTheme.textGrey, size: 22)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Barra de Categorias
// ---------------------------------------------------------------------------

class _CategoryBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const _CategoryBar({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = category.id == selectedCategoryId;

          return GestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? AppTheme.primaryOrange
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CategoryIcons.getIconForSlug(category.slug),
                    size: 26,
                    color:
                        isSelected ? AppTheme.primaryOrange : AppTheme.textGrey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra de Busca
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.primaryBlack, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar produto...',
          hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close,
                      color: AppTheme.textGrey, size: 20),
                  onPressed: onClear,
                )
              : const Icon(Icons.search, color: AppTheme.textGrey, size: 20),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estado vazio
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.borderGrey),
          SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tente outra categoria ou busca.',
            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
