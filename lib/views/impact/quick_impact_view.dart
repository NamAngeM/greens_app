import 'package:flutter/material.dart';

class QuickImpactView extends StatelessWidget {
  const QuickImpactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Rapide'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flash_on,
                size: 100,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              const Text(
                'Actions à impact rapide',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cette section vous permettra de découvrir et d\'enregistrer des actions écologiques quotidiennes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité disponible prochainement'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une action'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 