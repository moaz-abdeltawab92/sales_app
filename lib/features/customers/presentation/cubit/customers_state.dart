import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

class CustomersLoaded extends CustomersState {
  final List<Customer> customers;
  final String searchQuery;

  const CustomersLoaded({
    required this.customers,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [customers, searchQuery];
}

class CustomersEmpty extends CustomersState {
  final String searchQuery;

  const CustomersEmpty({this.searchQuery = ''});

  @override
  List<Object?> get props => [searchQuery];
}

class CustomersError extends CustomersState {
  final String message;

  const CustomersError(this.message);

  @override
  List<Object?> get props => [message];
}
