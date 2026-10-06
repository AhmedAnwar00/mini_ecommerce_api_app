import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/checkout_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/coupon_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/calculate_checkout.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_line.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_policy.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/coupon.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/model/checkout_draft.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/model/order.dart';

sealed class CheckoutEvent {
  const CheckoutEvent();
}

class CheckoutRequested extends CheckoutEvent {
  const CheckoutRequested();
}

class CheckoutSubmitted extends CheckoutEvent {
  const CheckoutSubmitted();
}

sealed class CheckoutState {
  const CheckoutState();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.message);

  final String message;
}

class CheckoutEmptyCart extends CheckoutState {
  const CheckoutEmptyCart();
}

class CheckoutReady extends CheckoutState {
  const CheckoutReady(this.draft);

  final CheckoutDraft draft;
}

class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting(this.draft);

  final CheckoutDraft draft;
}

class CheckoutSubmitFailure extends CheckoutState {
  const CheckoutSubmitFailure({required this.draft, required this.message});

  final CheckoutDraft draft;
  final String message;
}

class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess({required this.order, required this.quotedTotalMinor});

  final Order order;
  final int quotedTotalMinor;
}

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required this.cartRepository,
    required this.couponApi,
    required this.checkoutApi,
    required this.sessionBloc,
    required this.calculateCheckout,
    required this.policy,
  }) : super(const CheckoutLoading()) {
    on<CheckoutRequested>(_onRequested);
    on<CheckoutSubmitted>(_onSubmitted);
  }

  final CartRepository cartRepository;
  final CouponApi couponApi;
  final CheckoutApi checkoutApi;
  final SessionBloc sessionBloc;
  final CalculateCheckout calculateCheckout;
  final CheckoutPolicy policy;

  Future<void> _onRequested(
    CheckoutRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());
    try {
      final cart = await cartRepository.read(userId: _ownerId());
      if (cart.lines.isEmpty) {
        emit(const CheckoutEmptyCart());
        return;
      }
      final code = cart.couponCode?.trim();
      Coupon? coupon;
      String? couponMessage;
      String? appliedCode;
      if (code != null && code.isNotEmpty) {
        try {
          coupon = await couponApi.validate(code);
          appliedCode = code;
        } on AppFailure catch (failure) {
          couponMessage = failure.message;
        }
      }
      final quote = calculateCheckout(
        lines: [
          for (final line in cart.lines)
            CheckoutLine(
              price: Money(line.priceMinor),
              quantity: line.quantity,
            ),
        ],
        policy: policy,
        coupon: coupon,
        membershipBasisPoints: _membershipBasisPoints(),
      );
      emit(
        CheckoutReady(
          CheckoutDraft(
            cart: cart,
            quote: quote,
            appliedCouponCode: appliedCode,
            couponMessage: couponMessage,
          ),
        ),
      );
    } on AppFailure catch (failure) {
      emit(CheckoutFailure(failure.message));
    } on ArgumentError {
      emit(const CheckoutFailure('The cart has invalid items.'));
    }
  }

  Future<void> _onSubmitted(
    CheckoutSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    final draft = switch (state) {
      CheckoutReady(:final draft) => draft,
      CheckoutSubmitFailure(:final draft) => draft,
      _ => null,
    };
    if (draft == null || !draft.quote.canPlaceOrder) return;
    emit(CheckoutSubmitting(draft));
    try {
      final order = await checkoutApi.placeOrder(
        lines: draft.cart.lines,
        couponCode: draft.appliedCouponCode,
      );
      emit(
        CheckoutSuccess(
          order: order,
          quotedTotalMinor: draft.quote.total.minor,
        ),
      );
    } on AppFailure catch (failure) {
      emit(CheckoutSubmitFailure(draft: draft, message: failure.message));
    }
  }

  String? _ownerId() {
    final session = sessionBloc.state;
    if (session is SessionAuthenticated) return session.user?.id;
    return null;
  }

  int _membershipBasisPoints() {
    final session = sessionBloc.state;
    if (session is SessionAuthenticated) {
      return session.user?.membershipBasisPoints ?? 0;
    }
    return 0;
  }
}
