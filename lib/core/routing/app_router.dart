import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_app/core/config/odoo_config.dart';
import 'package:sales_app/core/network/odoo_rpc_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/odoo_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';

import '../../features/customers/data/datasources/customer_local_data_source.dart';
import '../../features/customers/data/datasources/customer_remote_data_source.dart';
import '../../features/customers/data/datasources/odoo_customer_remote_data_source.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/entities/customer.dart';
import '../../features/customers/domain/usecases/get_customers.dart';
import '../../features/customers/domain/usecases/update_customer_phone.dart';
import '../../features/customers/presentation/cubit/customer_detail_cubit.dart';
import '../../features/customers/presentation/cubit/customers_cubit.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_list_page.dart';

import '../../features/sales_orders/data/datasources/odoo_sales_order_remote_data_source.dart';
import '../../features/sales_orders/data/datasources/sales_order_remote_data_source.dart';
import '../../features/sales_orders/data/repositories/sales_orders_repository_impl.dart';
import '../../features/sales_orders/domain/entities/sale_order.dart';
import '../../features/sales_orders/domain/usecases/confirm_sales_order.dart';
import '../../features/sales_orders/domain/usecases/get_sales_orders.dart';
import '../../features/sales_orders/presentation/cubit/sales_order_detail_cubit.dart';
import '../../features/sales_orders/presentation/cubit/sales_orders_cubit.dart';
import '../../features/sales_orders/presentation/pages/sales_order_detail_page.dart';
import '../../features/sales_orders/presentation/pages/sales_orders_list_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String customerList = '/customers';
  static const String customerDetails = '/customer-details';
  static const String salesOrders = '/sales-orders';
  static const String salesOrderDetails = '/sales-order-details';
}

class AppRouter {
  static OdooConfig? _odooConfig;
  static OdooRpcClient? _odooRpcClient;

  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthRepositoryImpl? _authRepository;

  static CustomerRemoteDataSource? _customerRemoteDataSource;
  static CustomerLocalDataSource? _customerLocalDataSource;
  static CustomerRepositoryImpl? _customerRepository;

  static SalesOrderRemoteDataSource? _salesOrderRemoteDataSource;
  static SalesOrdersRepositoryImpl? _salesOrdersRepository;

  static void init({
    required SharedPreferences prefs,
    required Connectivity connectivity,
    OdooConfig? config,
    bool useMock = false,
  }) {
    _odooConfig = config ?? OdooConfig.fromEnvironment();
    _odooRpcClient = OdooRpcClient(config: _odooConfig!);

    if (useMock) {
      _authRemoteDataSource = MockAuthRemoteDataSource();
      _customerRemoteDataSource = MockCustomerDataSource();
      _salesOrderRemoteDataSource = MockSalesOrderDataSource();
    } else {
      _authRemoteDataSource = OdooAuthRemoteDataSource(client: _odooRpcClient!);
      _customerRemoteDataSource = OdooCustomerRemoteDataSource(
        client: _odooRpcClient!,
      );
      _salesOrderRemoteDataSource = OdooSalesOrderRemoteDataSource(
        client: _odooRpcClient!,
      );
    }

    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource!,
    );

    _customerLocalDataSource = CustomerLocalDataSourceImpl(
      sharedPreferences: prefs,
    );
    _customerRepository = CustomerRepositoryImpl(
      remoteDataSource: _customerRemoteDataSource!,
      localDataSource: _customerLocalDataSource,
      connectivity: connectivity,
    );

    _salesOrdersRepository = SalesOrdersRepositoryImpl(
      remoteDataSource: _salesOrderRemoteDataSource!,
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Fallback lazy initialization if init was not called beforehand
    _odooConfig ??= OdooConfig.fromEnvironment();
    _odooRpcClient ??= OdooRpcClient(config: _odooConfig!);

    _authRemoteDataSource ??= OdooAuthRemoteDataSource(client: _odooRpcClient!);
    _authRepository ??= AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource!,
    );

    _customerRemoteDataSource ??= OdooCustomerRemoteDataSource(
      client: _odooRpcClient!,
    );
    _customerRepository ??= CustomerRepositoryImpl(
      remoteDataSource: _customerRemoteDataSource!,
      localDataSource: _customerLocalDataSource,
    );

    _salesOrderRemoteDataSource ??= OdooSalesOrderRemoteDataSource(
      client: _odooRpcClient!,
    );
    _salesOrdersRepository ??= SalesOrdersRepositoryImpl(
      remoteDataSource: _salesOrderRemoteDataSource!,
    );

    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                AuthCubit(loginUseCase: LoginUseCase(_authRepository!)),
            child: const LoginPage(),
          ),
        );

      case AppRoutes.customerList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => CustomersCubit(
              getCustomersUseCase: GetCustomersUseCase(_customerRepository!),
            ),
            child: const CustomerListPage(isInternalUser: true),
          ),
        );

      case AppRoutes.customerDetails:
        final customer = settings.arguments as Customer;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => CustomerDetailCubit(
              initialCustomer: customer,
              updateCustomerPhoneUseCase: UpdateCustomerPhoneUseCase(
                _customerRepository!,
              ),
            ),
            child: CustomerDetailPage(customer: customer),
          ),
        );

      case AppRoutes.salesOrders:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => SalesOrdersCubit(
              getSalesOrdersUseCase: GetSalesOrdersUseCase(
                _salesOrdersRepository!,
              ),
            ),
            child: const SalesOrdersListPage(),
          ),
        );

      case AppRoutes.salesOrderDetails:
        final order = settings.arguments as SaleOrder;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => SalesOrderDetailCubit(
              initialOrder: order,
              confirmSalesOrderUseCase: ConfirmSalesOrderUseCase(
                _salesOrdersRepository!,
              ),
            ),
            child: SalesOrderDetailPage(order: order),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
