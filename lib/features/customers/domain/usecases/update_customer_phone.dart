import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerPhoneUseCase {
  final CustomerRepository repository;

  const UpdateCustomerPhoneUseCase(this.repository);

  Future<Customer> call({
    required int customerId,
    required String newPhone,
  }) async {
    return await repository.updateCustomerPhone(
      customerId: customerId,
      newPhone: newPhone,
    );
  }
}
