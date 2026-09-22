import '../entities/sale_order.dart';
import '../repositories/sales_orders_repository.dart';

class ConfirmSalesOrderUseCase {
  final SalesOrdersRepository repository;

  const ConfirmSalesOrderUseCase(this.repository);

  Future<SaleOrder> call(int orderId) async {
    return await repository.confirmSalesOrder(orderId);
  }
}
