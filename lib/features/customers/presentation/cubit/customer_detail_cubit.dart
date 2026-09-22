import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/update_customer_phone.dart';

abstract class CustomerDetailState extends Equatable {
  final Customer customer;
  const CustomerDetailState(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerDetailInitial extends CustomerDetailState {
  const CustomerDetailInitial(super.customer);
}

class CustomerDetailSaving extends CustomerDetailState {
  const CustomerDetailSaving(super.customer);
}

class CustomerDetailSuccess extends CustomerDetailState {
  const CustomerDetailSuccess(super.customer);
}

class CustomerDetailFailure extends CustomerDetailState {
  final String message;

  const CustomerDetailFailure({
    required Customer customer,
    required this.message,
  }) : super(customer);

  @override
  List<Object?> get props => [customer, message];
}

class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  final UpdateCustomerPhoneUseCase updateCustomerPhoneUseCase;

  CustomerDetailCubit({
    required Customer initialCustomer,
    required this.updateCustomerPhoneUseCase,
  }) : super(CustomerDetailInitial(initialCustomer));

  Future<void> updatePhone(String newPhone) async {
    final currentCustomer = state.customer;
    emit(CustomerDetailSaving(currentCustomer));

    try {
      final updatedCustomer = await updateCustomerPhoneUseCase(
        customerId: currentCustomer.id,
        newPhone: newPhone,
      );
      emit(CustomerDetailSuccess(updatedCustomer));
    } on Failure catch (f) {
      emit(CustomerDetailFailure(customer: currentCustomer, message: f.message));
    } catch (e) {
      emit(CustomerDetailFailure(customer: currentCustomer, message: e.toString()));
    }
  }
}
