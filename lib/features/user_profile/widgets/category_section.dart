import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final IconData iconData;
  final String description;
  final List<Widget> children;

  const CategorySection({
    Key? key,
    required this.title,
    required this.iconData,
    required this.description,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre avec icône
        Row(
          children: [
            Icon(
              iconData,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Description
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
        ),
        
        const SizedBox(height: 24),
        
        // Contenu
        ...children,
      ],
    );
  }
} 