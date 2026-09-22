import '../../domain/entities/sale_order_line.dart';

/// Data model representing a sale order line (sale.order.line).
class SaleOrderLineModel extends SaleOrderLine {
  const SaleOrderLineModel({
    required super.id,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
  });

  factory SaleOrderLineModel.fromJson(Map<String, dynamic> json) {
    return SaleOrderLineModel(
      id: json['id'] as int? ?? 0,
      productName: json['name'] as String? ?? json['product_name'] as String? ?? 'Product',
      quantity: (json['product_uom_qty'] as num?)?.toDouble() ?? (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['price_unit'] as num?)?.toDouble() ?? (json['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'product_uom_qty': quantity,
      'price_unit': unitPrice,
      'price_subtotal': subtotal,
    };
  }
}
