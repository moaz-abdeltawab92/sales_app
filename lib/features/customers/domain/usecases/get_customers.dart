import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;

  const GetCustomersUseCase(this.repository);

  Future<List<Customer>> call({String? searchQuery}) async {
    return await repository.getCustomers(searchQuery: searchQuery);
  }
}
