import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:data_table_2/data_table_2.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({Key? key}) : super(key: key);

  @override
  _AdminUserManagementState createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  String _filterRole = 'Tous';
  String _sortBy = 'dateCreation';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
      
      setState(() {
        _users = userSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'email': data['email'] ?? 'Non défini',
            'displayName': data['displayName'] ?? 'Utilisateur',
            'role': data['role'] ?? 'utilisateur',
            'dateCreation': data['dateCreation']?.toDate() ?? DateTime.now(),
            'lastLogin': data['lastLogin']?.toDate(),
            'carbonFootprint': data['carbonFootprint'] ?? 0.0,
            'completedChallenges': data['completedChallenges'] ?? 0,
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          user['displayName'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesRole = _filterRole == 'Tous' || user['role'] == _filterRole.toLowerCase();
      
      return matchesSearch && matchesRole;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'dateCreation') {
          return _sortAscending 
              ? a['dateCreation'].compareTo(b['dateCreation']) 
              : b['dateCreation'].compareTo(a['dateCreation']);
        } else if (_sortBy == 'email') {
          return _sortAscending 
              ? a['email'].toString().compareTo(b['email'].toString())
              : b['email'].toString().compareTo(a['email'].toString());
        } else if (_sortBy == 'role') {
          return _sortAscending 
              ? a['role'].toString().compareTo(b['role'].toString())
              : b['role'].toString().compareTo(a['role'].toString());
        }
        return 0;
      });
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isActive': !currentStatus,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut utilisateur mis à jour'))
      );
      
      _loadUsers();
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du statut'))
      );
    }
  }

  Future<void> _changeUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole.toLowerCase(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rôle utilisateur mis à jour'))
      );
      
      _loadUsers();
    } catch (e) {
      print('Erreur lors de la mise à jour du rôle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du rôle'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Utilisateurs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildUserStats(),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUsersTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _filterRole,
                items: const [
                  DropdownMenuItem(value: 'Tous', child: Text('Tous les rôles')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'moderateur', child: Text('Modérateur')),
                  DropdownMenuItem(value: 'utilisateur', child: Text('Utilisateur')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterRole = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Trier par',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'dateCreation', child: Text('Date d\'inscription')),
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'role', child: Text('Rôle')),
                ],
                onChanged: (value) {
                  setState(() {
                    if (_sortBy == value) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortBy = value!;
                      _sortAscending = true;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _loadUsers,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((user) => user['isActive'] == true).length;
    final adminUsers = _users.where((user) => user['role'] == 'admin').length;
    final moderatorUsers = _users.where((user) => user['role'] == 'moderateur').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Utilisateurs',
            '$totalUsers',
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Utilisateurs Actifs',
            '$activeUsers',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Administrateurs',
            '$adminUsers',
            Icons.admin_panel_settings,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Modérateurs',
            '$moderatorUsers',
            Icons.security,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          columns: [
            DataColumn2(
              label: const Text('Utilisateur'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: const Text('Email'),
            ),
            DataColumn(
              label: const Text('Rôle'),
            ),
            DataColumn(
              label: const Text('Inscription'),
            ),
            DataColumn(
              label: const Text('Statut'),
            ),
            DataColumn(
              label: const Text('Actions'),
            ),
          ],
          rows: _filteredUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          user['displayName'].toString().isNotEmpty 
                              ? user['displayName'].toString()[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(user['displayName']),
                    ],
                  ),
                ),
                DataCell(Text(user['email'].toString())),
                DataCell(
                  DropdownButton<String>(
                    value: user['role'],
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'utilisateur', child: Text('Utilisateur')),
                      DropdownMenuItem(value: 'moderateur', child: Text('Modérateur')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (newValue) {
                      _changeUserRole(user['id'], newValue!);
                    },
                  ),
                ),
                DataCell(
                  Text(
                    '${user['dateCreation'].day}/${user['dateCreation'].month}/${user['dateCreation'].year}',
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['isActive'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user['isActive'] ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        color: user['isActive'] ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          user['isActive'] ? Icons.block : Icons.check_circle,
                          color: user['isActive'] ? Colors.red : Colors.green,
                        ),
                        tooltip: user['isActive'] ? 'Désactiver' : 'Activer',
                        onPressed: () {
                          _toggleUserStatus(user['id'], user['isActive']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'Voir le profil',
                        onPressed: () {
                          _showUserDetails(user);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Profil de ${user['displayName']}'),
        content: Container(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user['email']),
              ),
              ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Rôle'),
                subtitle: Text(user['role']),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date d\'inscription'),
                subtitle: Text('${user['dateCreation'].day}/${user['dateCreation'].month}/${user['dateCreation'].year}'),
              ),
              if (user['lastLogin'] != null)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Dernière connexion'),
                  subtitle: Text('${user['lastLogin'].day}/${user['lastLogin'].month}/${user['lastLogin'].year}'),
                ),
              ListTile(
                leading: const Icon(Icons.eco),
                title: const Text('Empreinte carbone'),
                subtitle: Text('${user['carbonFootprint'].toStringAsFixed(2)} t CO2'),
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('Défis complétés'),
                subtitle: Text('${user['completedChallenges']}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Fermer'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
} 