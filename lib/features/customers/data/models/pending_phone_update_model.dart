import 'package:equatable/equatable.dart';

/// Data model representing an offline pending phone update to be synced to Odoo.
class PendingCustomerPhoneUpdateModel extends Equatable {
  final int customerId;
  final String phone;

  const PendingCustomerPhoneUpdateModel({
    required this.customerId,
    required this.phone,
  });

  factory PendingCustomerPhoneUpdateModel.fromJson(Map<String, dynamic> json) {
    return PendingCustomerPhoneUpdateModel(
      customerId: json['customer_id'] as int? ?? 0,
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [customerId, phone];
}
