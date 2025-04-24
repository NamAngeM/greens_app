import 'package:flutter/material.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/utils/app_colors.dart';

class ArticleView extends StatefulWidget {
  const ArticleView({Key? key}) : super(key: key);

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  String _selectedCategory = 'All';
  final List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _initializeArticles();
  }

  void _initializeArticles() {
    _articles.addAll([
      Article(
        title: '5 easy steps to go green today',
        category: 'Ecology',
        readTime: 20,
        imageAsset: 'assets/images/articles/ocean_sunset.jpg',
        content: '''
# 5 Easy Steps to Go Green Today

Going green doesn't have to be complicated or expensive. Here are five simple steps you can take today to make a positive impact on the environment.

## 1. Reduce Single-Use Plastics

Replace plastic water bottles with a reusable water bottle. Bring your own shopping bags to the grocery store. Say no to plastic straws and utensils.

## 2. Save Energy at Home

Turn off lights when you leave a room. Unplug electronics when not in use. Adjust your thermostat to use less heating and cooling.

## 3. Eat More Plant-Based Meals

Try having one meat-free day per week. Explore delicious plant-based recipes and gradually increase your consumption of fruits, vegetables, and whole grains.

## 4. Conserve Water

Take shorter showers. Fix leaky faucets. Water your plants during cooler parts of the day to minimize evaporation.

## 5. Support Eco-Friendly Businesses

Research and support companies that prioritize sustainability. Your purchasing power can drive positive change in the marketplace.

Remember, small actions add up to make a big difference!
''',
      ),
      Article(
        title: 'Eco hacks for daily life',
        category: 'Waste',
        readTime: 15,
        imageAsset: 'assets/images/articles/eco_daily.jpg',
        content: '''
# Eco Hacks for Daily Life

Incorporate these simple eco-friendly hacks into your daily routine to reduce waste and live more sustainably.

## Kitchen Hacks

- Use cloth napkins instead of paper towels
- Create a compost bin for food scraps
- Store food in glass containers instead of plastic
- Make your own cleaning solutions with vinegar and baking soda

## Bathroom Hacks

- Switch to bamboo toothbrushes
- Try shampoo and conditioner bars
- Use a safety razor instead of disposable razors
- Install a low-flow showerhead

## Shopping Hacks

- Bring reusable produce bags to the grocery store
- Buy in bulk to reduce packaging waste
- Shop at local farmers' markets
- Repair items instead of replacing them

## Transportation Hacks

- Walk or bike for short trips
- Combine errands to reduce driving
- Maintain your vehicle for optimal fuel efficiency
- Consider carpooling or public transportation

These small changes can make a big impact on reducing your environmental footprint!
''',
      ),
      Article(
        title: 'The future of sustainable fashion',
        category: 'Fashion',
        readTime: 18,
        imageAsset: 'assets/images/articles/sustainable_fashion.jpg',
        content: '''
# The Future of Sustainable Fashion

The fashion industry is undergoing a transformation as consumers and brands alike prioritize sustainability. Here's what the future holds for eco-friendly fashion.

## Innovative Materials

Designers are exploring materials made from agricultural waste, recycled plastics, and even lab-grown fabrics. Companies are developing leather alternatives from mushrooms, pineapple leaves, and apple peels.

## Circular Fashion Economy

The linear "take-make-dispose" model is being replaced by a circular approach where clothes are designed to be reused, repaired, and recycled. Rental and resale platforms are growing in popularity.

## Transparent Supply Chains

Brands are increasingly sharing information about their manufacturing processes, working conditions, and environmental impact. Blockchain technology is being used to verify sustainability claims.

## Slow Fashion Movement

Consumers are moving away from fast fashion and embracing quality garments that last longer. Capsule wardrobes and timeless designs are replacing trend-driven purchases.

## Consumer Education

As awareness grows, shoppers are learning to recognize greenwashing and demand genuine sustainability efforts from brands. Education about proper garment care is extending the life of clothing.

The path to truly sustainable fashion requires collaboration between designers, manufacturers, retailers, and consumers. Together, we can create a fashion industry that values both style and environmental responsibility.
''',
      ),
      Article(
        title: 'Understanding carbon footprints',
        category: 'Ecology',
        readTime: 25,
        imageAsset: 'assets/images/articles/carbon_footprint.jpg',
        content: '''
# Understanding Carbon Footprints

A carbon footprint measures the total greenhouse gas emissions caused directly and indirectly by an individual, organization, event, or product. Here's what you need to know about carbon footprints and how to reduce yours.

## What Makes Up Your Carbon Footprint?

- **Transportation**: Driving, flying, and public transit
- **Home Energy**: Electricity, heating, and cooling
- **Food**: Production, processing, and transportation of food
- **Consumption**: Goods and services you purchase
- **Waste**: Disposal of items you discard

## Calculating Your Carbon Footprint

Several online calculators can help you estimate your personal carbon footprint. These tools typically ask questions about your lifestyle, travel habits, diet, and consumption patterns.

## Strategies to Reduce Your Carbon Footprint

### Transportation
- Walk, bike, or use public transportation when possible
- Combine trips to reduce driving
- Consider an electric or hybrid vehicle for your next car

### Home Energy
- Switch to renewable energy sources
- Improve home insulation
- Use energy-efficient appliances

### Food Choices
- Reduce meat consumption, especially beef
- Buy local and seasonal produce
- Minimize food waste

### Consumption
- Buy less and choose quality items that last
- Repair rather than replace
- Support companies with sustainable practices

### Waste Management
- Recycle and compost
- Avoid single-use items
- Donate or sell unwanted items

## Carbon Offsets

Carbon offsets allow you to compensate for your emissions by funding projects that reduce greenhouse gas emissions elsewhere. These might include renewable energy, reforestation, or methane capture projects.

Understanding and reducing your carbon footprint is an important step in combating climate change. Every action counts!
''',
      ),
      Article(
        title: 'Water conservation at home',
        category: 'Waste',
        readTime: 12,
        imageAsset: 'assets/images/articles/water_conservation.jpg',
        content: '''
# Water Conservation at Home

Water is a precious resource, and conserving it at home is easier than you might think. These simple strategies can help you reduce your water usage and save money on your utility bills.

## In the Bathroom

- Fix leaky faucets and toilets promptly
- Install low-flow showerheads and faucet aerators
- Take shorter showers (aim for 5 minutes or less)
- Turn off the water while brushing your teeth or shaving
- Install a dual-flush toilet or place a displacement device in your tank

## In the Kitchen

- Run the dishwasher only when full
- Keep a pitcher of drinking water in the refrigerator instead of running the tap
- Thaw food in the refrigerator, not under running water
- Use a basin when washing dishes by hand
- Collect and reuse the water used for rinsing fruits and vegetables

## Laundry Room

- Wash full loads of laundry
- Adjust the water level to match the size of the load
- Consider upgrading to a high-efficiency washing machine

## Outdoor Water Use

- Water your garden in the early morning or evening to reduce evaporation
- Use drip irrigation or soaker hoses instead of sprinklers
- Collect rainwater for garden use
- Choose native, drought-resistant plants for your landscape
- Use a broom instead of a hose to clean driveways and sidewalks

## Detect and Fix Leaks

A single leaky toilet can waste up to 200 gallons of water per day. Check for leaks regularly by:
- Adding food coloring to your toilet tank to see if it seeps into the bowl
- Reading your water meter before and after a two-hour period when no water is being used
- Inspecting faucets and pipe connections for leaks

By implementing these water conservation strategies, you can significantly reduce your water consumption and help protect this vital natural resource for future generations.
''',
      ),
    ]);
  }

  List<Article> get _filteredArticles {
    if (_selectedCategory == 'All') {
      return _articles;
    }
    return _articles.where((article) => article.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.article_outlined,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Découvrez nos articles",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CD964),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.eco_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Explore a green lifestyle',
                                style: const TextStyle(
                                  color: Color(0xFF4CD964),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () {
                            // Navigate to settings
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Our latest articles',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3140),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryFilter(),
                    const SizedBox(height: 20),
                    _buildArticlesList(),
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomMenu(currentIndex: 1),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryButton('All'),
          _categoryButton('Ecology'),
          _categoryButton('Waste'),
          _categoryButton('Fashion'),
        ],
      ),
    );
  }

  Widget _categoryButton(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CD964) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1F3140),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList() {
    return Column(
      children: [
        // First row with two articles side by side
        Row(
          children: [
            Expanded(
              child: _buildArticleCard(_filteredArticles.isNotEmpty ? _filteredArticles[0] : null, small: true),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildArticleCard(_filteredArticles.length > 1 ? _filteredArticles[1] : null, small: true),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Remaining articles in full width
        ..._filteredArticles.skip(2).map((article) => Column(
          children: [
            _buildArticleCard(article),
            const SizedBox(height: 20),
          ],
        )),
      ],
    );
  }

  Widget _buildArticleCard(Article? article, {bool small = false}) {
    if (article == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailView(article: article),
          ),
        );
      },
      child: Container(
        height: small ? 160 : 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(article.imageAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${article.readTime} Min',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    article.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: small ? 16 : 20,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class Article {
  final String title;
  final String category;
  final int readTime;
  final String imageAsset;
  final String content;

  Article({
    required this.title,
    required this.category,
    required this.readTime,
    required this.imageAsset,
    required this.content,
  });
}

class ArticleDetailView extends StatelessWidget {
  final Article article;

  const ArticleDetailView({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                article.imageAsset,
                fit: BoxFit.cover,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEFFF0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(
                            color: Color(0xFF4CD964),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${article.readTime} min read',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMarkdownContent(article.content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(String content) {
    // Simple markdown-like rendering
    final paragraphs = content.split('\n\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        if (paragraph.startsWith('# ')) {
          // H1 heading
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              paragraph.substring(2),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (paragraph.startsWith('## ')) {
          // H2 heading
          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0, top: 8.0),
            child: Text(
              paragraph.substring(3),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (paragraph.startsWith('- ')) {
          // Bullet point
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    paragraph.substring(2),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Regular paragraph
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              paragraph,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
      }).toList(),
    );
  }
}