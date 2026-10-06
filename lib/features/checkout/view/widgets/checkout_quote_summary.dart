import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/minor_units_format.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_quote.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/view/widgets/checkout_amount_row.dart';

class CheckoutQuoteSummary extends StatelessWidget {
  const CheckoutQuoteSummary({super.key, required this.quote});

  final CheckoutQuote quote;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckoutAmountRow(label: 'Merchandise', minor: quote.merchandise.minor),
        CheckoutAmountRow(label: 'Coupon', minor: -quote.couponDiscount.minor),
        CheckoutAmountRow(
          label: 'Membership',
          minor: -quote.membershipDiscount.minor,
        ),
        CheckoutAmountRow(label: 'VAT', minor: quote.vat.minor),
        CheckoutAmountRow(label: 'Shipping', minor: quote.shipping.minor),
        const Divider(),
        CheckoutAmountRow(
          label: 'Total',
          minor: quote.total.minor,
          emphasize: true,
        ),
        if (!quote.meetsMinimum) ...[
          const SizedBox(height: 12),
          Text(
            'Minimum order is ${formatMinorUnits(quote.minimumOrder.minor)}.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
