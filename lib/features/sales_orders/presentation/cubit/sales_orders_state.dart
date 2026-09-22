import 'package:equatable/equatable.dart';
import '../../domain/entities/sale_order.dart';

abstract class SalesOrdersState extends Equatable {
  const SalesOrdersState();

  @override
  List<Object?> get props => [];
}

class SalesOrdersInitial extends SalesOrdersState {
  const SalesOrdersInitial();
}

class SalesOrdersLoading extends SalesOrdersState {
  const SalesOrdersLoading();
}

class SalesOrdersLoaded extends SalesOrdersState {
  final List<SaleOrder> orders;

  const SalesOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class SalesOrdersEmpty extends SalesOrdersState {
  const SalesOrdersEmpty();
}

class SalesOrdersError extends SalesOrdersState {
  final String message;

  const SalesOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
