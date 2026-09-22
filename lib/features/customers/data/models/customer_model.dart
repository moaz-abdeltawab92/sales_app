import '../../domain/entities/customer.dart';

/// Data model representing Odoo res.partner customer object.
class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.city,
    required super.address,
    required super.customerRank,
    super.isOfflineCached = false,
    super.hasPendingUpdate = false,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['street'] as String? ?? json['address'] as String? ?? '',
      customerRank: json['customer_rank'] as int? ?? 0,
      isOfflineCached: json['is_offline_cached'] as bool? ?? false,
      hasPendingUpdate: json['has_pending_update'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'city': city,
      'street': address,
      'customer_rank': customerRank,
      'is_offline_cached': isOfflineCached,
      'has_pending_update': hasPendingUpdate,
    };
  }

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      city: customer.city,
      address: customer.address,
      customerRank: customer.customerRank,
      isOfflineCached: customer.isOfflineCached,
      hasPendingUpdate: customer.hasPendingUpdate,
    );
  }
}
