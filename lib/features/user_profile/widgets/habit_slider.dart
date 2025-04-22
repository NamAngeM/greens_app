import 'package:flutter/material.dart';

class HabitSlider extends StatelessWidget {
  final String title;
  final String description;
  final double value;
  final ValueChanged<double> onChanged;
  final List<String> labels;

  const HabitSlider({
    Key? key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        
        const SizedBox(height: 8),
        
        // Description
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        
        const SizedBox(height: 16),
        
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: labels.length - 1.0,
            divisions: labels.length - 1,
            onChanged: onChanged,
          ),
        ),
        
        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((label) => Text(label)).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Valeur sélectionnée
        Center(
          child: Text(
            labels[value.round()],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
} 