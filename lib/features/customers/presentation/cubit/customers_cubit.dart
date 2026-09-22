import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_customers.dart';
import 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final GetCustomersUseCase getCustomersUseCase;
  String _currentQuery = '';

  CustomersCubit({required this.getCustomersUseCase})
    : super(const CustomersInitial());

  Future<void> fetchCustomers({
    String? searchQuery,
    bool showLoading = true,
  }) async {
    _currentQuery = searchQuery ?? _currentQuery;

    if (showLoading) {
      emit(const CustomersLoading());
    }

    try {
      final customers = await getCustomersUseCase(searchQuery: _currentQuery);
      if (customers.isEmpty) {
        emit(CustomersEmpty(searchQuery: _currentQuery));
      } else {
        emit(CustomersLoaded(customers: customers, searchQuery: _currentQuery));
      }
    } on Failure catch (f) {
      emit(CustomersError(f.message));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  void searchCustomers(String query) {
    fetchCustomers(searchQuery: query, showLoading: false);
  }

  void refreshCustomers() {
    fetchCustomers(searchQuery: _currentQuery, showLoading: false);
  }
}
