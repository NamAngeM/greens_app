import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greens_app/models/favorite_item_model.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/utils/merchant_urls.dart';

class FavoritesService extends ChangeNotifier {
  List<FavoriteItemModel> _items = [];
  
  // Getters
  List<FavoriteItemModel> get items => _items;
  bool get isEmpty => _items.isEmpty;
  
  // Nombre total de produits dans la liste de favoris
  int get itemCount {
    return _items.length;
  }

  // Ajouter un produit aux favoris
  void addItem(ProductModel product) {
    final index = _findItemIndex(product.id);
    
    if (index >= 0) {
      // Le produit existe déjà, mettre à jour la date
      _items[index].addedAt = DateTime.now();
    } else {
      // Ajouter un nouveau produit
      _items.add(FavoriteItemModel(product: product));
    }
    
    notifyListeners();
    saveFavorites();
  }
  
  // Supprimer un article des favoris
  FavoriteItemModel removeItem(int index) {
    final removedItem = _items.removeAt(index);
    notifyListeners();
    saveFavorites();
    return removedItem;
  }
  
  // Vider la liste de favoris
  List<FavoriteItemModel> clearFavorites() {
    final oldItems = List<FavoriteItemModel>.from(_items);
    _items.clear();
    notifyListeners();
    saveFavorites();
    return oldItems;
  }
  
  // Restaurer des articles précédemment supprimés
  void restoreItems(List<FavoriteItemModel> items) {
    _items = items;
    notifyListeners();
    saveFavorites();
  }
  
  // Trouver l'index d'un produit dans la liste de favoris
  int _findItemIndex(String productId) {
    return _items.indexWhere((item) => item.product.id == productId);
  }
  
  // Vérifier si un produit est dans les favoris
  bool isInFavorites(String productId) {
    return _findItemIndex(productId) >= 0;
  }
  
  // Sauvegarder la liste de favoris dans SharedPreferences
  Future<void> saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = _items.map((item) => item.toJson()).toList();
      
      await prefs.setString('favorites', jsonEncode(itemsJson));
      print('Favoris sauvegardés avec succès : ${_items.length} produits');
    } catch (e) {
      print('Erreur lors de la sauvegarde des favoris : $e');
    }
  }
  
  // Charger la liste de favoris depuis SharedPreferences
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');
      
      if (favoritesJson != null) {
        final List<dynamic> decodedItems = jsonDecode(favoritesJson);
        _items = decodedItems.map((item) => FavoriteItemModel.fromJson(item)).toList();
        
        notifyListeners();
        print('Favoris chargés avec succès : ${_items.length} produits');
      }
    } catch (e) {
      print('Erreur lors du chargement des favoris : $e');
    }
  }
  
  // Acheter tous les produits favoris (obtenir les URLs)
  List<String> getBuyUrls() {
    final List<String> urls = [];
    
    for (final item in _items) {
      String? url = item.product.merchantUrl;
      
      // Si l'URL n'est pas disponible directement dans le produit, essayer de la récupérer via MerchantUrls
      if (url == null || url.isEmpty) {
        final merchantInfo = MerchantUrls.getMerchantForProduct(item.product.id);
        if (merchantInfo != null) {
          url = merchantInfo.url;
        }
      }
      
      if (url != null && url.isNotEmpty) {
        urls.add(url);
      }
    }
    
    return urls;
  }
} 