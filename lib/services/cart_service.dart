import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greens_app/models/cart_item_model.dart';
import 'package:greens_app/models/product_model.dart';

class CartService extends ChangeNotifier {
  List<CartItemModel> _items = [];
  double _discountAmount = 0.0;
  String _promoCode = '';
  bool _isApplyingPromo = false;

  // Getters
  List<CartItemModel> get items => _items;
  double get discountAmount => _discountAmount;
  String get promoCode => _promoCode;
  bool get isApplyingPromo => _isApplyingPromo;
  bool get isEmpty => _items.isEmpty;
  
  // Calculer le sous-total (avant remise)
  double get subtotal {
    return _items.fold(0, (total, item) => total + item.totalPrice);
  }
  
  // Calculer le total (après remise)
  double get total {
    double finalTotal = subtotal - _discountAmount;
    return finalTotal > 0 ? finalTotal : 0;
  }
  
  // Nombre total d'articles dans le panier
  int get itemCount {
    return _items.fold(0, (count, item) => count + item.quantity);
  }

  // Ajouter un produit au panier
  void addItem(ProductModel product) {
    final index = _findItemIndex(product.id);
    
    if (index >= 0) {
      // Le produit existe déjà, augmenter la quantité
      _items[index].quantity++;
    } else {
      // Ajouter un nouveau produit
      _items.add(CartItemModel(product: product));
    }
    
    notifyListeners();
    saveCart();
  }
  
  // Supprimer un article du panier
  CartItemModel removeItem(int index) {
    final removedItem = _items.removeAt(index);
    notifyListeners();
    saveCart();
    return removedItem;
  }
  
  // Mettre à jour la quantité d'un article
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      saveCart();
    }
  }
  
  // Vider le panier
  List<CartItemModel> clearCart() {
    final oldItems = List<CartItemModel>.from(_items);
    _items.clear();
    _discountAmount = 0;
    _promoCode = '';
    notifyListeners();
    saveCart();
    return oldItems;
  }
  
  // Restaurer des articles précédemment supprimés
  void restoreItems(List<CartItemModel> items) {
    _items = items;
    notifyListeners();
    saveCart();
  }
  
  // Appliquer un code promo
  Future<bool> applyPromoCode(String code) async {
    _isApplyingPromo = true;
    _promoCode = code;
    notifyListeners();
    
    // Simuler une vérification du code promo
    await Future.delayed(const Duration(seconds: 1));
    
    bool isValid = false;
    if (code.toUpperCase() == 'GREEN10') {
      // 10% de réduction
      _discountAmount = subtotal * 0.1;
      isValid = true;
    } else if (code.toUpperCase() == 'FREESHIP') {
      // Livraison gratuite (déjà gratuite dans notre exemple)
      isValid = true;
    } else {
      // Code invalide
      _discountAmount = 0;
      isValid = false;
    }
    
    _isApplyingPromo = false;
    notifyListeners();
    saveCart();
    return isValid;
  }
  
  // Trouver l'index d'un article dans le panier
  int _findItemIndex(String productId) {
    return _items.indexWhere((item) => item.product.id == productId);
  }
  
  // Sauvegarder le panier dans SharedPreferences
  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart_data', cartData);
      
      // Sauvegarder aussi les informations de remise
      await prefs.setDouble('discount_amount', _discountAmount);
      await prefs.setString('promo_code', _promoCode);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du panier: $e');
    }
  }
  
  // Charger le panier depuis SharedPreferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_data');
      
      if (cartData != null && cartData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cartData);
        _items = decoded.map((item) => CartItemModel.fromJson(item)).toList();
      }
      
      // Charger aussi les informations de remise
      _discountAmount = prefs.getDouble('discount_amount') ?? 0.0;
      _promoCode = prefs.getString('promo_code') ?? '';
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement du panier: $e');
    }
  }
}