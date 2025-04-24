import 'package:flutter/material.dart';

class LocalCommunityView extends StatelessWidget {
  const LocalCommunityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communauté Locale'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.people_alt_outlined,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 24),
            Text(
              'Fonctionnalité en développement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Cette section permettra de découvrir les\ninitiatives écologiques près de chez vous.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 