class RentalModel {
  final String id;
  final String productId;
  final String tenantId;
  final String landlordId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // e.g. 'PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED'
  final double totalPrice;
  final String? address;
  final DateTime? createdAt;

  RentalModel({
    required this.id,
    required this.productId,
    required this.tenantId,
    required this.landlordId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalPrice,
    this.address,
    this.createdAt,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      tenantId: json['tenantId'] as String,
      landlordId: json['landlordId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      address: json['address'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'totalPrice': totalPrice,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  RentalModel copyWith({
    String? id,
    String? productId,
    String? tenantId,
    String? landlordId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? totalPrice,
    String? address,
    DateTime? createdAt,
  }) {
    return RentalModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
