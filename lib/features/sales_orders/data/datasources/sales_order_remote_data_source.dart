import '../../../../core/errors/failures.dart';
import '../models/sale_order_line_model.dart';
import '../models/sale_order_model.dart';

abstract class SalesOrderRemoteDataSource {
  Future<List<SaleOrderModel>> getSalesOrders();
  Future<SaleOrderModel> confirmSalesOrder(int orderId);
}

/// Isolated Mock Data Source for Sales Orders (sale.order model).
/// Includes draft (quotation) and confirmed (sale) orders with session-persistent confirmation.
class MockSalesOrderDataSource implements SalesOrderRemoteDataSource {
  final List<SaleOrderModel> _mockOrders = [
    SaleOrderModel(
      id: 201,
      orderNumber: 'SO001',
      customerName: 'Acme Corporation',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'draft', // Quotation state available for confirmation
      lines: const [
        SaleOrderLineModel(
          id: 1,
          productName: 'Enterprise ERP License (Annual)',
          quantity: 2,
          unitPrice: 1500.00,
        ),
        SaleOrderLineModel(
          id: 2,
          productName: 'Implementation Consulting (Hours)',
          quantity: 10,
          unitPrice: 120.00,
        ),
      ],
      totalAmount: 4200.00,
    ),
    SaleOrderModel(
      id: 202,
      orderNumber: 'SO002',
      customerName: 'Global Logistics Ltd',
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: 'sale', // Already Confirmed state
      lines: const [
        SaleOrderLineModel(
          id: 3,
          productName: 'Cloud Server Hosting Unit',
          quantity: 5,
          unitPrice: 450.00,
        ),
      ],
      totalAmount: 2250.00,
    ),
    SaleOrderModel(
      id: 203,
      orderNumber: 'SO003',
      customerName: 'Nile Tech Solutions',
      orderDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'draft', // Quotation state
      lines: const [
        SaleOrderLineModel(
          id: 4,
          productName: 'Custom Module Development',
          quantity: 1,
          unitPrice: 3200.00,
        ),
        SaleOrderLineModel(
          id: 5,
          productName: 'Priority Support Subscription',
          quantity: 1,
          unitPrice: 800.00,
        ),
      ],
      totalAmount: 4000.00,
    ),
  ];

  @override
  Future<List<SaleOrderModel>> getSalesOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockOrders);
  }

  @override
  Future<SaleOrderModel> confirmSalesOrder(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw const ServerFailure('Sales Order not found');
    }

    final current = _mockOrders[index];

    // Simulate Odoo business action workflow (action_confirm)
    final confirmedOrder = SaleOrderModel(
      id: current.id,
      orderNumber: current.orderNumber,
      customerName: current.customerName,
      orderDate: current.orderDate,
      status: 'sale', // Odoo confirmed state
      lines: current.lines,
      totalAmount: current.totalAmount,
    );

    _mockOrders[index] = confirmedOrder;
    return confirmedOrder;
  }
}
