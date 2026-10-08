import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/checkout_draft.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/view/widgets/checkout_quote_summary.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/viewmodel/checkout_cubit.dart';

class CheckoutBody extends StatelessWidget {
  const CheckoutBody({
    super.key,
    required this.draft,
    required this.submitting,
    this.errorMessage,
  });

  final CheckoutDraft draft;
  final bool submitting;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        for (final line in draft.cart.lines) ...[
          Text('${line.name} × ${line.quantity}'),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        CheckoutQuoteSummary(quote: draft.quote),
        if (draft.couponMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            draft.couponMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: submitting || !draft.quote.canPlaceOrder
              ? null
              : () =>
                    context.read<CheckoutCubit>().submit(),
          child: submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Place order'),
        ),
      ],
    );
  }
}
