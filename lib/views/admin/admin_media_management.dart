import 'package:flutter/material.dart';
import 'package:greens_app/services/media_service.dart';
import 'package:greens_app/services/admin_auth_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class AdminMediaManagement extends StatefulWidget {
  const AdminMediaManagement({Key? key}) : super(key: key);

  @override
  _AdminMediaManagementState createState() => _AdminMediaManagementState();
}

class _AdminMediaManagementState extends State<AdminMediaManagement> {
  final MediaService _mediaService = MediaService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  
  String _searchQuery = '';
  String _filterType = 'Tous';
  List<String> _mediaTypes = ['Tous', 'Image', 'Document', 'Vidéo', 'Audio'];
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _filteredMedia = [];
  
  TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadMedia();
  }
  
  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = true;
    });
    
    await _mediaService.loadMedia();
    _filterMedia();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _filterMedia() {
    final allMedia = _mediaService.mediaList;
    
    _filteredMedia = allMedia.where((media) {
      // Filtrer par type si un type est sélectionné
      if (_filterType != 'Tous' && media['type'].toString().toLowerCase() != _filterType.toLowerCase()) {
        return false;
      }
      
      // Filtrer par recherche
      if (_searchQuery.isNotEmpty) {
        final name = media['name'].toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copiée dans le presse-papiers')),
    );
  }
  
  Future<void> _uploadNewMedia() async {
    final userId = _adminAuthService.currentUser?.uid ?? 'admin';
    final newMedia = await _mediaService.pickAndUploadImage(userId);
    
    if (newMedia != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Média "${newMedia['name']}" téléchargé avec succès')),
      );
      _filterMedia();
      setState(() {});
    }
  }
  
  Future<void> _deleteMedia(String mediaId, String mediaName) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "$mediaName" ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    
    if (confirmDelete == true) {
      final success = await _mediaService.deleteMedia(mediaId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Média "$mediaName" supprimé avec succès')),
        );
        _filterMedia();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression du média')),
        );
      }
    }
  }
  
  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher un média',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterMedia();
              });
            },
          ),
        ),
        SizedBox(width: 16),
        DropdownButton<String>(
          value: _filterType,
          items: _mediaTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _filterType = value;
                _filterMedia();
              });
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildMediaGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width ~/ 250,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredMedia.length,
      itemBuilder: (context, index) {
        final media = _filteredMedia[index];
        return _buildMediaCard(media);
      },
    );
  }
  
  Widget _buildMediaCard(Map<String, dynamic> media) {
    final String name = media['name'] ?? 'Sans nom';
    final String url = media['url'] ?? '';
    final String type = media['type'] ?? 'image';
    final int size = media['size'] ?? 0;
    final DateTime createdAt = media['createdAt'] ?? DateTime.now();
    
    // Formater la taille du fichier
    String formattedSize;
    if (size < 1024) {
      formattedSize = '$size o';
    } else if (size < 1024 * 1024) {
      formattedSize = '${(size / 1024).toStringAsFixed(1)} Ko';
    } else {
      formattedSize = '${(size / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Afficher un aperçu de l'image
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              child: type.toLowerCase() == 'image'
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey.shade400));
                      },
                    )
                  : Center(
                      child: Icon(
                        _getIconForType(type),
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  formattedSize,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy, size: 20),
                      tooltip: 'Copier l\'URL',
                      onPressed: () => _copyToClipboard(url),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                      tooltip: 'Supprimer',
                      onPressed: () => _deleteMedia(media['id'], name),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      case 'vidéo':
      case 'video':
        return Icons.video_library;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  Widget _buildMediaStats() {
    final mediaCount = _mediaService.mediaList.length;
    final imagesCount = _mediaService.mediaList.where((m) => m['type']?.toString().toLowerCase() == 'image').length;
    final documentsCount = _mediaService.mediaList.where((m) => m['type']?.toString().toLowerCase() == 'document').length;
    
    // Calculer l'espace total utilisé
    final totalSize = _mediaService.mediaList.fold<int>(0, (sum, media) => sum + (media['size'] as int? ?? 0));
    String formattedTotalSize;
    if (totalSize < 1024 * 1024) {
      formattedTotalSize = '${(totalSize / 1024).toStringAsFixed(1)} Ko';
    } else if (totalSize < 1024 * 1024 * 1024) {
      formattedTotalSize = '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} Mo';
    } else {
      formattedTotalSize = '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} Go';
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total médias', mediaCount.toString(), Icons.perm_media),
          _buildStatCard('Images', imagesCount.toString(), Icons.image),
          _buildStatCard('Documents', documentsCount.toString(), Icons.description),
          _buildStatCard('Espace utilisé', formattedTotalSize, Icons.storage),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 32),
        SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
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
                  'Médiathèque',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Télécharger un média'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _uploadNewMedia,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildMediaStats(),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMedia.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 64, color: Colors.grey.shade400),
                              SizedBox(height: 16),
                              Text(
                                'Aucun média trouvé',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un média'),
                                onPressed: _uploadNewMedia,
                              ),
                            ],
                          ),
                        )
                      : _buildMediaGrid(),
            ),
          ],
        ),
      ),
    );
  }
} 