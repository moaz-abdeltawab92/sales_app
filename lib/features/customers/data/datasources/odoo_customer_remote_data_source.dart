import '../../../../core/errors/failures.dart';
import '../../../../core/network/odoo_rpc_client.dart';
import '../models/customer_model.dart';
import 'customer_remote_data_source.dart';

/// Odoo implementation of [CustomerRemoteDataSource] using `res.partner`.
class OdooCustomerRemoteDataSource implements CustomerRemoteDataSource {
  final OdooRpcClient client;

  OdooCustomerRemoteDataSource({required this.client});

  @override
  Future<List<CustomerModel>> getCustomers({String? searchQuery}) async {
    try {
      final domain = <dynamic>[
        ['customer_rank', '>', 0],
      ];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        domain.add(['name', 'ilike', searchQuery.trim()]);
      }

      final response = await client.executeKw(
        model: 'res.partner',
        method: 'search_read',
        args: [domain],
        kwargs: {
          'fields': [
            'id',
            'name',
            'phone',
            'email',
            'city',
            'street',
            'customer_rank',
          ],
          'limit': 100,
        },
      );

      if (response is! List) {
        throw const ServerFailure('Invalid customer response from Odoo');
      }

      final customers = response.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _mapToCustomerModel(map);
      }).toList();

      final filteredCustomers = customers
          .where((c) => c.customerRank > 0)
          .toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        return filteredCustomers
            .where((c) => c.name.toLowerCase().contains(query))
            .toList();
      }

      return filteredCustomers;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        'Failed to fetch customers from Odoo: ${e.toString()}',
      );
    }
  }

  @override
  Future<CustomerModel> updateCustomerPhone({
    required int customerId,
    required String newPhone,
  }) async {
    final cleanPhone = newPhone.trim();

    if (cleanPhone.isEmpty) {
      throw const ServerFailure('Phone number cannot be empty');
    }

    try {
      final writeResult = await client.executeKw(
        model: 'res.partner',
        method: 'write',
        args: [
          [customerId],
          {'phone': cleanPhone},
        ],
      );

      if (writeResult != true) {
        throw const ServerFailure('Failed to update phone number on Odoo');
      }

      // Re-read updated customer record from Odoo
      final updatedRecords = await client.executeKw(
        model: 'res.partner',
        method: 'search_read',
        args: [
          [
            ['id', '=', customerId],
          ],
        ],
        kwargs: {
          'fields': [
            'id',
            'name',
            'phone',
            'email',
            'city',
            'street',
            'customer_rank',
          ],
          'limit': 1,
        },
      );

      if (updatedRecords is List && updatedRecords.isNotEmpty) {
        final map = Map<String, dynamic>.from(updatedRecords.first as Map);
        return _mapToCustomerModel(map);
      }

      // Fallback if read returns empty
      return CustomerModel(
        id: customerId,
        name: 'Customer #$customerId',
        phone: cleanPhone,
        email: '',
        city: '',
        address: '',
        customerRank: 1,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Failed to update phone number: ${e.toString()}');
    }
  }

  CustomerModel _mapToCustomerModel(Map<String, dynamic> json) {
    return CustomerModel(
      id: OdooRpcClient.parseInt(json['id']),
      name: OdooRpcClient.parseString(json['name']),
      phone: OdooRpcClient.parseString(json['phone']),
      email: OdooRpcClient.parseString(json['email']),
      city: OdooRpcClient.parseString(json['city']),
      address: OdooRpcClient.parseString(json['street']),
      customerRank: OdooRpcClient.parseInt(json['customer_rank'], 1),
    );
  }
}
