import '../entities/sale_order.dart';
import '../repositories/sales_orders_repository.dart';

class GetSalesOrdersUseCase {
  final SalesOrdersRepository repository;

  const GetSalesOrdersUseCase(this.repository);

  Future<List<SaleOrder>> call() async {
    return await repository.getSalesOrders();
  }
}
