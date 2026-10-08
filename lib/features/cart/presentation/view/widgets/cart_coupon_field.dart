import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_cubit.dart';

class CartCouponField extends StatefulWidget {
  const CartCouponField({super.key, required this.couponCode});

  final String? couponCode;

  @override
  State<CartCouponField> createState() => _CartCouponFieldState();
}

class _CartCouponFieldState extends State<CartCouponField> {
  String _code = '';

  @override
  void initState() {
    super.initState();
    _code = widget.couponCode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: ValueKey(widget.couponCode),
          initialValue: widget.couponCode ?? '',
          decoration: const InputDecoration(
            labelText: 'Coupon code',
            helperText: 'Applied when you check out',
          ),
          onChanged: (value) => setState(() => _code = value),
          onFieldSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _save, child: const Text('Save coupon')),
      ],
    );
  }

  void _save() {
    context.read<CartCubit>().saveCoupon(_code);
  }
}
