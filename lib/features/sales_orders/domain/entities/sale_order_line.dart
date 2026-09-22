import 'package:equatable/equatable.dart';

/// Domain entity representing a Sale Order Line item (sale.order.line).
class SaleOrderLine extends Equatable {
  final int id;
  final String productName;
  final double quantity;
  final double unitPrice;

  const SaleOrderLine({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  @override
  List<Object?> get props => [id, productName, quantity, unitPrice];
}
