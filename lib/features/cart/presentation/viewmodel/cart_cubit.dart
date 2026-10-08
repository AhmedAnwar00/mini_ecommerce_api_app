import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';

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

class CartCubit extends Cubit<CartState> {
  CartCubit({required this.repository, required this.sessionBloc})
    : super(const CartLoading()) {
    _subscription = sessionBloc.stream.listen((session) {
      _enqueue(() => _applySession(session));
    });
    _updates = repository.updates.listen((_) {
      _enqueue(_reload);
    });
  }

  final CartRepository repository;
  final SessionCubit sessionBloc;
  late final StreamSubscription<SessionState> _subscription;
  late final StreamSubscription<void> _updates;
  Future<void> _queue = Future<void>.value();

  Future<void> start() {
    return _enqueue(() => _applySession(sessionBloc.state));
  }

  Future<void> addProduct(Product product) {
    return _enqueue(() => _addProduct(product));
  }

  Future<void> increaseQuantity(String productId) {
    return _enqueue(() => _updateQuantity(productId, 1));
  }

  Future<void> decreaseQuantity(String productId) {
    return _enqueue(() => _updateQuantity(productId, -1));
  }

  Future<void> removeLine(String productId) {
    return _enqueue(() => _removeLine(productId));
  }

  Future<void> saveCoupon(String code) {
    return _enqueue(() => _saveCoupon(code));
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.catchError((Object _) {});
    return result;
  }

  Future<void> _applySession(SessionState session) async {
    if (session is SessionLoading) {
      _emit(const CartLoading());
      return;
    }
    if (session is SessionAuthenticated &&
        session.signedInNow &&
        session.user != null) {
      try {
        final cart = await repository.mergeGuestIntoUser(session.user!.id);
        _emit(_viewState(cart));
      } on Object {
        _emit(const CartFailure('The cart could not be saved.'));
      }
      return;
    }
    await _load(_ownerId(session));
  }

  Future<void> _addProduct(Product product) async {
    final cart = await _editableCart();
    if (cart == null) {
      _emit(const CartFailure('The cart could not be read.'));
      return;
    }
    final lines = [...cart.lines];
    final index = lines.indexWhere((line) => line.productId == product.id);
    if (index >= 0) {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    } else {
      lines.add(
        CartLine(
          productId: product.id,
          name: product.name,
          priceMinor: product.priceMinor,
          quantity: 1,
        ),
      );
    }
    await _persist(cart.copyWith(lines: lines));
  }

  Future<void> _updateQuantity(String productId, int delta) async {
    final cart = await _editableCart();
    if (cart == null) {
      _emit(const CartFailure('The cart could not be read.'));
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
    await _persist(cart.copyWith(lines: lines));
  }

  Future<void> _removeLine(String productId) async {
    final cart = await _editableCart();
    if (cart == null) {
      _emit(const CartFailure('The cart could not be read.'));
      return;
    }
    final lines = cart.lines
        .where((line) => line.productId != productId)
        .toList();
    await _persist(cart.copyWith(lines: lines));
  }

  Future<void> _saveCoupon(String code) async {
    final cart = await _editableCart();
    if (cart == null) {
      _emit(const CartFailure('The cart could not be read.'));
      return;
    }
    final trimmed = code.trim();
    await _persist(
      cart.copyWith(couponCode: trimmed, clearCoupon: trimmed.isEmpty),
    );
  }

  Future<void> _reload() {
    final session = sessionBloc.state;
    if (session is SessionLoading) {
      _emit(const CartLoading());
      return Future<void>.value();
    }
    return _load(_ownerId(session));
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

  Future<void> _load(String? userId) async {
    try {
      final cart = await repository.read(userId: userId);
      _emit(_viewState(cart));
    } on Object {
      _emit(const CartFailure('The cart could not be read.'));
    }
  }

  Future<void> _persist(Cart cart) async {
    try {
      await repository.write(cart, userId: _ownerId(sessionBloc.state));
      _emit(_viewState(cart));
    } on Object {
      _emit(const CartFailure('The cart could not be saved.'));
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

  void _emit(CartState next) {
    if (isClosed) return;
    emit(next);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _updates.cancel();
    return super.close();
  }
}
