import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final CustomerLocalDataSource? localDataSource;
  final Connectivity? connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    this.connectivity,
  }) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    if (connectivity != null) {
      _connectivitySubscription =
          connectivity!.onConnectivityChanged.listen((results) {
        final isOnline = results.any((r) => r != ConnectivityResult.none);
        if (isOnline) {
          syncPendingUpdates();
        }
      });
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<bool> _isNetworkConnected() async {
    if (connectivity == null) return true;
    final results = await connectivity!.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<List<Customer>> getCustomers({String? searchQuery}) async {
    final isOnline = await _isNetworkConnected();

    if (isOnline) {
      try {
        // Try remote fetch
        final remoteModels =
            await remoteDataSource.getCustomers(searchQuery: searchQuery);

        // Cache remotely fetched customers if local data source is available
        if (localDataSource != null) {
          await localDataSource!.cacheCustomers(remoteModels);

          // Check if there are pending local phone updates and apply them visually
          final pending = await localDataSource!.getPendingPhoneUpdates();
          if (pending.isNotEmpty) {
            final pendingMap = {for (var p in pending) p.customerId: p.phone};
            final merged = remoteModels.map((c) {
              if (pendingMap.containsKey(c.id)) {
                return CustomerModel(
                  id: c.id,
                  name: c.name,
                  phone: pendingMap[c.id]!,
                  email: c.email,
                  city: c.city,
                  address: c.address,
                  customerRank: c.customerRank,
                  isOfflineCached: false,
                  hasPendingUpdate: true,
                );
              }
              return c;
            }).toList();
            return merged;
          }
        }
        return remoteModels;
      } catch (e) {
        // Fallback to local cache if available
        if (localDataSource != null) {
          return await _getCachedCustomers(searchQuery: searchQuery);
        }
        rethrow;
      }
    } else {
      // Device is offline: load cached customers
      if (localDataSource != null) {
        return await _getCachedCustomers(searchQuery: searchQuery);
      }
      throw const NetworkFailure(
          'Device is offline and no cached data is available');
    }
  }

  Future<List<Customer>> _getCachedCustomers({String? searchQuery}) async {
    if (localDataSource == null) return [];
    final cachedModels = await localDataSource!.getCachedCustomers();
    final pending = await localDataSource!.getPendingPhoneUpdates();
    final pendingMap = {for (var p in pending) p.customerId: p.phone};

    Iterable<CustomerModel> list = cachedModels;

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q));
    }

    return list.map((c) {
      final hasPending = pendingMap.containsKey(c.id);
      return CustomerModel(
        id: c.id,
        name: c.name,
        phone: hasPending ? pendingMap[c.id]! : c.phone,
        email: c.email,
        city: c.city,
        address: c.address,
        customerRank: c.customerRank,
        isOfflineCached: true,
        hasPendingUpdate: hasPending,
      );
    }).toList();
  }

  @override
  Future<Customer> updateCustomerPhone({
    required int customerId,
    required String newPhone,
  }) async {
    final isOnline = await _isNetworkConnected();

    if (isOnline) {
      try {
        final updated = await remoteDataSource.updateCustomerPhone(
          customerId: customerId,
          newPhone: newPhone,
        );

        // Update local cache and clear pending item if remote succeeds
        if (localDataSource != null) {
          await localDataSource!.removePendingPhoneUpdate(customerId);
          final cached = await localDataSource!.getCachedCustomers();
          final index = cached.indexWhere((c) => c.id == customerId);
          if (index != -1) {
            cached[index] = CustomerModel.fromEntity(updated);
            await localDataSource!.cacheCustomers(cached);
          }
        }
        return updated;
      } catch (e) {
        if (localDataSource != null) {
          return await _saveOfflinePhoneUpdate(customerId, newPhone);
        }
        rethrow;
      }
    } else {
      // Device is offline: save update locally as pending sync
      if (localDataSource != null) {
        return await _saveOfflinePhoneUpdate(customerId, newPhone);
      }
      throw const NetworkFailure('Cannot update phone while offline');
    }
  }

  Future<Customer> _saveOfflinePhoneUpdate(
      int customerId, String newPhone) async {
    await localDataSource!.savePendingPhoneUpdate(customerId, newPhone);
    final cached = await localDataSource!.getCachedCustomers();
    final index = cached.indexWhere((c) => c.id == customerId);

    CustomerModel updatedModel;
    if (index != -1) {
      final existing = cached[index];
      updatedModel = CustomerModel(
        id: existing.id,
        name: existing.name,
        phone: newPhone,
        email: existing.email,
        city: existing.city,
        address: existing.address,
        customerRank: existing.customerRank,
        isOfflineCached: true,
        hasPendingUpdate: true,
      );
      cached[index] = updatedModel;
      await localDataSource!.cacheCustomers(cached);
    } else {
      updatedModel = CustomerModel(
        id: customerId,
        name: 'Customer #$customerId',
        phone: newPhone,
        email: '',
        city: '',
        address: '',
        customerRank: 1,
        isOfflineCached: true,
        hasPendingUpdate: true,
      );
    }
    return updatedModel;
  }

  Future<void> syncPendingUpdates() async {
    if (localDataSource == null) return;

    final pendingList = await localDataSource!.getPendingPhoneUpdates();
    if (pendingList.isEmpty) return;

    for (final pending in pendingList) {
      try {
        final updated = await remoteDataSource.updateCustomerPhone(
          customerId: pending.customerId,
          newPhone: pending.phone,
        );
        await localDataSource!.removePendingPhoneUpdate(pending.customerId);

        final cached = await localDataSource!.getCachedCustomers();
        final idx = cached.indexWhere((c) => c.id == pending.customerId);
        if (idx != -1) {
          cached[idx] = CustomerModel.fromEntity(updated);
          await localDataSource!.cacheCustomers(cached);
        }
      } catch (_) {
        // Keep in pending list if retry fails
      }
    }
  }
}
