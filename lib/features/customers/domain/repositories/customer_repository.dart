import '../entities/customer.dart';

/// Abstract repository defining Customer operations.
abstract class CustomerRepository {
  /// Fetches customers filtered by customer_rank > 0 and optional search query.
  Future<List<Customer>> getCustomers({String? searchQuery});

  /// Updates the phone number for a customer by [customerId].
  Future<Customer> updateCustomerPhone({
    required int customerId,
    required String newPhone,
  });
}
