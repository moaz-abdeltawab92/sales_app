import '../../../../core/errors/failures.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({String? searchQuery});

  Future<CustomerModel> updateCustomerPhone({
    required int customerId,
    required String newPhone,
  });
}

/// Isolated Mock Data Source for Customers (res.partner model).
/// Strictly filters where customer_rank > 0 as required by Odoo domain specifications.
class MockCustomerDataSource implements CustomerRemoteDataSource {
  final List<CustomerModel> _mockCustomers = [
    const CustomerModel(
      id: 101,
      name: 'Acme Corporation',
      phone: '+1 (555) 019-2834',
      email: 'contact@acme.corp',
      city: 'Cairo',
      address: '15 El-Tahrir Square, Downtown',
      customerRank: 1,
    ),
    const CustomerModel(
      id: 102,
      name: 'Global Logistics Ltd',
      phone: '+1 (555) 048-9102',
      email: 'info@globallogistics.com',
      city: 'Alexandria',
      address: '42 Corniche Road, Ramleh',
      customerRank: 2,
    ),
    const CustomerModel(
      id: 103,
      name: 'Nile Tech Solutions',
      phone: '+20 100 123 4567',
      email: 'sales@niletech.eg',
      city: 'Cairo',
      address: '88 9th Street, Maadi',
      customerRank: 1,
    ),
    const CustomerModel(
      id: 104,
      name: 'Sunrise Trading Co',
      phone: '+20 122 987 6543',
      email: 'orders@sunrisetrading.com',
      city: 'Giza',
      address: '12 Pyramids Avenue, Haram',
      customerRank: 3,
    ),
    const CustomerModel(
      id: 105,
      name: 'Delta Pharma Industries',
      phone: '+20 40 331 8890',
      email: 'support@deltapharma.eg',
      city: 'Tanta',
      address: '5 El-Gaish Street, Center',
      customerRank: 1,
    ),
  ];

  @override
  Future<List<CustomerModel>> getCustomers({String? searchQuery}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Strictly enforce requirement: customer_rank > 0
    Iterable<CustomerModel> filtered = _mockCustomers.where((c) => c.customerRank > 0);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      filtered = filtered.where(
        (c) => c.name.toLowerCase().contains(query),
      );
    }

    return filtered.toList();
  }

  @override
  Future<CustomerModel> updateCustomerPhone({
    required int customerId,
    required String newPhone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (newPhone.trim().isEmpty) {
      throw const ServerFailure('Phone number cannot be empty');
    }

    final index = _mockCustomers.indexWhere((c) => c.id == customerId);
    if (index == -1) {
      throw const ServerFailure('Customer not found');
    }

    final updated = CustomerModel(
      id: _mockCustomers[index].id,
      name: _mockCustomers[index].name,
      phone: newPhone.trim(),
      email: _mockCustomers[index].email,
      city: _mockCustomers[index].city,
      address: _mockCustomers[index].address,
      customerRank: _mockCustomers[index].customerRank,
    );

    _mockCustomers[index] = updated;
    return updated;
  }
}
