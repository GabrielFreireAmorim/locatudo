class ProductModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double pricePerDay;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.pricePerDay,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'pricePerDay': pricePerDay,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    double? pricePerDay,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
