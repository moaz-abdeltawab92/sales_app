import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderStatusBadge extends StatelessWidget {
  final bool isDraft;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;

  const OrderStatusBadge({
    super.key,
    required this.isDraft,
    this.horizontalPadding = 10,
    this.verticalPadding = 4,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDraft ? AppColors.warning : AppColors.success;
    final text = isDraft ? 'Quotation' : 'Confirmed';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
