import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/model/cart.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/model/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/products/model/product.dart';

sealed class CartEvent {
  const CartEvent();
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartSessionChanged extends CartEvent {
  const CartSessionChanged(this.session);

  final SessionState session;
}

class CartProductAdded extends CartEvent {
  const CartProductAdded(this.product);

  final Product product;
}

class CartQuantityIncreased extends CartEvent {
  const CartQuantityIncreased(this.productId);

  final String productId;
}

class CartQuantityDecreased extends CartEvent {
  const CartQuantityDecreased(this.productId);

  final String productId;
}

class CartLineRemoved extends CartEvent {
  const CartLineRemoved(this.productId);

  final String productId;
}

class CartCouponSaved extends CartEvent {
  const CartCouponSaved(this.code);

  final String code;
}

class CartCheckedOut extends CartEvent {
  const CartCheckedOut();
}

sealed class CartState {
  const CartState();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartFailure extends CartState {
  const CartFailure(this.message);

  final String message;
}

class CartEmpty extends CartState {
  const CartEmpty(this.cart);

  final Cart cart;
}

class CartReady extends CartState {
  const CartReady(this.cart);

  final Cart cart;
}

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required this.repository, required this.sessionBloc})
    : super(const CartLoading()) {
    on<CartStarted>(_onStarted);
    on<CartSessionChanged>(_onSessionChanged);
    on<CartProductAdded>(_onProductAdded);
    on<CartQuantityIncreased>(_onQuantityIncreased);
    on<CartQuantityDecreased>(_onQuantityDecreased);
    on<CartLineRemoved>(_onLineRemoved);
    on<CartCouponSaved>(_onCouponSaved);
    on<CartCheckedOut>(_onCheckedOut);
    _subscription = sessionBloc.stream.listen((session) {
      add(CartSessionChanged(session));
    });
  }

  final CartRepository repository;
  final SessionBloc sessionBloc;
  late final StreamSubscription<SessionState> _subscription;

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) {
    return _applySession(sessionBloc.state, emit);
  }

  Future<void> _onSessionChanged(
    CartSessionChanged event,
    Emitter<CartState> emit,
  ) {
    return _applySession(event.session, emit);
  }

  Future<void> _applySession(
    SessionState session,
    Emitter<CartState> emit,
  ) async {
    if (session is SessionLoading) {
      emit(const CartLoading());
      return;
    }
    if (session is SessionAuthenticated &&
        session.signedInNow &&
        session.user != null) {
      try {
        final cart = await repository.mergeGuestIntoUser(session.user!.id);
        emit(_viewState(cart));
      } on Object {
        emit(const CartFailure('The cart could not be saved.'));
      }
      return;
    }
    await _load(_ownerId(session), emit);
  }

  Future<void> _onProductAdded(
    CartProductAdded event,
    Emitter<CartState> emit,
  ) async {
    final cart = await _editableCart();
    if (cart == null) {
      emit(const CartFailure('The cart could not be read.'));
      return;
    }
    final lines = [...cart.lines];
    final index = lines.indexWhere(
      (line) => line.productId == event.product.id,
    );
    if (index >= 0) {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    } else {
      lines.add(
        CartLine(
          productId: event.product.id,
          name: event.product.name,
          priceMinor: event.product.priceMinor,
          quantity: 1,
        ),
      );
    }
    await _persist(cart.copyWith(lines: lines), emit);
  }

  Future<void> _onQuantityIncreased(
    CartQuantityIncreased event,
    Emitter<CartState> emit,
  ) async {
    await _updateQuantity(event.productId, 1, emit);
  }

  Future<void> _onQuantityDecreased(
    CartQuantityDecreased event,
    Emitter<CartState> emit,
  ) async {
    await _updateQuantity(event.productId, -1, emit);
  }

  Future<void> _updateQuantity(
    String productId,
    int delta,
    Emitter<CartState> emit,
  ) async {
    final cart = await _editableCart();
    if (cart == null) {
      emit(const CartFailure('The cart could not be read.'));
      return;
    }
    final lines = [...cart.lines];
    final index = lines.indexWhere((line) => line.productId == productId);
    if (index < 0) return;
    final next = lines[index].quantity + delta;
    if (next <= 0) {
      lines.removeAt(index);
    } else {
      lines[index] = lines[index].copyWith(quantity: next);
    }
    await _persist(cart.copyWith(lines: lines), emit);
  }

  Future<void> _onLineRemoved(
    CartLineRemoved event,
    Emitter<CartState> emit,
  ) async {
    final cart = await _editableCart();
    if (cart == null) {
      emit(const CartFailure('The cart could not be read.'));
      return;
    }
    final lines = cart.lines
        .where((line) => line.productId != event.productId)
        .toList();
    await _persist(cart.copyWith(lines: lines), emit);
  }

  Future<void> _onCouponSaved(
    CartCouponSaved event,
    Emitter<CartState> emit,
  ) async {
    final cart = await _editableCart();
    if (cart == null) {
      emit(const CartFailure('The cart could not be read.'));
      return;
    }
    final code = event.code.trim();
    await _persist(
      cart.copyWith(couponCode: code, clearCoupon: code.isEmpty),
      emit,
    );
  }

  Future<void> _onCheckedOut(
    CartCheckedOut event,
    Emitter<CartState> emit,
  ) async {
    await _persist(Cart.empty, emit);
  }

  Future<Cart?> _editableCart() async {
    final current = state;
    if (current is CartReady) return current.cart;
    if (current is CartEmpty) return current.cart;
    try {
      return await repository.read(userId: _ownerId(sessionBloc.state));
    } on Object {
      return null;
    }
  }

  Future<void> _load(String? userId, Emitter<CartState> emit) async {
    try {
      final cart = await repository.read(userId: userId);
      emit(_viewState(cart));
    } on Object {
      emit(const CartFailure('The cart could not be read.'));
    }
  }

  Future<void> _persist(Cart cart, Emitter<CartState> emit) async {
    try {
      await repository.write(cart, userId: _ownerId(sessionBloc.state));
      emit(_viewState(cart));
    } on Object {
      emit(const CartFailure('The cart could not be saved.'));
    }
  }

  CartState _viewState(Cart cart) {
    if (cart.lines.isEmpty) return CartEmpty(cart);
    return CartReady(cart);
  }

  String? _ownerId(SessionState session) {
    if (session is SessionAuthenticated) return session.user?.id;
    return null;
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
