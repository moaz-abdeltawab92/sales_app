import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_sales_orders.dart';
import 'sales_orders_state.dart';

class SalesOrdersCubit extends Cubit<SalesOrdersState> {
  final GetSalesOrdersUseCase getSalesOrdersUseCase;

  SalesOrdersCubit({required this.getSalesOrdersUseCase})
    : super(const SalesOrdersInitial());

  Future<void> fetchSalesOrders({bool showLoading = true}) async {
    if (showLoading) {
      emit(const SalesOrdersLoading());
    }

    try {
      final orders = await getSalesOrdersUseCase();
      if (orders.isEmpty) {
        emit(const SalesOrdersEmpty());
      } else {
        emit(SalesOrdersLoaded(orders));
      }
    } on Failure catch (f) {
      emit(SalesOrdersError(f.message));
    } catch (e) {
      emit(SalesOrdersError(e.toString()));
    }
  }

  void refresh() {
    fetchSalesOrders(showLoading: false);
  }
}
