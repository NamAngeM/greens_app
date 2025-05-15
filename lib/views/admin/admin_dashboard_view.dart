import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/controllers/product_controller.dart';
import 'package:greens_app/controllers/article_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/services/eco_challenge_service.dart';
import 'package:greens_app/services/admin_auth_service.dart';
import 'package:greens_app/views/admin/admin_user_management.dart';
import 'package:greens_app/views/admin/admin_challenge_management.dart';
import 'package:greens_app/views/admin/admin_product_management.dart';
import 'package:greens_app/views/admin/admin_article_management.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:greens_app/views/admin/admin_media_management.dart';
import 'package:greens_app/services/admin_service.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;
  bool _isExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  
  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Tableau de bord', 'icon': Icons.dashboard},
    {'title': 'Utilisateurs', 'icon': Icons.people},
    {'title': 'Défis', 'icon': Icons.emoji_events},
    {'title': 'Produits', 'icon': Icons.shopping_bag},
    {'title': 'Articles', 'icon': Icons.article},
    {'title': 'Médiathèque', 'icon': Icons.perm_media},
    {'title': 'Paramètres', 'icon': Icons.settings},
    {'title': 'Aide', 'icon': Icons.help_outline},
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des statistiques: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord administrateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AdminAuthService().logoutAdmin();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/admin/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildRecentActivities(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStats,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Utilisateurs',
          _stats['totalUsers']?.toString() ?? '0',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Utilisateurs actifs',
          _stats['activeUsers']?.toString() ?? '0',
          Icons.person,
          Colors.green,
        ),
        _buildStatCard(
          'Défis',
          _stats['totalChallenges']?.toString() ?? '0',
          Icons.emoji_events,
          Colors.orange,
        ),
        _buildStatCard(
          'Défis actifs',
          _stats['activeChallenges']?.toString() ?? '0',
          Icons.flag,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, [String? change]) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
              ),
            ),
            if (change != null) ...[
              const SizedBox(height: 4),
              Text(
                change,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = _stats['recentActivities'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activités récentes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(activity['userName']?[0] ?? '?'),
              ),
              title: Text(activity['userName'] ?? 'Utilisateur inconnu'),
              subtitle: Text(activity['action'] ?? 'Action inconnue'),
              trailing: Text(
                _formatDate(activity['date']),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Administrateur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'admin@greensapp.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Tableau de bord'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Utilisateurs'),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.eco),
            title: const Text('Challenges'),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Produits'),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Articles'),
            selected: _selectedIndex == 4,
            onTap: () {
              setState(() {
                _selectedIndex = 4;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Statistiques'),
            selected: _selectedIndex == 5,
            onTap: () {
              setState(() {
                _selectedIndex = 5;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
                    ListTile(            leading: const Icon(Icons.logout),            title: const Text('Déconnexion'),            onTap: () async {              await AdminAuthService().logoutAdmin();              if (context.mounted) {                Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);              }            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Administration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(Icons.dashboard, 'Tableau de bord', 0),
                _buildNavItem(Icons.people, 'Utilisateurs', 1),
                _buildNavItem(Icons.eco, 'Challenges', 2),
                _buildNavItem(Icons.shopping_bag, 'Produits', 3),
                _buildNavItem(Icons.article, 'Articles', 4),
                _buildNavItem(Icons.analytics, 'Statistiques', 5),
                const Divider(),
                _buildNavItem(Icons.settings, 'Paramètres', 6),
                _buildNavItem(Icons.help, 'Aide', 7),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF4CAF50),
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrateur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'admin@greensapp.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                                IconButton(                  icon: const Icon(Icons.logout, size: 20),                  onPressed: () async {                    // Déconnecter l'utilisateur                    await AdminAuthService().logoutAdmin();                    if (context.mounted) {                      Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);                    }                  },                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildBody() {    switch (_selectedIndex) {      case 0:        return _buildDashboardPage();      case 1:        return const AdminUserManagement();      case 2:        return const AdminChallengeManagement();      case 3:        return const AdminProductManagement();      case 4:        return const AdminArticleManagement();      case 5:        return const AdminMediaManagement();      case 6:        return _buildSettingsPage();      case 7:        return _buildHelpPage();      default:        return _buildDashboardPage();    }  }

  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bienvenue sur votre tableau de bord',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Exporter les données'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Exporter les données
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Utilisateurs',
                  '12,543',
                  '+12.5%',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Produits référencés',
                  '5,782',
                  '+7.2%',
                  Icons.shopping_bag,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Challenges actifs',
                  '87',
                  '+4.9%',
                  Icons.eco,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Articles publiés',
                  '328',
                  '+2.3%',
                  Icons.article,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
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
                            const Text(
                              'Évolution des utilisateurs',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: 'Mois précédent',
                              onChanged: (String? newValue) {
                                // Changer la période
                              },
                              items: <String>['Semaine précédente', 'Mois précédent', 'Année précédente']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      String text = value.toInt().toString();
                                      return Text(text);
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) {
                                      const texts = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
                                      if (value.toInt() < 0 || value.toInt() >= texts.length) {
                                        return const Text('');
                                      }
                                      return Text(texts[value.toInt()]);
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    const FlSpot(0, 3),
                                    const FlSpot(1, 2),
                                    const FlSpot(2, 5),
                                    const FlSpot(3, 3.1),
                                    const FlSpot(4, 4),
                                    const FlSpot(5, 3),
                                    const FlSpot(6, 4),
                                    const FlSpot(7, 4.5),
                                    const FlSpot(8, 5),
                                    const FlSpot(9, 5.5),
                                    const FlSpot(10, 6.5),
                                    const FlSpot(11, 7),
                                  ],
                                  isCurved: true,
                                  color: const Color(0xFF4CAF50),
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Répartition des utilisateurs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.blue,
                                  value: 35,
                                  title: '35%',
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.orange,
                                  value: 25,
                                  title: '25%',
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: 20,
                                  title: '20%',
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.purple,
                                  value: 20,
                                  title: '20%',
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLegendItem('Par tranche d\'âge', [
                          LegendItemData('18-24 ans', Colors.blue, '35%'),
                          LegendItemData('25-34 ans', Colors.orange, '25%'),
                          LegendItemData('35-44 ans', Colors.green, '20%'),
                          LegendItemData('45+ ans', Colors.purple, '20%'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
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
                      const Text(
                        'Dernières activités',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualiser'),
                        onPressed: () {
                          // Actualiser les données
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      columns: const [
                        DataColumn2(
                          label: Text('Utilisateur'),
                          size: ColumnSize.L,
                        ),
                        DataColumn(
                          label: Text('Action'),
                        ),
                        DataColumn(
                          label: Text('Date'),
                        ),
                        DataColumn(
                          label: Text('Statut'),
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        10,
                        (index) => DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.primaries[index % Colors.primaries.length],
                                    child: Text(
                                      'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Utilisateur ${index + 1}'),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(['S\'est inscrit', 'A partagé un article', 'A terminé un challenge', 'A scanné un produit', 'A ajouté un commentaire'][index % 5]),
                            ),
                            DataCell(
                              Text('${DateTime.now().day - index}/${DateTime.now().month}/2023'),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: [Colors.green, Colors.orange, Colors.blue][index % 3].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ['Complété', 'En cours', 'Nouveau'][index % 3],
                                  style: TextStyle(
                                    color: [Colors.green, Colors.orange, Colors.blue][index % 3],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, List<LegendItemData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.label),
                  const Spacer(),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Pages de gestion
  Widget _buildUsersPage() {
    return const Center(
      child: Text('Gestion des utilisateurs - Page à implémenter'),
    );
  }

  Widget _buildChallengesPage() {
    return const Center(
      child: Text('Gestion des challenges - Page à implémenter'),
    );
  }

  Widget _buildProductsPage() {
    return const Center(
      child: Text('Gestion des produits - Page à implémenter'),
    );
  }

  Widget _buildArticlesPage() {
    return const Center(
      child: Text('Gestion des articles - Page à implémenter'),
    );
  }

  Widget _buildStatsPage() {
    return const Center(
      child: Text('Statistiques - Page à implémenter'),
    );
  }

  Widget _buildSettingsPage() {
    return const Center(
      child: Text('Paramètres - Page à implémenter'),
    );
  }

  Widget _buildHelpPage() {
    return const Center(
      child: Text('Aide - Page à implémenter'),
    );
  }
}

class LegendItemData {
  final String label;
  final Color color;
  final String value;

  LegendItemData(this.label, this.color, this.value);
} 