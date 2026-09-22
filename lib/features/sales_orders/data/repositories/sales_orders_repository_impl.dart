import '../../../../core/errors/failures.dart';
import '../../domain/entities/sale_order.dart';
import '../../domain/repositories/sales_orders_repository.dart';
import '../datasources/sales_order_remote_data_source.dart';

class SalesOrdersRepositoryImpl implements SalesOrdersRepository {
  final SalesOrderRemoteDataSource remoteDataSource;

  const SalesOrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SaleOrder>> getSalesOrders() async {
    try {
      final orders = await remoteDataSource.getSalesOrders();
      return orders;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<SaleOrder> confirmSalesOrder(int orderId) async {
    try {
      final confirmed = await remoteDataSource.confirmSalesOrder(orderId);
      return confirmed;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
