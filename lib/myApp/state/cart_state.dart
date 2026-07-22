import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../../myWeb2/state/app_state.dart' as webState;
import '../../Backend/Cart/get_cart.dart';
import '../../Backend/Cart/add_cart_item.dart';
import '../../Backend/Cart/update_cart_item.dart';
import '../../Backend/Cart/remove_cart_item.dart';
import '../../Backend/Cart/clear_cart.dart';
import '../../Models/Cart/cart_model.dart';

class CartState extends ChangeNotifier {
  CartState() {
    webState.AppState.instance.addListener(_onAuthChange);
    if (webState.AppState.instance.user != null) {
      _cartLoaded = true;
      loadFromBackend();
    }
  }

  final List<CartItem> _items = [];
  bool _cartLoaded = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalQty => _items.fold(0, (sum, i) => sum + i.qty);
  bool get isEmpty => _items.isEmpty;

  bool get _isLoggedIn => webState.AppState.instance.user != null;

  void _onAuthChange() {
    final loggedIn = webState.AppState.instance.user != null;
    if (loggedIn && !_cartLoaded) {
      _cartLoaded = true;
      loadFromBackend();
    } else if (!loggedIn && _cartLoaded) {
      _cartLoaded = false;
      _items.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    webState.AppState.instance.removeListener(_onAuthChange);
    super.dispose();
  }

  int _indexOf(String productId, Plan plan) =>
      _items.indexWhere((i) => i.productId == productId && i.plan == plan);

  Future<void> addItem(String productId, {Plan plan = Plan.rent, int qty = 1}) async {
    print('[CartState.addItem] productId=$productId plan=${plan.id} qty=$qty loggedIn=$_isLoggedIn');
    final idx = _indexOf(productId, plan);
    final existingBackendId = idx >= 0 ? _items[idx].backendItemId : null;
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(qty: _items[idx].qty + qty);
    } else {
      _items.add(CartItem(productId: productId, plan: plan, qty: qty));
    }
    notifyListeners();

    if (_isLoggedIn) {
      final id = int.tryParse(productId);
      if (id != null) {
        final newQty = _items.where((i) => i.productId == productId && i.plan == plan).firstOrNull?.qty ?? qty;
        if (existingBackendId != null) {
          print('[CartState.addItem] updating existing backendItemId=$existingBackendId newQty=$newQty');
          final res = await updateCartItem(existingBackendId, quantity: newQty);
          print('[CartState.addItem] updateCartItem success=${res.success} message=${res.message} items=${res.data?.items.length}');
          if (res.success && res.data != null) { _applyBackendCart(res.data!); notifyListeners(); }
        } else {
          print('[CartState.addItem] calling addCartItem productId=$id term=${plan.id} qty=$qty');
          final res = await addCartItem(productId: id, term: plan.id, quantity: qty);
          print('[CartState.addItem] addCartItem success=${res.success} message=${res.message} items=${res.data?.items.length}');
          if (res.success && res.data != null) { _applyBackendCart(res.data!); notifyListeners(); }
        }
      } else {
        print('[CartState.addItem] ERROR: productId="$productId" is not a valid int, skipping API call');
      }
    } else {
      print('[CartState.addItem] not logged in, added to local cart only');
    }
  }

  Future<void> setPlan(String productId, Plan oldPlan, Plan newPlan) async {
    print('[CartState.setPlan] productId=$productId ${oldPlan.id} -> ${newPlan.id}');
    final idx = _indexOf(productId, oldPlan);
    if (idx < 0) return;
    final backendId = _items[idx].backendItemId;
    final currentQty = _items[idx].qty;

    final existing = _indexOf(productId, newPlan);
    if (existing >= 0 && existing != idx) {
      _items[existing] = _items[existing].copyWith(qty: _items[existing].qty + currentQty);
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(plan: newPlan);
    }
    notifyListeners();

    if (_isLoggedIn) {
      if (backendId != null) {
        print('[CartState.setPlan] removing old backendItemId=$backendId');
        await removeCartItem(backendId);
      }
      final id = int.tryParse(productId);
      if (id != null) {
        print('[CartState.setPlan] adding new term=${newPlan.id} qty=$currentQty');
        final res = await addCartItem(productId: id, term: newPlan.id, quantity: currentQty);
        print('[CartState.setPlan] success=${res.success} message=${res.message} items=${res.data?.items.length}');
        if (res.success && res.data != null) { _applyBackendCart(res.data!); notifyListeners(); }
      }
    }
  }

  Future<void> setQty(String productId, Plan plan, int qty) async {
    print('[CartState.setQty] productId=$productId plan=${plan.id} qty=$qty');
    final idx = _indexOf(productId, plan);
    if (idx < 0) return;
    if (qty <= 0) {
      await removeItem(productId, plan);
      return;
    }
    final backendId = _items[idx].backendItemId;
    _items[idx] = _items[idx].copyWith(qty: qty);
    notifyListeners();

    if (_isLoggedIn && backendId != null) {
      print('[CartState.setQty] calling updateCartItem backendItemId=$backendId qty=$qty');
      final res = await updateCartItem(backendId, quantity: qty);
      print('[CartState.setQty] success=${res.success} message=${res.message} items=${res.data?.items.length}');
      if (res.success && res.data != null) { _applyBackendCart(res.data!); notifyListeners(); }
    } else if (_isLoggedIn && backendId == null) {
      print('[CartState.setQty] WARNING: no backendItemId, cannot sync qty to backend');
    }
  }

  Future<void> removeItem(String productId, Plan plan) async {
    print('[CartState.removeItem] productId=$productId plan=${plan.id}');
    final idx = _indexOf(productId, plan);
    final backendId = idx >= 0 ? _items[idx].backendItemId : null;
    _items.removeWhere((i) => i.productId == productId && i.plan == plan);
    notifyListeners();

    if (_isLoggedIn && backendId != null) {
      print('[CartState.removeItem] calling removeCartItem backendItemId=$backendId');
      final res = await removeCartItem(backendId);
      print('[CartState.removeItem] success=${res.success} message=${res.message} items=${res.data?.items.length}');
      if (res.success && res.data != null) { _applyBackendCart(res.data!); notifyListeners(); }
    } else if (_isLoggedIn && backendId == null) {
      print('[CartState.removeItem] WARNING: no backendItemId, removed locally only');
    }
  }

  Future<void> clearBackend() async {
    print('[CartState.clearBackend] loggedIn=$_isLoggedIn');
    if (_isLoggedIn) {
      final res = await clearCart();
      print('[CartState.clearBackend] success=${res.success} message=${res.message}');
    }
    _items.clear();
    notifyListeners();
  }

  Future<void> loadFromBackend() async {
    print('[CartState.loadFromBackend] fetching cart...');
    final res = await getCart();
    print('[CartState.loadFromBackend] success=${res.success} message=${res.message} items=${res.data?.items.length}');
    if (!res.success || res.data == null) return;
    _applyBackendCart(res.data!);
    notifyListeners();
    print('[CartState.loadFromBackend] applied ${_items.length} items: ${_items.map((i) => 'id=${i.productId} plan=${i.plan.id} qty=${i.qty} backendId=${i.backendItemId}').join(', ')}');
  }

  void _applyBackendCart(CartModel backendCart) {
    print('[CartState._applyBackendCart] ${backendCart.items.length} items from backend');
    _items.clear();
    for (final item in backendCart.items) {
      print('[CartState._applyBackendCart]   -> productId=${item.productId} term=${item.term} qty=${item.quantity} backendItemId=${item.id} name=${item.product?.name}');
      _items.add(CartItem(
        productId: item.productId.toString(),
        plan: PlanX.fromId(item.term),
        qty: item.quantity,
        backendItemId: item.id,
      ));
    }
  }
}
