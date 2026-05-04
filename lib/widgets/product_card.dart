import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Card de produto reutilizável do LocaTudo.
/// Exibido na grade de categorias da ProductListScreen (2 colunas).
///
/// Parâmetros:
/// - [title]       : Nome do produto (ex: "Betoneira").
/// - [pricePerDay] : Preço em reais por dia (ex: 80.00).
/// - [imageUrl]    : URL da imagem do produto. Se nulo, exibe placeholder.
/// - [onTap]       : Callback ao pressionar o card (navega para ProductDetail).
class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String pricingType; // 'DAILY' ou 'HOURLY'
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.pricingType,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usa LayoutBuilder para adaptar a altura da imagem ao espaço disponível
    return LayoutBuilder(
      builder: (context, constraints) {
        // A altura da imagem é proporcional à largura do card (ratio ~1:1)
        final double imageHeight = constraints.maxWidth * 0.85;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem do produto
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: _buildImage(),
                  ),
                ),

                // Informações do produto
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do produto
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Preço por dia
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price
                                  .toStringAsFixed(2)
                                  .replaceAll('.', ','),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlack,
                              ),
                            ),
                            TextSpan(
                              text: pricingType == 'DAILY' ? ' / dia' : ' / hora',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Constrói a imagem do produto ou um placeholder com ícone caso [imageUrl] seja nulo.
  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        // Exibe placeholder enquanto carrega
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder();
        },
        // Em caso de erro, exibe placeholder
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
  }

  /// Widget de placeholder exibido quando não há imagem disponível.
  Widget _placeholder() {
    return Container(
      color: AppTheme.borderGrey,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppTheme.textGrey,
        ),
      ),
    );
  }
}
