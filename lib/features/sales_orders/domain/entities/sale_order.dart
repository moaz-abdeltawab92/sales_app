import 'package:equatable/equatable.dart';
import 'sale_order_line.dart';

/// Domain entity representing a Sales Order (sale.order).
class SaleOrder extends Equatable {
  final int id;
  final String orderNumber;
  final String customerName;
  final DateTime orderDate;
  final String status; // 'draft' (Quotation) or 'sale' (Confirmed)
  final List<SaleOrderLine> lines;
  final double totalAmount;

  const SaleOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.orderDate,
    required this.status,
    required this.lines,
    required this.totalAmount,
  });

  bool get isDraft =>
      status.toLowerCase() == 'draft' || status.toLowerCase() == 'quotation';
  bool get isConfirmed =>
      status.toLowerCase() == 'sale' || status.toLowerCase() == 'confirmed';

  SaleOrder copyWith({
    int? id,
    String? orderNumber,
    String? customerName,
    DateTime? orderDate,
    String? status,
    List<SaleOrderLine>? lines,
    double? totalAmount,
  }) {
    return SaleOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      lines: lines ?? this.lines,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    customerName,
    orderDate,
    status,
    lines,
    totalAmount,
  ];
}
