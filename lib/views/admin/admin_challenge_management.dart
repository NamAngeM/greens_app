import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greens_app/services/admin_service.dart';
import 'package:greens_app/models/eco_challenge.dart';

class AdminChallengeManagement extends StatefulWidget {
  const AdminChallengeManagement({Key? key}) : super(key: key);

  @override
  State<AdminChallengeManagement> createState() => _AdminChallengeManagementState();
}

class _AdminChallengeManagementState extends State<AdminChallengeManagement> {
  final AdminService _adminService = AdminService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<EcoChallenge> _challenges = [];
  String _searchQuery = '';
  String _filterCategory = 'Toutes';
  String _filterStatus = 'Tous';
  List<String> _categories = ['Toutes', 'Alimentation', 'Transport', 'Énergie', 'Déchets', 'Eau', 'Autre'];

  // Contrôleurs pour le formulaire d'ajout/édition
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  String _selectedCategory = 'Alimentation';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    try {
      final challenges = await _adminService.getChallenges();
      setState(() {
        _challenges = challenges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des défis: $e')),
        );
      }
    }
  }

  List<EcoChallenge> get _filteredChallenges {
    return _challenges.where((challenge) {
      final matchesSearch = 
          challenge.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          challenge.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _filterCategory == 'Toutes' || challenge.category == _filterCategory;
      
      final bool isActive = challenge.isActive;
      final bool matchesStatus = _filterStatus == 'Tous' || 
                              (_filterStatus == 'Actif' && isActive) || 
                              (_filterStatus == 'Inactif' && !isActive);
      
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Future<void> _createChallenge() async {
    _titleController.clear();
    _descriptionController.clear();
    _pointsController.clear();
    _selectedCategory = 'Alimentation';
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));
    _isActive = true;
    _imageUrl = null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau défi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Catégorie'),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Date de début'),
                      subtitle: Text(_formatDate(_startDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                            // Ensure end date is after start date
                            if (_endDate.isBefore(_startDate)) {
                              _endDate = _startDate.add(const Duration(days: 30));
                            }
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Date de fin'),
                      subtitle: Text(_formatDate(_endDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Actif'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickAndUploadImage,
                child: const Text('Ajouter une image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (_titleController.text.isEmpty || 
                  _descriptionController.text.isEmpty ||
                  _pointsController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                );
                return;
              }

              if (_endDate.isBefore(_startDate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La date de fin doit être après la date de début')),
                );
                return;
              }

              try {
                final challenge = EcoChallenge(
                  id: '', // The ID will be generated by Firestore
                  title: _titleController.text,
                  description: _descriptionController.text,
                  category: _selectedCategory,
                  points: int.parse(_pointsController.text),
                  startDate: _startDate,
                  endDate: _endDate,
                  isActive: _isActive,
                  imageUrl: _imageUrl,
                );

                await _adminService.createChallenge(challenge);
                if (mounted) {
                  Navigator.pop(context);
                  _loadChallenges();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Défi créé avec succès')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la création: $e')),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _editChallenge(EcoChallenge challenge) async {
    _titleController.text = challenge.title;
    _descriptionController.text = challenge.description;
    _pointsController.text = challenge.points.toString();
    _selectedCategory = challenge.category;
    _startDate = challenge.startDate;
    _endDate = challenge.endDate;
    _isActive = challenge.isActive;
    _imageUrl = challenge.imageUrl;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le défi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Catégorie'),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Date de début'),
                      subtitle: Text(_formatDate(_startDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                            // Ensure end date is after start date
                            if (_endDate.isBefore(_startDate)) {
                              _endDate = _startDate.add(const Duration(days: 30));
                            }
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Date de fin'),
                      subtitle: Text(_formatDate(_endDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Actif'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_imageUrl != null)
                Image.network(_imageUrl!, height: 100),
              ElevatedButton(
                onPressed: _pickAndUploadImage,
                child: const Text('Changer l\'image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (_titleController.text.isEmpty || 
                  _descriptionController.text.isEmpty ||
                  _pointsController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                );
                return;
              }

              if (_endDate.isBefore(_startDate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La date de fin doit être après la date de début')),
                );
                return;
              }

              try {
                final updatedChallenge = challenge.copyWith(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  category: _selectedCategory,
                  points: int.parse(_pointsController.text),
                  startDate: _startDate,
                  endDate: _endDate,
                  isActive: _isActive,
                  imageUrl: _imageUrl,
                );

                await _adminService.updateChallenge(challenge.id, updatedChallenge);
                if (mounted) {
                  Navigator.pop(context);
                  _loadChallenges();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Défi mis à jour avec succès')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
                  );
                }
              }
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChallenge(String challengeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le défi'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce défi ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _adminService.deleteChallenge(challengeId);
        if (mounted) {
          _loadChallenges();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Défi supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          // Read the image data
          final bytes = await pickedFile.readAsBytes();
          
          // Upload to Firebase Storage
          final ref = FirebaseStorage.instance
              .ref()
              .child('challenges')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
              
          final uploadTask = await ref.putData(
            bytes,
            SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'uploadedAt': DateTime.now().toIso8601String(),
              },
            ),
          );

          if (uploadTask.state == TaskState.success) {
            final downloadUrl = await uploadTask.ref.getDownloadURL();

            setState(() {
              _imageUrl = downloadUrl;
              _isLoading = false;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image téléchargée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            throw Exception('Échec de l\'upload de l\'image');
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors du téléchargement de l\'image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des défis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Rechercher',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
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
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _filterStatus,
                        items: const [
                          DropdownMenuItem(value: 'Tous', child: Text('Tous')),
                          DropdownMenuItem(value: 'Actif', child: Text('Actif')),
                          DropdownMenuItem(value: 'Inactif', child: Text('Inactif')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = _filteredChallenges[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: challenge.imageUrl != null
                              ? Image.network(challenge.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.emoji_events),
                          title: Text(challenge.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(challenge.description),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(challenge.category),
                                    backgroundColor: Colors.green.withOpacity(0.1),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text('${challenge.points} points'),
                                    backgroundColor: Colors.blue.withOpacity(0.1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editChallenge(challenge),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteChallenge(challenge.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChallenge,
        child: const Icon(Icons.add),
      ),
    );
  }
} 