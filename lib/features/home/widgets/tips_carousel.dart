import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TipsCarousel extends StatefulWidget {
  const TipsCarousel({super.key});

  @override
  State<TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends State<TipsCarousel> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

  final List<Map<String, dynamic>> _ecoTips = [
    {
      'title': 'Économisez l\'eau',
      'description': 'Prenez des douches plus courtes et fermez le robinet pendant le brossage des dents pour économiser jusqu\'à 200 litres d\'eau par semaine.',
      'icon': Icons.water_drop,
      'color': Colors.blue,
    },
    {
      'title': 'Réduisez vos déchets',
      'description': 'Utilisez des sacs réutilisables et évitez les produits à usage unique pour diminuer votre empreinte écologique.',
      'icon': Icons.delete_outline,
      'color': Colors.green,
    },
    {
      'title': 'Économisez l\'énergie',
      'description': 'Éteignez les lumières et débranchez les appareils électroniques lorsqu\'ils ne sont pas utilisés.',
      'icon': Icons.bolt,
      'color': Colors.amber,
    },
    {
      'title': 'Mangez local',
      'description': 'Achetez des produits locaux et de saison pour réduire les émissions liées au transport des aliments.',
      'icon': Icons.eco,
      'color': Colors.lightGreen,
    },
    {
      'title': 'Compostez',
      'description': 'Transformez vos déchets organiques en compost pour enrichir votre jardin et réduire les déchets.',
      'icon': Icons.compost,
      'color': Colors.brown,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Conseils Écologiques',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: _ecoTips.length,
          itemBuilder: (context, index, realIndex) {
            return _buildTipCard(_ecoTips[index]);
          },
          options: CarouselOptions(
            height: 220,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: _ecoTips.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Theme.of(context).primaryColor,
            dotColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: tip['color'].withOpacity(0.2),
                  child: Icon(
                    tip['icon'],
                    color: tip['color'],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tip['description'],
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  // Naviguer vers la page détaillée du conseil
                },
                child: const Text('En savoir plus'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 