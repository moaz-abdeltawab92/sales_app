import '../../domain/entities/sale_order.dart';
import 'sale_order_line_model.dart';

/// Data model representing a sales order (sale.order).
class SaleOrderModel extends SaleOrder {
  const SaleOrderModel({
    required super.id,
    required super.orderNumber,
    required super.customerName,
    required super.orderDate,
    required super.status,
    required super.lines,
    required super.totalAmount,
  });

  factory SaleOrderModel.fromJson(Map<String, dynamic> json) {
    final rawLines =
        json['order_line'] as List<dynamic>? ??
        json['lines'] as List<dynamic>? ??
        [];
    final linesList = rawLines
        .map((l) => SaleOrderLineModel.fromJson(l as Map<String, dynamic>))
        .toList();

    return SaleOrderModel(
      id: json['id'] as int? ?? 0,
      orderNumber:
          json['name'] as String? ?? json['order_number'] as String? ?? '',
      customerName:
          json['partner_name'] as String? ??
          json['customer_name'] as String? ??
          'Customer',
      orderDate: json['date_order'] != null
          ? DateTime.parse(json['date_order'] as String)
          : DateTime.now(),
      status: json['state'] as String? ?? json['status'] as String? ?? 'draft',
      lines: linesList,
      totalAmount:
          (json['amount_total'] as num?)?.toDouble() ??
          (json['total_amount'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': orderNumber,
      'partner_name': customerName,
      'date_order': orderDate.toIso8601String(),
      'state': status,
      'order_line': lines.map((l) {
        if (l is SaleOrderLineModel) return l.toJson();
        return SaleOrderLineModel(
          id: l.id,
          productName: l.productName,
          quantity: l.quantity,
          unitPrice: l.unitPrice,
        ).toJson();
      }).toList(),
      'amount_total': totalAmount,
    };
  }
}
