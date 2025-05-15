import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import '../controllers/social_feed_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final VoidCallback? onDelete;
  final bool isUserPost;
  
  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onShare,
    required this.onBookmark,
    this.onDelete,
    this.isUserPost = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec avatar et nom d'utilisateur
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(post.authorAvatar),
              onBackgroundImageError: (_, __) {},
              child: post.authorAvatar.isEmpty ? Text(post.author[0]) : null,
            ),
            title: Text(
              post.author,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              timeago.format(post.createdAt, locale: 'fr'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: _buildMoreButton(),
          ),
          
          // Titre du post
          if (post.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // Contenu du post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post.content),
          ),
          
          // Image du post
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Image.asset(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
          
          // Tags
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: post.tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ),
          
          const Divider(),
          
          // Actions (likes, commentaires, partage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : null,
                  label: '${post.likes}',
                  onPressed: onLike,
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post.comments}',
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Partager',
                  onPressed: onShare,
                ),
                _buildActionButton(
                  icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: post.isBookmarked ? AppColors.primaryColor : null,
                  label: '',
                  onPressed: onBookmark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoreButton() {
    if (!isUserPost) return const SizedBox.shrink();
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Supprimer', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Modifier'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label),
            ],
          ],
        ),
      ),
    );
  }
} 