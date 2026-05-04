class ProductModel {
  final String id;
  final String ownerId;
  final String categoryId;
  final String title;
  final String description;
  final String imageUrl;
  final String pricingType; // 'DAILY' ou 'HOURLY'
  final double price;
  final int stockQuantity;
  final bool pickupLocally;
  final String? pickupTimeStart; // Formato HH:mm:ss ou nulo
  final String? pickupTimeEnd;
  final String? pickupDays; // 'ALL_DAYS', 'WEEKDAYS', 'WEEKENDS'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.ownerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pricingType,
    required this.price,
    required this.stockQuantity,
    required this.pickupLocally,
    this.pickupTimeStart,
    this.pickupTimeEnd,
    this.pickupDays,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      pricingType: json['pricing_type'] as String,
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      pickupLocally: json['pickup_locally'] as bool,
      pickupTimeStart: json['pickup_time_start'] as String?,
      pickupTimeEnd: json['pickup_time_end'] as String?,
      pickupDays: json['pickup_days'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? ownerId,
    String? categoryId,
    String? title,
    String? description,
    String? imageUrl,
    String? pricingType,
    double? price,
    int? stockQuantity,
    bool? pickupLocally,
    String? pickupTimeStart,
    String? pickupTimeEnd,
    String? pickupDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      pricingType: pricingType ?? this.pricingType,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      pickupLocally: pickupLocally ?? this.pickupLocally,
      pickupTimeStart: pickupTimeStart ?? this.pickupTimeStart,
      pickupTimeEnd: pickupTimeEnd ?? this.pickupTimeEnd,
      pickupDays: pickupDays ?? this.pickupDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
