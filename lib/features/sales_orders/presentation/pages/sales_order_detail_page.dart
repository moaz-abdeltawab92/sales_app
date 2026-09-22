import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/confetti_overlay.dart';
import '../../domain/entities/sale_order.dart';
import '../cubit/sales_order_detail_cubit.dart';

import '../widgets/order_status_badge.dart';

class SalesOrderDetailPage extends StatefulWidget {
  final SaleOrder order;

  const SalesOrderDetailPage({
    super.key,
    required this.order,
  });

  @override
  State<SalesOrderDetailPage> createState() => _SalesOrderDetailPageState();
}

class _SalesOrderDetailPageState extends State<SalesOrderDetailPage> {
  final GlobalKey<ConfettiOverlayState> _confettiKey =
      GlobalKey<ConfettiOverlayState>();
  final GlobalKey<SlideActionState> _slideKey =
      GlobalKey<SlideActionState>();


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesOrderDetailCubit, SalesOrderDetailState>(
      listener: (context, state) {
        if (state is SalesOrderDetailSuccess) {
          _confettiKey.currentState?.play();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Sales Order confirmed successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is SalesOrderDetailFailure) {
          _slideKey.currentState?.reset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final currentOrder = state.order;
        final formattedDate = DateFormatter.format(currentOrder.orderDate);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pop(context, state is SalesOrderDetailSuccess);
          },
          child: ConfettiOverlay(
            key: _confettiKey,
            child: Scaffold(
            appBar: AppBar(
              title: Text(currentOrder.orderNumber),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    Navigator.pop(context, state is SalesOrderDetailSuccess),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header Overview Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentOrder.orderNumber,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              OrderStatusBadge(
                                isDraft: currentOrder.isDraft,
                                horizontalPadding: 12,
                                verticalPadding: 6,
                                fontSize: 13,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  currentOrder.customerName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Text(
                                'Date: $formattedDate',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Lines / Products Title
                  const Text(
                    'Order Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Products List
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentOrder.lines.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final line = currentOrder.lines[index];
                        return ListTile(
                          title: Text(
                            line.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${line.quantity.toStringAsFixed(0)} x \$${line.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: Text(
                            '\$${line.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Total Card
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${currentOrder.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Confirm Order Slide Action Button (Only visible if order is in Draft / Quotation state)
                  if (currentOrder.isDraft)
                    SlideAction(
                      key: _slideKey,
                      text: 'Slide to Confirm Order',
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      outerColor: AppColors.success,
                      innerColor: Colors.white,
                      sliderButtonIcon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.success,
                      ),
                      submittedIcon: const Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      onSubmit: () async {
                        context.read<SalesOrderDetailCubit>().confirmOrder();
                        return null;
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}
