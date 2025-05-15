import 'package:flutter/material.dart';
import 'package:greens_app/models/chatbot_message.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/views/product_detail_view.dart';
import 'package:greens_app/views/article_detail_view.dart';

/// Widget pour afficher une bulle de message dans l'interface du chatbot
class ChatbotMessageBubble extends StatelessWidget {
  final ChatbotMessage message;
  final Function(String) onSuggestionTap;

  const ChatbotMessageBubble({
    Key? key,
    required this.message,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: AppColors.secondaryColor,
              radius: 18,
              child: const Icon(Icons.eco, color: Colors.white, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Bulle de message
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryColor : AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      
                      // Afficher les suggestions s'il y en a
                      if (!isUser && message.suggestedActions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildSuggestions(),
                        ),
                    ],
                  ),
                ),
                
                // Afficher les recommandations de produits s'il y en a
                if (!isUser && message.productRecommendations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildProductRecommendations(context),
                  ),
                
                // Afficher les recommandations d'articles s'il y en a
                if (!isUser && message.articleRecommendations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildArticleRecommendations(context),
                  ),
              ],
            ),
          ),
          
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.blueGrey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: message.suggestedActions.map((suggestion) {
        return GestureDetector(
          onTap: () => onSuggestionTap(suggestion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              suggestion,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildProductRecommendations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Produits recommandés',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: message.productRecommendations.length,
            itemBuilder: (context, index) {
              final productModel = message.productRecommendations[index];
              return _buildProductCard(context, productModel);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildProductCard(BuildContext context, ProductModel productModel) {
    // Convert ProductModel to Product
    final product = Product(
      id: productModel.id,
      name: productModel.name,
      description: productModel.description,
      brand: productModel.brand,
      category: productModel.categories.isNotEmpty ? productModel.categories.first : 'Non classé',
      imageUrl: productModel.imageUrl ?? '',
      isEcoFriendly: productModel.isEcoFriendly,
      price: productModel.price,
      merchantUrl: productModel.merchantUrl,
    );
    
    return GestureDetector(
      onTap: () {
        // Naviguer vers la page de détail du produit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailView(
              product: product,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                product.imageUrl ?? 'assets/images/placeholder.png',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Informations du produit
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildArticleRecommendations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Articles recommandés',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        Column(
          children: message.articleRecommendations.map((article) => 
            _buildArticleCard(context, article)
          ).toList(),
        ),
      ],
    );
  }
  
  Widget _buildArticleCard(BuildContext context, ArticleModel article) {
    return GestureDetector(
      onTap: () {
        // Naviguer vers la page de détail de l'article
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailView(
              article: article,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image de l'article
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                article.imageUrl ?? 'assets/images/placeholder.png',
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            // Informations de l'article
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.summaryText,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 12,
                          color: AppColors.secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.category,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}