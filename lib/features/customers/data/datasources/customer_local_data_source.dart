import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import '../models/pending_phone_update_model.dart';

abstract class CustomerLocalDataSource {
  Future<void> cacheCustomers(List<CustomerModel> customers);
  Future<List<CustomerModel>> getCachedCustomers();

  Future<void> savePendingPhoneUpdate(int customerId, String phone);
  Future<List<PendingCustomerPhoneUpdateModel>> getPendingPhoneUpdates();
  Future<void> removePendingPhoneUpdate(int customerId);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  static const String cachedCustomersKey = 'CACHED_CUSTOMERS';
  static const String pendingPhoneUpdatesKey = 'PENDING_PHONE_UPDATES';

  final SharedPreferences sharedPreferences;

  CustomerLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheCustomers(List<CustomerModel> customers) async {
    final jsonList = customers.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPreferences.setString(cachedCustomersKey, jsonString);
  }

  @override
  Future<List<CustomerModel>> getCachedCustomers() async {
    final jsonString = sharedPreferences.getString(cachedCustomersKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((j) => CustomerModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> savePendingPhoneUpdate(int customerId, String phone) async {
    final pending = await getPendingPhoneUpdates();
    // Remove duplicate for the same customer ID if present
    pending.removeWhere((p) => p.customerId == customerId);
    pending.add(
      PendingCustomerPhoneUpdateModel(customerId: customerId, phone: phone),
    );

    final jsonList = pending.map((p) => p.toJson()).toList();
    await sharedPreferences.setString(
      pendingPhoneUpdatesKey,
      jsonEncode(jsonList),
    );
  }

  @override
  Future<List<PendingCustomerPhoneUpdateModel>> getPendingPhoneUpdates() async {
    final jsonString = sharedPreferences.getString(pendingPhoneUpdatesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map(
          (j) => PendingCustomerPhoneUpdateModel.fromJson(
            j as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> removePendingPhoneUpdate(int customerId) async {
    final pending = await getPendingPhoneUpdates();
    pending.removeWhere((p) => p.customerId == customerId);
    final jsonList = pending.map((p) => p.toJson()).toList();
    await sharedPreferences.setString(
      pendingPhoneUpdatesKey,
      jsonEncode(jsonList),
    );
  }
}
