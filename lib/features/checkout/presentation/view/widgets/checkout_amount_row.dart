import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/minor_units_format.dart';

class CheckoutAmountRow extends StatelessWidget {
  const CheckoutAmountRow({
    super.key,
    required this.label,
    required this.minor,
    this.emphasize = false,
  });

  final String label;
  final int minor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(formatMinorUnits(minor), style: style),
        ],
      ),
    );
  }
}
