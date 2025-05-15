import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/social_feed_controller.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({Key? key}) : super(key: key);

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Charger les posts
    Future.microtask(() {
      Provider.of<SocialFeedController>(context, listen: false).loadPosts();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final feedController = Provider.of<SocialFeedController>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  feedController.searchPosts(value);
                },
                autofocus: true,
              )
            : const Text('Communauté Verte'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  feedController.clearSearch();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pour vous'),
            Tab(text: 'Tendances'),
            Tab(text: 'Mes posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet "Pour vous"
          _buildPostList(feedController.recommendedPosts, feedController.isLoading),
          
          // Onglet "Tendances"
          _buildPostList(feedController.trendingPosts, feedController.isLoading),
          
          // Onglet "Mes posts"
          _buildPostList(feedController.userPosts, feedController.isLoading, isUserPosts: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildPostList(List<Post> posts, bool isLoading, {bool isUserPosts = false}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUserPosts ? Icons.post_add : Icons.feed,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isUserPosts
                  ? 'Vous n\'avez pas encore publié de contenu.'
                  : 'Aucun post à afficher pour le moment.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (isUserPosts) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Créer votre premier post'),
              ),
            ],
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => Provider.of<SocialFeedController>(context, listen: false).loadPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PostCard(
              post: post,
              onLike: () => _toggleLike(post),
              onShare: () => _sharePost(post),
              onBookmark: () => _toggleBookmark(post),
              isUserPost: isUserPosts,
              onDelete: isUserPosts ? () => _deletePost(post) : null,
            ),
          );
        },
      ),
    );
  }
  
  void _showFilterDialog() {
    final feedController = Provider.of<SocialFeedController>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtrer les publications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Tous', PostCategory.all, feedController),
                  _buildFilterChip('Astuces', PostCategory.tips, feedController),
                  _buildFilterChip('Réalisations', PostCategory.achievements, feedController),
                  _buildFilterChip('Questions', PostCategory.questions, feedController),
                  _buildFilterChip('Produits', PostCategory.products, feedController),
                  _buildFilterChip('Événements', PostCategory.events, feedController),
                ],
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Trier par',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip('Plus récents', SortOrder.newest, feedController),
                  _buildSortChip('Plus populaires', SortOrder.mostLiked, feedController),
                  _buildSortChip('Plus commentés', SortOrder.mostCommented, feedController),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, PostCategory category, SocialFeedController controller) {
    final isSelected = category == controller.selectedCategory;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.filterByCategory(category);
          Navigator.pop(context);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.secondaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.secondaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildSortChip(String label, SortOrder sortOrder, SocialFeedController controller) {
    final isSelected = sortOrder == controller.currentSortOrder;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.sortBy(sortOrder);
          Navigator.pop(context);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.secondaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  void _toggleLike(Post post) {
    Provider.of<SocialFeedController>(context, listen: false).toggleLike(post.id);
  }
  
  void _toggleBookmark(Post post) {
    Provider.of<SocialFeedController>(context, listen: false).toggleBookmark(post.id);
  }
  
  void _deletePost(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce post?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<SocialFeedController>(context, listen: false).deletePost(post.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post supprimé')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToComments(Post post) {
    // Naviguer vers la page de commentaires (à implémenter)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Page de commentaires à implémenter')),
    );
  }
  
  void _sharePost(Post post) {
    Share.share(
      '${post.title}\n\n${post.content}\n\nPartagé depuis l\'app Greens',
    );
  }
} 