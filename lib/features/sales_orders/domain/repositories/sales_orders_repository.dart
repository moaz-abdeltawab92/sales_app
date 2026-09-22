import '../entities/sale_order.dart';

/// Abstract repository for Sales Orders.
abstract class SalesOrdersRepository {
  /// Fetches sales orders.
  Future<List<SaleOrder>> getSalesOrders();

  /// Confirms a sales order (business action: draft -> confirmed).
  Future<SaleOrder> confirmSalesOrder(int orderId);
}
