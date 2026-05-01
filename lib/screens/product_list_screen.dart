import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/product_card.dart';

// ---------------------------------------------------------------------------
// Modelos de dado simples (mover para models/ quando integrar backend)
// ---------------------------------------------------------------------------

class _Category {
  final String label;
  final IconData icon;

  const _Category({required this.label, required this.icon});
}

class _Product {
  final String title;
  final double pricePerDay;
  final String? imageUrl;
  final String category;

  const _Product({
    required this.title,
    required this.pricePerDay,
    required this.category,
    this.imageUrl,
  });
}

// ---------------------------------------------------------------------------
// Dados de exemplo
// ---------------------------------------------------------------------------

const List<_Category> _categories = [
  _Category(label: 'Ferramentas', icon: Icons.construction),
  _Category(label: 'Eletrônicos', icon: Icons.videogame_asset_outlined),
  _Category(label: 'Festa', icon: Icons.celebration_outlined),
  _Category(label: 'Veículos', icon: Icons.directions_car_outlined),
  _Category(label: 'Casa', icon: Icons.house_outlined),
];

const List<_Product> _allProducts = [
  _Product(title: 'Betoneira', pricePerDay: 80.00, category: 'Ferramentas'),
  _Product(title: 'Carretinha', pricePerDay: 50.00, category: 'Veículos'),
  _Product(
      title: 'Martelo de Demolição',
      pricePerDay: 35.00,
      category: 'Ferramentas'),
  _Product(
      title: 'Pula Pula 2,3m infantil', pricePerDay: 85.00, category: 'Festa'),
  _Product(title: 'Furadeira', pricePerDay: 25.00, category: 'Ferramentas'),
  _Product(title: 'Mesa Plástica Branca', pricePerDay: 6.00, category: 'Festa'),
  _Product(title: 'Cadeira Plástica', pricePerDay: 1.50, category: 'Festa'),
  _Product(title: 'Smart TV 55"', pricePerDay: 120.00, category: 'Eletrônicos'),
  _Product(
      title: 'Projetor Epson', pricePerDay: 90.00, category: 'Eletrônicos'),
  _Product(title: 'Lava Pressão', pricePerDay: 40.00, category: 'Casa'),
];

// ---------------------------------------------------------------------------
// Tela Principal
// ---------------------------------------------------------------------------

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtra produtos pela categoria selecionada e pelo texto de busca
  List<_Product> get _filteredProducts {
    final selectedCategory = _categories[_selectedCategoryIndex].label;

    return _allProducts.where((p) {
      final matchesCategory =
          selectedCategory == 'Ferramentas' && _selectedCategoryIndex == 0
              ? true // "Todos" — exibe tudo por padrão no índice 0
              : p.category == selectedCategory;

      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Calcula o número de colunas do grid conforme a largura da tela
  int _columnCount(double screenWidth) {
    if (screenWidth >= 1024) return 4; // Tablet Landscape / Desktop
    if (screenWidth >= 600) return 3; // Tablet Portrait
    return 2; // Smartphone (mockup)
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
          SliverToBoxAdapter(
            child: _CategoryBar(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (i) => setState(() {
                _selectedCategoryIndex = i;
                _searchController.clear();
                _searchQuery = '';
              }),
            ),
          ),

          // ── Barra de Busca ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),

          // ── Título da Seção ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Categorias',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
              ),
            ),
          ),

          // ── Grade de Produtos (SliverGrid) ──────────────────────────────
          _filteredProducts.isEmpty
              ? const SliverFillRemaining(child: _EmptyState())
              : SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      // Aspect ratio dinâmico conforme o número de colunas
                      childAspectRatio: columns >= 3 ? 0.68 : 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          title: product.title,
                          pricePerDay: product.pricePerDay,
                          imageUrl: product.imageUrl,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/product_detail',
                          ),
                        );
                      },
                      childCount: _filteredProducts.length,
                    ),
                  ),
                ),

          // Espaçamento inferior para evitar que o último item fique colado no FAB
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // Botão flutuante para cadastrar nova locação
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/product_register'),
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
            onTap: () => Navigator.pushNamed(context, '/user_profile'),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.borderGrey,
              child: Icon(Icons.person, color: AppTheme.textGrey, size: 22),
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
  final List<_Category> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const _CategoryBar({
    required this.categories,
    required this.selectedIndex,
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
          final bool isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onCategorySelected(index),
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
                    category.icon,
                    size: 26,
                    color:
                        isSelected ? AppTheme.primaryOrange : AppTheme.textGrey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.label,
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
// Estado vazio (nenhum produto encontrado)
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
