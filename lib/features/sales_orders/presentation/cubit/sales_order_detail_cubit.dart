import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sale_order.dart';
import '../../domain/usecases/confirm_sales_order.dart';

abstract class SalesOrderDetailState extends Equatable {
  final SaleOrder order;
  const SalesOrderDetailState(this.order);

  @override
  List<Object?> get props => [order];
}

class SalesOrderDetailInitial extends SalesOrderDetailState {
  const SalesOrderDetailInitial(super.order);
}

class SalesOrderDetailConfirming extends SalesOrderDetailState {
  const SalesOrderDetailConfirming(super.order);
}

class SalesOrderDetailSuccess extends SalesOrderDetailState {
  const SalesOrderDetailSuccess(super.order);
}

class SalesOrderDetailFailure extends SalesOrderDetailState {
  final String message;

  const SalesOrderDetailFailure({
    required SaleOrder order,
    required this.message,
  }) : super(order);

  @override
  List<Object?> get props => [order, message];
}

class SalesOrderDetailCubit extends Cubit<SalesOrderDetailState> {
  final ConfirmSalesOrderUseCase confirmSalesOrderUseCase;

  SalesOrderDetailCubit({
    required SaleOrder initialOrder,
    required this.confirmSalesOrderUseCase,
  }) : super(SalesOrderDetailInitial(initialOrder));

  Future<void> confirmOrder() async {
    final currentOrder = state.order;
    emit(SalesOrderDetailConfirming(currentOrder));

    try {
      final confirmedOrder = await confirmSalesOrderUseCase(currentOrder.id);
      emit(SalesOrderDetailSuccess(confirmedOrder));
    } on Failure catch (f) {
      emit(SalesOrderDetailFailure(order: currentOrder, message: f.message));
    } catch (e) {
      emit(SalesOrderDetailFailure(order: currentOrder, message: e.toString()));
    }
  }
}
