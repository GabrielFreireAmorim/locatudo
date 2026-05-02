/// Representa um registro na tabela `user_consents` do Supabase.
class UserConsentModel {
  final String id;
  final String userId;
  final String termsVersion;
  final DateTime acceptedAt;
  final String? ipAddress;

  const UserConsentModel({
    required this.id,
    required this.userId,
    required this.termsVersion,
    required this.acceptedAt,
    this.ipAddress,
  });

  factory UserConsentModel.fromJson(Map<String, dynamic> json) {
    return UserConsentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      termsVersion: json['terms_version'] as String,
      acceptedAt: DateTime.parse(json['accepted_at'] as String),
      ipAddress: json['ip_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'terms_version': termsVersion,
      'accepted_at': acceptedAt.toIso8601String(),
      'ip_address': ipAddress,
    };
  }
}
