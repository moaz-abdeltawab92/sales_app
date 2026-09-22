import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/skeleton_loader.dart';
import '../../../../core/widgets/animated_search_bar.dart';
import '../cubit/customers_cubit.dart';
import '../cubit/customers_state.dart';

import '../widgets/customer_card.dart';

class CustomerListPage extends StatefulWidget {
  final bool isInternalUser;

  const CustomerListPage({super.key, this.isInternalUser = true});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomersCubit>().fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          if (widget.isInternalUser)
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              tooltip: 'Sales Orders',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.salesOrders);
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CustomersCubit>().refreshCustomers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSearchBar(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<CustomersCubit>().searchCustomers(value),
              onClear: () => context.read<CustomersCubit>().searchCustomers(''),
              searchPhrases: const ['customer by name...'],
            ),
          ),

          // Customer List Content
          Expanded(
            child: BlocBuilder<CustomersCubit, CustomersState>(
              builder: (context, state) {
                if (state is CustomersLoading) {
                  return const CardSkeletonLoader(count: 5);
                } else if (state is CustomersError) {
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
                            'Unable to load customers',
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
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.read<CustomersCubit>().fetchCustomers(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is CustomersEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 56,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No customers available'
                                : 'No customers matching "${state.searchQuery}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (state.searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                context.read<CustomersCubit>().searchCustomers(
                                  '',
                                );
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Search'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                } else if (state is CustomersLoaded) {
                  final isOffline = state.customers.any(
                    (c) => c.isOfflineCached,
                  );

                  return Column(
                    children: [
                      // Offline indicator bar
                      if (isOffline)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          color: AppColors.warning.withValues(alpha: 0.15),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.wifi_off,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Offline — showing cached data',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),

                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<CustomersCubit>().refreshCustomers();
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            itemCount: state.customers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final customer = state.customers[index];
                              return CustomerCard(
                                customer: customer,
                                onTap: () async {
                                  final updated = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.customerDetails,
                                    arguments: customer,
                                  );
                                  if (updated == true && context.mounted) {
                                    context
                                        .read<CustomersCubit>()
                                        .refreshCustomers();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
