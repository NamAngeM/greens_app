import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/social_feed_controller.dart';
import 'package:greens_app/widgets/app_bar_with_back_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  
  List<String> _tags = [];
  File? _image;
  PostCategory _selectedCategory = PostCategory.tips;
  
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }
  
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithBackButton(
        title: 'Créer une publication',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Titre (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              
              // Contenu
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Écrivez votre post ici...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez écrire du contenu pour votre post';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Catégorie
              const Text(
                'Catégorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PostCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: PostCategory.tips,
                    child: _buildCategoryMenuItem(Icons.lightbulb, 'Astuces écologiques'),
                  ),
                  DropdownMenuItem(
                    value: PostCategory.achievements,
                    child: _buildCategoryMenuItem(Icons.emoji_events, 'Réalisations'),
                  ),
                  DropdownMenuItem(
                    value: PostCategory.questions,
                    child: _buildCategoryMenuItem(Icons.help, 'Questions'),
                  ),
                  DropdownMenuItem(
                    value: PostCategory.products,
                    child: _buildCategoryMenuItem(Icons.shopping_bag, 'Produits'),
                  ),
                  DropdownMenuItem(
                    value: PostCategory.events,
                    child: _buildCategoryMenuItem(Icons.event, 'Événements'),
                  ),
                ],
                onChanged: (PostCategory? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Image
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Ajouter une image'),
                    ),
                  ),
                  if (_image != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _image = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              if (_image != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _image!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              
              // Tags
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un tag',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: AppColors.primaryColor,
                    onPressed: _addTag,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryMenuItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
  
  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // Simuler la création d'un post
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post publié avec succès!')),
      );
      
      // Si implémenté avec une API, on enverrait les données du post ici
      
      Navigator.pop(context);
    }
  }
} 