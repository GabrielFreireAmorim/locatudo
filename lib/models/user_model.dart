class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? cpf;
  final String? address; // Full address string
  final String? profileImageUrl;
  final DateTime? createdAt;
  
  // Locador fields
  final String? locadorStatus;
  final String? personType;
  final String? whatsapp;
  final String? documentUrl;
  final String? storeName;
  final String? storeDescription;
  final String? storeCategory;
  final bool? acceptedLocadorTerms;
  
  // Detailed address fields
  final String? addressCep;
  final String? addressStreet;
  final String? addressNumber;
  final String? addressCity;
  final String? addressState;
  final String? addressComplement;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.cpf,
    this.address,
    this.profileImageUrl,
    this.createdAt,
    this.locadorStatus,
    this.personType,
    this.whatsapp,
    this.documentUrl,
    this.storeName,
    this.storeDescription,
    this.storeCategory,
    this.acceptedLocadorTerms,
    this.addressCep,
    this.addressStreet,
    this.addressNumber,
    this.addressCity,
    this.addressState,
    this.addressComplement,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      cpf: json['cpf'] as String?,
      address: json['address'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      locadorStatus: json['locador_status'] as String?,
      personType: json['person_type'] as String?,
      whatsapp: json['whatsapp'] as String?,
      documentUrl: json['document_url'] as String?,
      storeName: json['store_name'] as String?,
      storeDescription: json['store_description'] as String?,
      storeCategory: json['store_category'] as String?,
      acceptedLocadorTerms: json['accepted_locador_terms'] as bool?,
      addressCep: json['address_cep'] as String?,
      addressStreet: json['address_street'] as String?,
      addressNumber: json['address_number'] as String?,
      addressCity: json['address_city'] as String?,
      addressState: json['address_state'] as String?,
      addressComplement: json['address_complement'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'cpf': cpf,
      'address': address,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'locador_status': locadorStatus,
      'person_type': personType,
      'whatsapp': whatsapp,
      'document_url': documentUrl,
      'store_name': storeName,
      'store_description': storeDescription,
      'store_category': storeCategory,
      'accepted_locador_terms': acceptedLocadorTerms,
      'address_cep': addressCep,
      'address_street': addressStreet,
      'address_number': addressNumber,
      'address_city': addressCity,
      'address_state': addressState,
      'address_complement': addressComplement,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? cpf,
    String? address,
    String? profileImageUrl,
    DateTime? createdAt,
    String? locadorStatus,
    String? personType,
    String? whatsapp,
    String? documentUrl,
    String? storeName,
    String? storeDescription,
    String? storeCategory,
    bool? acceptedLocadorTerms,
    String? addressCep,
    String? addressStreet,
    String? addressNumber,
    String? addressCity,
    String? addressState,
    String? addressComplement,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      locadorStatus: locadorStatus ?? this.locadorStatus,
      personType: personType ?? this.personType,
      whatsapp: whatsapp ?? this.whatsapp,
      documentUrl: documentUrl ?? this.documentUrl,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
      storeCategory: storeCategory ?? this.storeCategory,
      acceptedLocadorTerms: acceptedLocadorTerms ?? this.acceptedLocadorTerms,
      addressCep: addressCep ?? this.addressCep,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      addressComplement: addressComplement ?? this.addressComplement,
    );
  }
}
