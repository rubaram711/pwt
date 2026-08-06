import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/dio_service.dart';
import '../../Models/Auth/user_model.dart';
import '../../Backend/Promotions/validate_promotion.dart';
import '../../Backend/Reference/get_public_settings.dart';
import '../../Models/Products/products_model.dart';
import '../../Backend/Cart/get_cart.dart';
import '../../Backend/Cart/add_cart_item.dart';
import '../../Backend/Cart/update_cart_item.dart';
import '../../Backend/Cart/remove_cart_item.dart';
import '../../Backend/Cart/clear_cart.dart';
import '../../Backend/Products/show_product.dart';
import '../../Models/Cart/cart_model.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Models/Reference/country_model.dart';
import '../../Backend/Addresses/get_addresses.dart';
import '../../Models/address_model.dart';

/// One line in the cart.
class CartLine {
  final ProductModel product;
  int qty;
  final String mode; // 'buy' | 'rent'
  int? backendItemId;
  CartLine({required this.product, this.qty = 1, this.mode = 'buy', this.backendItemId});

  double get unit {
    if (mode == 'rent') {
      final rentPrice = product.prices.where((p) => p.term == 'rent').firstOrNull;
      return double.tryParse(rentPrice?.amount ?? '0') ?? 0;
    }
    final buyPrice = product.prices.where((p) => p.term == 'buy').firstOrNull;
    return double.tryParse(buyPrice?.amount ?? product.finalPrice ?? product.startingPrice?.amount ?? '0') ?? 0;
  }

  double get lineTotal => unit * qty;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'qty': qty,
        'mode': mode,
        if (backendItemId != null) 'backend_item_id': backendItemId,
      };

  static CartLine? fromJson(Map<String, dynamic> j) {
    try {
      final productData = j['product'];
      if (productData == null) return null;
      final p = ProductModel.fromJson(productData as Map<String, dynamic>);
      return CartLine(product: p, qty: j['qty'] ?? 1, mode: j['mode'] ?? 'buy', backendItemId: j['backend_item_id']);
    } catch (_) {
      return null;
    }
  }
}

/// A scheduled maintenance visit (mirrors the prototype's `pwt_maint`).
class MaintVisit {
  List<String> devices;
  String date; // ISO yyyy-mm-dd or ''
  String slot;
  String notes;
  String status; // 'Scheduled' | 'Cancellation requested'
  MaintVisit({required this.devices, this.date = '', this.slot = '', this.notes = '', this.status = 'Scheduled'});

  Map<String, dynamic> toJson() => {
        'devices': devices,
        'date': date,
        'slot': slot,
        'notes': notes,
        'status': status,
      };

  factory MaintVisit.fromJson(Map<String, dynamic> j) => MaintVisit(
        devices: (j['devices'] as List).map((e) => e.toString()).toList(),
        date: j['date'] ?? '',
        slot: j['slot'] ?? '',
        notes: j['notes'] ?? '',
        status: j['status'] ?? 'Scheduled',
      );
}

/// Saved address (Profile).
class Address {
  int id;
  String label, line1, line2, city, postcode, country;
  bool isDefault;
  Address({required this.id, required this.label, required this.line1, this.line2 = '', required this.city, required this.postcode, this.country = 'United Kingdom', this.isDefault = false});
  String get full => [line1, line2, city, postcode, country].where((s) => s.isNotEmpty).join(', ');
}

/// Saved card (Profile).
class PayCard {
  int id;
  String brand; // VISA | MC | CARD
  String last4;
  String exp;
  bool isDefault;
  PayCard({required this.id, required this.brand, required this.last4, required this.exp, this.isDefault = false});
}

/// Global app state — single source of truth, persisted to shared_preferences.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  late final DioService dioService = DioService();
  static const _kAuth        = 'pwt_auth';
  static const _kToken       = 'pwt_token';
  static const _kMaint       = 'pwt_maint';
  static const _kLang        = 'pwt_lang';
  static const _kWa          = 'pwt_wa';
  static const _kPassword    = 'pwt_password';
  static const _kAccountType = 'pwt_account_type';

  User? user;
  String? accessToken;
  String? currentPassword;
  String? whatsappNumber;
  final List<CartLine> cart = [];
  final List<MaintVisit> maintenance = [];

  // ---- VAT ----
  // Countries (with their vat_rate) fetched from the backend's country
  // reference API. VAT starts at 0 until the real rate for the relevant
  // address's country has loaded, rather than showing a guessed number.
  List<CountryModel> countries = [];
  num vatRatePercent = 0;

  String? _appliedPromoCode;
  double _promoDiscount = 0.0;
  bool _promoLoading = false;
  String? _promoError;
  bool _promoValid = false;

  String? get appliedPromoCode => _appliedPromoCode;
  double get promoDiscount => _promoDiscount;
  bool get promoLoading => _promoLoading;
  String? get promoError => _promoError;
  bool get promoValid => _promoValid;

  /// UI language ('en' | 'ar') — mirrors the prototype's localStorage pwt_lang.
  String lang = 'en';

  bool _loaded = false;
  bool get loaded => _loaded;

  bool get isCompany => user?.isCompany ?? false;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    // language
    lang = p.getString(_kLang) ?? 'en';
    // auth
    final a = p.getString(_kAuth);
    if (a != null) {
      try {
        user = User.fromJson(jsonDecode(a));
      } catch (_) {}
    }
    accessToken     = p.getString(_kToken);
    currentPassword = p.getString(_kPassword);
    // maintenance
    final m = p.getString(_kMaint);
    maintenance.clear();
    if (m != null) {
      try {
        for (final e in (jsonDecode(m) as List)) {
          maintenance.add(MaintVisit.fromJson(e));
        }
      } catch (_) {}
    }
    // whatsapp number — serve from cache instantly, refresh in background
    whatsappNumber = p.getString(_kWa);
    _refreshPublicSettings(p);
    if (user != null) {
      _loadCartFromBackend();
      loadDefaultVatRate();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _refreshPublicSettings(SharedPreferences p) async {
    try {
      final result = await getPublicSettings();
      if (result.success && result.data?.whatsappNumber != null) {
        whatsappNumber = result.data!.whatsappNumber;
        await p.setString(_kWa, whatsappNumber!);
        notifyListeners();
      }
    } catch (_) {}
  }

  // ---- auth ----
  Future<void> signIn(User u, String token, {String? password, String? accountType}) async {
    user = u;
    accessToken = token;
    if (password != null && password.isNotEmpty) currentPassword = password;
    final p = await SharedPreferences.getInstance();
    // Patch accountType into the JSON if the API didn't return it
    final userJson = u.toJson();
    if (accountType != null && (userJson['account_type'] == null)) {
      userJson['account_type'] = accountType;
      user = User.fromJson(userJson);
    }
    await p.setString(_kAuth, jsonEncode(user!.toJson()));
    await p.setString(_kToken, token);
    if (currentPassword != null) await p.setString(_kPassword, currentPassword!);
    if (accountType != null) await p.setString(_kAccountType, accountType);
    _loadCartFromBackend();
    loadDefaultVatRate();
    notifyListeners();
  }

  Future<void> persistUser(User u) async {
    user = u;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAuth, jsonEncode(u.toJson()));
    notifyListeners();
  }

  /// Keeps the cached password (used to re-authenticate other profile edits)
  /// in sync after the user successfully changes their password.
  Future<void> updateCurrentPassword(String password) async {
    currentPassword = password;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPassword, password);
  }

  Future<void> signOut() async {
    cart.clear();
    user = null;
    accessToken = null;
    currentPassword = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAuth);
    await p.remove(_kToken);
    await p.remove(_kPassword);
    await p.remove(_kAccountType);
    notifyListeners();
  }

  // ---- language ----
  Future<void> setLang(String l) async {
    if (l == lang) return;
    lang = l;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, l);
    notifyListeners();
  }

  // ---- cart ----
  int get cartCount => cart.fold(0, (s, l) => s + l.qty);
  double get subtotal => cart.fold(0, (s, l) => s + l.lineTotal);
  double get vat => subtotal * (vatRatePercent / 100);
  double get total => subtotal + vat - _promoDiscount;

  Future<void> loadCountries() async {
    final res = await getCountries();
    if (res.success && res.data != null) {
      countries = res.data!;
    }
  }

  num? vatRateForCountryCode(String? code) {
    if (code == null) return null;
    for (final c in countries) {
      if (c.code == code) return c.vatRate;
    }
    return null;
  }

  /// Recomputes [vatRatePercent] from `address`'s country. Called on load
  /// and whenever the user picks a different delivery address at checkout.
  Future<void> setVatRateForAddress(AddressModel? address) async {
    if (countries.isEmpty) await loadCountries();
    final rate = vatRateForCountryCode(address?.country?.code);
    vatRatePercent = rate ?? 0;
    notifyListeners();
  }

  /// Loads the VAT rate for the signed-in user's default delivery address.
  Future<void> loadDefaultVatRate() async {
    await loadCountries();
    final res = await getAddresses();
    if (res.success && res.data != null && res.data!.isNotEmpty) {
      final addresses = res.data!;
      final def = addresses.firstWhere((a) => a.isDefault == true, orElse: () => addresses.first);
      await setVatRateForAddress(def);
    }
  }

  Future<void> addToCart(ProductModel product, {String mode = 'buy', int qty = 1}) async {
    // Optimistic update
    final existing = cart.where((l) => l.product.id == product.id && l.mode == mode).firstOrNull;
    final existingBackendId = existing?.backendItemId;
    if (existing != null) {
      existing.qty += qty;
    } else {
      cart.add(CartLine(product: product, mode: mode, qty: qty));
    }
    notifyListeners();

    if (user != null && product.id != null) {
      final newQty = cart.where((l) => l.product.id == product.id && l.mode == mode).firstOrNull?.qty ?? qty;
      final res = existingBackendId != null
          ? await updateCartItem(existingBackendId, quantity: newQty)
          : await addCartItem(productId: product.id!, term: mode, quantity: qty);
      if (res.success && res.data != null) {
        _applyBackendCart(res.data!, knownProduct: product);
        notifyListeners();
      }
    }
  }

  void incQty(CartLine l) {
    l.qty++;
    notifyListeners();
    if (user != null) {
      final call = l.backendItemId != null
          ? updateCartItem(l.backendItemId!, quantity: l.qty)
          : addCartItem(productId: l.product.id!, term: l.mode, quantity: 1);
      call.then((res) {
        if (res.success && res.data != null) { _applyBackendCart(res.data!); notifyListeners(); }
      });
    }
  }

  void decQty(CartLine l) {
    if (l.qty <= 1) return;
    l.qty--;
    notifyListeners();
    if (user != null && l.backendItemId != null) {
      updateCartItem(l.backendItemId!, quantity: l.qty).then((res) {
        if (res.success && res.data != null) { _applyBackendCart(res.data!); notifyListeners(); }
      });
    }
  }

  Future<void> removeLine(CartLine l) async {
    cart.remove(l);
    notifyListeners();
    if (user != null && l.backendItemId != null) {
      final res = await removeCartItem(l.backendItemId!);
      if (res.success && res.data != null) {
        _applyBackendCart(res.data!);
        notifyListeners();
      }
    }
  }

  Future<void> clearBackendCart() async {
    if (user != null) await clearCart();
    cart.clear();
    clearPromo();
    notifyListeners();
  }

  // Rebuild local cart from backend response, keeping full ProductModels in memory.
  void _applyBackendCart(CartModel backendCart, {ProductModel? knownProduct}) {
    final productCache = <int, ProductModel>{
      for (final l in cart) if (l.product.id != null) l.product.id!: l.product,
      if (knownProduct?.id != null) knownProduct!.id!: knownProduct,
    };
    cart.clear();
    for (final item in backendCart.items) {
      final product = productCache[item.productId];
      if (product != null) {
        cart.add(CartLine(product: product, qty: item.quantity, mode: item.term, backendItemId: item.id));
      }
    }
  }

  // On login: load backend cart and enrich missing products via API.
  Future<void> _loadCartFromBackend() async {
    final res = await getCart();
    if (!res.success || res.data == null || res.data!.items.isEmpty) return;
    final productCache = <int, ProductModel>{
      for (final l in cart) if (l.product.id != null) l.product.id!: l.product,
    };
    final newCart = <CartLine>[];
    for (final item in res.data!.items) {
      var product = productCache[item.productId];
      if (product == null) {
        final pRes = await getProductDetails(item.productId);
        if (pRes.success && pRes.data != null) product = pRes.data;
      }
      if (product != null) {
        newCart.add(CartLine(product: product, qty: item.quantity, mode: item.term, backendItemId: item.id));
      }
    }
    cart
      ..clear()
      ..addAll(newCart);
    notifyListeners();
  }

  Future<bool> applyPromo(String code) async {
    _promoLoading = true;
    _promoError = null;
    notifyListeners();

    final result = await validatePromotion(
      code: code.trim().toUpperCase(),
      subtotal: subtotal,
      currency: 'AED',
    );

    _promoLoading = false;

    if (result.success && result.data != null) {
      final promo = result.data!;
      if (promo.valid) {
        _appliedPromoCode = promo.code;
        _promoDiscount = double.tryParse(promo.appliedAmount ?? '0') ?? 0;
        _promoValid = true;
        _promoError = null;
      } else {
        _appliedPromoCode = null;
        _promoDiscount = 0;
        _promoValid = false;
        _promoError = _reasonMessage(promo.reasonCode);
      }
    } else {
      _appliedPromoCode = null;
      _promoDiscount = 0;
      _promoValid = false;
      _promoError = result.message ?? 'Could not validate code. Try again.';
    }

    notifyListeners();
    return _promoValid;
  }

  void clearPromo() {
    _appliedPromoCode = null;
    _promoDiscount = 0;
    _promoValid = false;
    _promoError = null;
    notifyListeners();
  }

  String _reasonMessage(String code) {
    switch (code) {
      case 'expired': return 'This promo code has expired.';
      case 'not_started': return 'This promo code is not active yet.';
      case 'usage_limit_reached': return 'This promo code has reached its usage limit.';
      case 'user_limit_reached': return 'You have already used this promo code.';
      case 'min_order_not_met': return 'Minimum order amount not reached.';
      case 'not_applicable': return 'This code does not apply to items in your cart.';
      case 'invalid_code': return 'Invalid promo code.';
      default: return 'Promo code could not be applied.';
    }
  }

  // ---- maintenance ----
  void addMaintenance(MaintVisit v) {
    maintenance.insert(0, v);
    _persistMaint();
    notifyListeners();
  }

  void updateMaintenance(int idx, MaintVisit v) {
    if (idx >= 0 && idx < maintenance.length) {
      maintenance[idx] = v;
      _persistMaint();
      notifyListeners();
    }
  }

  void removeMaintenance(int idx) {
    if (idx >= 0 && idx < maintenance.length) {
      maintenance.removeAt(idx);
      _persistMaint();
      notifyListeners();
    }
  }

  Future<void> _persistMaint() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kMaint, jsonEncode(maintenance.map((v) => v.toJson()).toList()));
  }
}
