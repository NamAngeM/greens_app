import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greens_app/services/admin_service.dart';
import 'package:greens_app/models/article_model.dart';

class AdminArticleManagement extends StatefulWidget {
  const AdminArticleManagement({Key? key}) : super(key: key);

  @override
  _AdminArticleManagementState createState() => _AdminArticleManagementState();
}

class _AdminArticleManagementState extends State<AdminArticleManagement> {
  final AdminService _adminService = AdminService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  List<Article> _articles = [];
  String _searchQuery = '';
  String _filterCategory = 'Toutes';
  String _filterStatus = 'Tous';
  List<String> _categories = ['Toutes', 'Actualités', 'Conseils', 'Études', 'Événements', 'Tutoriels'];

  // Contrôleurs pour le formulaire d'ajout/édition
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String _selectedCategory = 'Actualités';
  bool _isFeatured = false;
  bool _isPublished = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    try {
      final articles = await _adminService.getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des articles: $e')),
        );
      }
    }
  }

  List<Article> get _filteredArticles {
    return _articles.where((article) {
      final matchesSearch = 
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          article.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.author.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _filterCategory == 'Toutes' || article.category == _filterCategory;
      
      final bool isPublished = article.isPublished;
      final bool matchesStatus = _filterStatus == 'Tous' || 
                              (_filterStatus == 'Publié' && isPublished) || 
                              (_filterStatus == 'Brouillon' && !isPublished);
      
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Future<void> _toggleArticlePublishStatus(String articleId, bool currentStatus) async {
    try {
      await _adminService.updateArticle(articleId, {
        'isPublished': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut de publication mis à jour'))
      );
      
      _loadArticles();
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du statut'))
      );
    }
  }

  Future<void> _toggleArticleFeaturedStatus(String articleId, bool currentStatus) async {
    try {
      await _adminService.updateArticle(articleId, {
        'isFeatured': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut de mise en avant mis à jour'))
      );
      
      _loadArticles();
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du statut'))
      );
    }
  }

  Future<void> _deleteArticle(String articleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'article'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet article ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adminService.deleteArticle(articleId);
        _loadArticles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  void _showAddEditArticleDialog([Article? article]) {
    final bool isEditing = article != null;
    bool _showPreview = false;
    
    // Remplir les contrôleurs si en mode édition
    if (isEditing) {
      _titleController.text = article.title;
      _subtitleController.text = article.subtitle;
      _contentController.text = article.content;
      _authorController.text = article.author;
      _imageUrlController.text = article.imageUrl ?? '';
      _selectedCategory = article.category;
      _isFeatured = article.isFeatured;
      _isPublished = article.isPublished;
    } else {
      // Réinitialiser les contrôleurs pour un nouvel article
      _titleController.clear();
      _subtitleController.clear();
      _contentController.clear();
      _authorController.text = 'Admin';
      _imageUrlController.clear();
      _selectedCategory = 'Actualités';
      _isFeatured = false;
      _isPublished = true;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEditing ? 'Modifier l\'article' : 'Ajouter un nouvel article'),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.remove_red_eye),
                      label: Text(_showPreview ? 'Éditer' : 'Prévisualiser'),
                      onPressed: () {
                        setState(() {
                          _showPreview = !_showPreview;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            content: Container(
              width: 800,
              height: 600,
              child: _showPreview 
                  ? _buildArticlePreview()
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Titre',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _subtitleController,
                            decoration: InputDecoration(
                              labelText: 'Sous-titre',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              labelText: 'Contenu',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                              helperText: 'Vous pouvez utiliser la syntaxe Markdown',
                            ),
                            maxLines: 15,
                            minLines: 10,
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _authorController,
                                  decoration: InputDecoration(
                                    labelText: 'Auteur',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Catégorie',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _selectedCategory,
                                  items: _categories.where((c) => c != 'Toutes').map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(
                              labelText: 'URL de l\'image',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile(
                                  title: const Text('Mettre en avant'),
                                  value: _isFeatured,
                                  onChanged: (value) {
                                    setState(() {
                                      _isFeatured = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: SwitchListTile(
                                  title: const Text('Publier'),
                                  value: _isPublished,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPublished = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_imageUrlController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Aperçu de l\'image:'),
                                  SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _imageUrlController.text,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 100,
                                          width: double.infinity,
                                          color: Colors.grey.shade300,
                                          child: Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
                onPressed: () => _saveArticle(article?['id']),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _saveArticle([String? articleId]) async {
    final bool isEditing = articleId != null;
    
    try {
      final Map<String, dynamic> articleData = {
        'title': _titleController.text,
        'subtitle': _subtitleController.text,
        'content': _contentController.text,
        'author': _authorController.text,
        'category': _selectedCategory,
        'imageUrl': _imageUrlController.text,
        'isFeatured': _isFeatured,
        'isPublished': _isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (isEditing) {
        // Mettre à jour l'article existant
        await _adminService.updateArticle(articleId, articleData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article mis à jour avec succès'))
        );
      } else {
        // Ajouter un nouvel article
        articleData['viewCount'] = 0;
        articleData['likeCount'] = 0;
        articleData['commentCount'] = 0;
        articleData['publishDate'] = FieldValue.serverTimestamp();
        articleData['createdAt'] = FieldValue.serverTimestamp();
        
        await _adminService.createArticle(articleData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nouvel article créé avec succès'))
        );
      }
      
      Navigator.of(context).pop();
      _loadArticles();
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'article: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde de l\'article'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestion des Articles',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Rédiger un article'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showAddEditArticleDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildArticleStats(),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildArticlesTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un article...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _filterCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filterCategory = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _filterStatus,
                items: const [
                  DropdownMenuItem(value: 'Tous', child: Text('Tous')),
                  DropdownMenuItem(value: 'Publié', child: Text('Publié')),
                  DropdownMenuItem(value: 'Brouillon', child: Text('Brouillon')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _loadArticles,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleStats() {
    final totalArticles = _articles.length;
    final publishedArticles = _articles.where((article) => article.isPublished == true).length;
    final featuredArticles = _articles.where((article) => article.isFeatured == true).length;
    
    // Calculer l'article le plus populaire
    Article? mostViewedArticle;
    int maxViews = 0;
    
    for (var article in _articles) {
      final views = article.viewCount as int;
      if (views > maxViews) {
        maxViews = views;
        mostViewedArticle = article;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Articles',
            '$totalArticles',
            Icons.article,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Articles Publiés',
            '$publishedArticles',
            Icons.publish,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Articles en Une',
            '$featuredArticles',
            Icons.star,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Article le plus lu',
            mostViewedArticle != null ? '${mostViewedArticle.title} (${mostViewedArticle.viewCount} vues)' : 'Aucun',
            Icons.visibility,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          columns: const [
            DataColumn2(
              label: Text('Titre'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('Auteur'),
            ),
            DataColumn(
              label: Text('Catégorie'),
            ),
            DataColumn(
              label: Text('Publication'),
            ),
            DataColumn(
              label: Text('Statistiques'),
              numeric: true,
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: _filteredArticles.map((article) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          if (article.isFeatured)
                            Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              article.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        article.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                DataCell(Text(article.author)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(article.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article.category,
                      style: TextStyle(
                        color: _getCategoryColor(article.category),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: article.isPublished ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.isPublished ? 'Publié' : 'Brouillon',
                          style: TextStyle(
                            color: article.isPublished ? Colors.green : Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(article.publishDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildStatIcon(Icons.visibility, article.viewCount),
                      const SizedBox(width: 8),
                      _buildStatIcon(Icons.thumb_up, article.likeCount),
                      const SizedBox(width: 8),
                      _buildStatIcon(Icons.comment, article.commentCount),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          article.isPublished ? Icons.unpublished : Icons.publish,
                          color: article.isPublished ? Colors.orange : Colors.green,
                        ),
                        tooltip: article.isPublished ? 'Dépublier' : 'Publier',
                        onPressed: () {
                          _toggleArticlePublishStatus(article.id, article.isPublished);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          article.isFeatured ? Icons.star : Icons.star_border,
                          color: article.isFeatured ? Colors.amber : Colors.grey,
                        ),
                        tooltip: article.isFeatured ? 'Retirer de la une' : 'Mettre en une',
                        onPressed: () {
                          _toggleArticleFeaturedStatus(article.id, article.isFeatured);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Modifier',
                        onPressed: () {
                          _showAddEditArticleDialog(article);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Supprimer',
                        onPressed: () {
                          _deleteArticle(article.id);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 2),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Actualités':
        return Colors.blue;
      case 'Conseils':
        return Colors.green;
      case 'Études':
        return Colors.purple;
      case 'Événements':
        return Colors.orange;
      case 'Tutoriels':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildArticlePreview() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imageUrlController.text.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(_imageUrlController.text),
                    fit: BoxFit.cover,
                    onError: (_, __) => {},
                  ),
                ),
              ),
            Row(
              children: [
                if (_isFeatured)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'À la une',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_selectedCategory).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedCategory,
                    style: TextStyle(
                      color: _getCategoryColor(_selectedCategory),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _titleController.text.isEmpty ? 'Titre de l\'article' : _titleController.text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_subtitleController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _subtitleController.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green,
                  child: Text(
                    _authorController.text.isNotEmpty 
                        ? _authorController.text[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _authorController.text,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: _contentController.text.isEmpty 
                    ? '_Le contenu de l\'article apparaîtra ici..._' 
                    : _contentController.text,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  p: const TextStyle(fontSize: 16, height: 1.5),
                  listBullet: TextStyle(color: Colors.grey.shade800),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isPublished)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Cet article est en mode brouillon et ne sera pas visible par les utilisateurs',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 