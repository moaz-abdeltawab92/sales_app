import 'package:equatable/equatable.dart';

/// Domain entity representing a Customer (res.partner where customer_rank > 0).
class Customer extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String address;
  final int customerRank;
  final bool isOfflineCached;
  final bool hasPendingUpdate;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.address,
    required this.customerRank,
    this.isOfflineCached = false,
    this.hasPendingUpdate = false,
  });

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? city,
    String? address,
    int? customerRank,
    bool? isOfflineCached,
    bool? hasPendingUpdate,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      address: address ?? this.address,
      customerRank: customerRank ?? this.customerRank,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
      hasPendingUpdate: hasPendingUpdate ?? this.hasPendingUpdate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    city,
    address,
    customerRank,
    isOfflineCached,
    hasPendingUpdate,
  ];
}
