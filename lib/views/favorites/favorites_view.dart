import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/services/favorites_service.dart';
import 'package:greens_app/models/favorite_item_model.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    // Charger les favoris
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesService>(context, listen: false).loadFavorites();
    });
  }

  // Ouvrir l'URL du marchand
  Future<void> _openMerchantUrl(String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune URL de marchand disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Impossible d'ouvrir le site marchand"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de l\'URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Acheter tous les produits favoris
  Future<void> _buyAllFavorites() async {
    final favoritesService = Provider.of<FavoritesService>(context, listen: false);
    final urls = favoritesService.getBuyUrls();
    
    if (urls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune URL de marchand disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ouvrir seulement la première URL pour l'instant (on pourrait en ouvrir plusieurs si nécessaire)
    await _openMerchantUrl(urls.first);
    
    // Afficher un message pour indiquer combien d'URLs restent à ouvrir
    if (urls.length > 1 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${urls.length - 1} autres produits à acheter'),
          action: SnackBarAction(
            label: 'SUIVANT',
            onPressed: () {
              _openMerchantUrl(urls[1]);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes Favoris',
          style: TextStyle(
            color: Color(0xFF1F3140),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.grey.shade600,
            onPressed: () {
              // Confirmation avant de vider les favoris
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Vider les favoris'),
                  content: const Text('Êtes-vous sûr de vouloir vider votre liste de favoris ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ANNULER'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final favoritesService = Provider.of<FavoritesService>(context, listen: false);
                        final oldItems = favoritesService.clearFavorites();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Favoris vidés'),
                            action: SnackBarAction(
                              label: 'ANNULER',
                              onPressed: () {
                                favoritesService.restoreItems(oldItems);
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('VIDER'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesService>(
        builder: (context, favoritesService, child) {
          final items = favoritesService.items;
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Votre liste de favoris est vide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des produits à vos favoris\npour les retrouver ici',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Découvrir des produits'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildFavoriteItem(item, index);
                  },
                ),
              ),
              _buildBottomBar(favoritesService),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomMenu(currentIndex: 3),
    );
  }

  // Construire un élément de la liste des favoris
  Widget _buildFavoriteItem(FavoriteItemModel item, int index) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        final favoritesService = Provider.of<FavoritesService>(context, listen: false);
        final removedItem = favoritesService.removeItem(index);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${removedItem.product.name} retiré des favoris'),
            action: SnackBarAction(
              label: 'ANNULER',
              onPressed: () {
                favoritesService.addItem(removedItem.product);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image du produit
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.product.imageUrl != null
                      ? item.product.imageUrl!.startsWith('http')
                          ? Image.network(
                              item.product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                            )
                          : Image.asset(
                              item.product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                            )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Informations du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F3140),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.product.isEcoFriendly)
                      Row(
                        children: [
                          const Icon(
                            Icons.eco,
                            size: 14,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Éco-responsable',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton d'achat
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                color: Colors.blue,
                onPressed: () {
                  _openMerchantUrl(item.product.merchantUrl);
                },
                tooltip: 'Acheter',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construire la barre inférieure avec le bouton "Acheter tout"
  Widget _buildBottomBar(FavoritesService favoritesService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nombre de produits
            Text(
              '${favoritesService.itemCount} produit${favoritesService.itemCount > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 16),
            // Bouton "Acheter tout"
            Expanded(
              child: ElevatedButton.icon(
                onPressed: favoritesService.isEmpty ? null : _buyAllFavorites,
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Acheter tout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 