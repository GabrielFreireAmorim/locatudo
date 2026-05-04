import 'package:flutter/material.dart';

class CategoryIcons {
  static const Map<String, IconData> _icons = {
    'ferramentas': Icons.construction,
    'eletronicos': Icons.videogame_asset_outlined,
    'esportes_lazer': Icons.sports_soccer_outlined,
    'festas_eventos': Icons.celebration_outlined,
    'limpeza': Icons.cleaning_services_outlined,
  };

  static IconData getIconForSlug(String slug) {
    return _icons[slug] ?? Icons.category_outlined;
  }
}
