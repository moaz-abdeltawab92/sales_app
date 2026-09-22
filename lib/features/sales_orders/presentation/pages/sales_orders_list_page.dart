import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/skeleton_loader.dart';
import '../cubit/sales_orders_cubit.dart';
import '../cubit/sales_orders_state.dart';

import '../widgets/sales_order_card.dart';

class SalesOrdersListPage extends StatefulWidget {
  const SalesOrdersListPage({super.key});

  @override
  State<SalesOrdersListPage> createState() => _SalesOrdersListPageState();
}

class _SalesOrdersListPageState extends State<SalesOrdersListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SalesOrdersCubit>().fetchSalesOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SalesOrdersCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<SalesOrdersCubit, SalesOrdersState>(
        builder: (context, state) {
          if (state is SalesOrdersLoading) {
            return const CardSkeletonLoader(count: 4);
          } else if (state is SalesOrdersError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load sales orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<SalesOrdersCubit>().fetchSalesOrders(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is SalesOrdersEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Sales Orders available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<SalesOrdersCubit>().fetchSalesOrders(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is SalesOrdersLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SalesOrdersCubit>().refresh();
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return SalesOrderCard(
                    order: order,
                    onTap: () async {
                      final updated = await Navigator.pushNamed(
                        context,
                        AppRoutes.salesOrderDetails,
                        arguments: order,
                      );
                      if (updated == true && context.mounted) {
                        context.read<SalesOrdersCubit>().refresh();
                      }
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
