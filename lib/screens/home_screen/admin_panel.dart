import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/setting_categories.dart/services/user_payment_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness/controller/auth_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness/setting_categories.dart/services/firestore_services.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();

  bool _isAscending = true;
  String _searchTerm = '';

  late Future<List<UserPaymentDetails>> _usersPaymentDetails;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _fetchUsers();
    _usersPaymentDetails = _fetchPaidUsersPaymentDetails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    bool isAdmin = await _authController.isUserAdmin();
    if (!mounted) return;
    print('Is user admin on admin page: $isAdmin');
    if (!isAdmin ||
        _authController.currentUser?.email != 'chaudharysaba898@gmail.com') {
      Get.offAllNamed('/home');
      Get.snackbar('Access Denied', 'You do not have admin privileges.');
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('data').get();
      if (!mounted) return;
      setState(() {
        filteredUsers = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "name": data["name"] ?? 'Unknown',
            "email": data["email"] ?? 'Unknown',
            "age": data["age"]?.toString() ?? 'Unknown',
            "gender": data["gender"] ?? 'Unknown',
            "height": data["height"]?.toString() ?? 'Unknown',
            "weight": data["weight"]?.toString() ?? 'Unknown',
            "goal": data["goal"] ?? 'Unknown',
            "activity": data["activity_level"] ?? 'Unknown'
          };
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  void _filterUsers(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm.toLowerCase();
      filteredUsers = filteredUsers
          .where((user) =>
              user["name"]!.toLowerCase().contains(_searchTerm) ||
              user["email"]!.toLowerCase().contains(_searchTerm))
          .toList();
    });
  }

  void _sortUsers(String key) {
    setState(() {
      _isAscending = !_isAscending;
      filteredUsers.sort((a, b) {
        int compare = a[key]!.toString().compareTo(b[key]!.toString());
        return _isAscending ? compare : -compare;
      });
    });
  }

  void _exportUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User list exported as CSV (Mock)')),
    );
  }

  Future<void> _addUser() async {
    final newUser = {
      "name": _nameController.text,
      "email": _emailController.text,
      "age": int.tryParse(_ageController.text) ?? 0,
      "gender": _genderController.text,
      "height": double.tryParse(_heightController.text) ?? 0.0,
      "weight": double.tryParse(_weightController.text) ?? 0.0,
      "goal": _goalController.text,
      "activity_level": _activityController.text,
    };
    try {
      await _firestore.collection('data').add(newUser);
      _fetchUsers();
      _clearControllers();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding user: $e')),
      );
    }
  }

  Future<void> _editUser(String docId) async {
    final updatedUser = {
      "name": _nameController.text,
      "email": _emailController.text,
      "age": int.tryParse(_ageController.text) ?? 0,
      "gender": _genderController.text,
      "height": double.tryParse(_heightController.text) ?? 0.0,
      "weight": double.tryParse(_weightController.text) ?? 0.0,
      "goal": _goalController.text,
      "activity_level": _activityController.text,
    };
    try {
      await _firestore.collection('data').doc(docId).update(updatedUser);
      _fetchUsers();
      _clearControllers();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }

  Future<void> _deleteUser(String docId) async {
    try {
      await _firestore.collection('data').doc(docId).delete();
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  void _showUserDialog({String? docId}) {
    if (docId != null) {
      final user = filteredUsers.firstWhere((user) => user["id"] == docId);
      _nameController.text = user["name"];
      _emailController.text = user["email"];
      _ageController.text = user["age"];
      _genderController.text = user["gender"];
      _heightController.text = user["height"];
      _weightController.text = user["weight"];
      _goalController.text = user["goal"];
      _activityController.text = user["activity"];
    } else {
      _clearControllers();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Add User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: _heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Height'),
              ),
              TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight'),
              ),
              TextField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: 'Goal'),
              ),
              TextField(
                controller: _activityController,
                decoration: const InputDecoration(labelText: 'Activity'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: Color.fromARGB(255, 196, 176, 175))),
          ),
          ElevatedButton(
            onPressed: () {
              if (docId == null) {
                _addUser();
              } else {
                _editUser(docId);
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 182, 241, 174),
              backgroundColor: Colors.blue,
            ),
            child: Text(docId == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
    _genderController.clear();
    _heightController.clear();
    _weightController.clear();
    _goalController.clear();
    _activityController.clear();
  }

  Widget _buildAgeDistributionChart() {
    Map<String, int> ageGroups = {
      '0-20': 0,
      '21-30': 0,
      '31-40': 0,
      '41-50': 0,
      '51+': 0
    };

    for (var user in filteredUsers) {
      int age = int.tryParse(user['age']) ?? 0;
      if (age <= 20) {
        ageGroups['0-20'] = (ageGroups['0-20'] ?? 0) + 1;
      } else if (age <= 30)
        ageGroups['21-30'] = (ageGroups['21-30'] ?? 0) + 1;
      else if (age <= 40)
        ageGroups['31-40'] = (ageGroups['31-40'] ?? 0) + 1;
      else if (age <= 50)
        ageGroups['41-50'] = (ageGroups['41-50'] ?? 0) + 1;
      else
        ageGroups['51+'] = (ageGroups['51+'] ?? 0) + 1;
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: ageGroups.values.reduce((a, b) => a > b ? a : b).toDouble(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(ageGroups.keys.elementAt(value.toInt())),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: true)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          barGroups: ageGroups.entries.map((entry) {
            return BarChartGroupData(
              x: ageGroups.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: const Color.fromARGB(255, 30, 192, 36))
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityLevelChart() {
    Map<String, int> activityLevels = {};

    for (var user in filteredUsers) {
      String activity = user['activity'] ?? 'Unknown';
      activityLevels[activity] = (activityLevels[activity] ?? 0) + 1;
    }

    List<Color> customColors = [
      const Color.fromARGB(255, 228, 147, 141),
      const Color.fromARGB(255, 159, 203, 240),
      const Color.fromARGB(255, 137, 217, 140),
      const Color.fromARGB(255, 205, 176, 238),
      const Color.fromARGB(255, 237, 173, 214),
    ];

    return SizedBox(
      height: 300, // Adjust height as needed
      child: PieChart(
        PieChartData(
          sections: activityLevels.entries.map((entry) {
            return PieChartSectionData(
              color: customColors[
                  activityLevels.keys.toList().indexOf(entry.key) %
                      customColors.length],
              value: entry.value.toDouble(),
              title: '${entry.key}\n${entry.value}', // Consider reducing font size
              radius: 70, // Adjust radius for better spacing
              titleStyle: const TextStyle(
                  fontSize: 10, // Reduce font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            );
          }).toList(),
          sectionsSpace: 0,
          centerSpaceRadius: 40, // Increase center space radius
        ),
      ),
    );
  }

  Widget _buildGoalChart() {
    Map<String, int> goalCounts = {};

    for (var user in filteredUsers) {
      String goal = user['goal'] ?? 'Unknown';
      goalCounts[goal] = (goalCounts[goal] ?? 0) + 1;
    }

    // Define your custom colors
    List<Color> customColors = [
      const Color.fromARGB(255, 228, 147, 141),
      const Color.fromARGB(255, 159, 203, 240),
      const Color.fromARGB(255, 137, 217, 140),
      const Color.fromARGB(255, 205, 176, 238),
      const Color.fromARGB(255, 237, 173, 214),
    ];

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: goalCounts.entries.map((entry) {
            return PieChartSectionData(
              color: customColors[goalCounts.keys.toList().indexOf(entry.key) %
                  customColors.length],
              value: entry.value.toDouble(),
              title: '${entry.key}\n${entry.value}', // Display goal and count
              radius: 100,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            );
          }).toList(),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildHeightChart() {
    // Fixed Y-axis limits
    const double minY = 0;
    const double maxY = 7; // Adjust this based on your expected maximum

    Map<String, double> heightCounts = {};
    for (var user in filteredUsers) {
      String height = (double.tryParse(user['height']) ?? 0.0).toString();
      heightCounts[height] = (heightCounts[height] ?? 0) + 1;
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY, // Set fixed maxY for height
          minY: minY,
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          barGroups: heightCounts.entries.map((entry) {
            return BarChartGroupData(
              x: int.parse(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.purple,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    // Fixed Y-axis limits
    const double minY = 0;
    const double maxY = 7; // Adjust this based on your expected maximum

    Map<String, double> weightCounts = {};
    for (var user in filteredUsers) {
      String weight = (double.tryParse(user['weight']) ?? 0.0).toString();
      weightCounts[weight] = (weightCounts[weight] ?? 0) + 1;
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY, // Set fixed maxY for weight
          minY: minY,
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          barGroups: weightCounts.entries.map((entry) {
            return BarChartGroupData(
              x: int.parse(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.green,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsTable() {
    return FutureBuilder<List<UserPaymentDetails>>(
      future: _usersPaymentDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error in FutureBuilder: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No data in snapshot or empty data');
          return const Center(child: Text('No paid users found'));
        } else {
          print('Number of users in snapshot: ${snapshot.data!.length}');
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Plan')),
                DataColumn(label: Text('Price')),
              //  DataColumn(label: Text('Start Date')),
              //  DataColumn(label: Text('End Date')),
              ],
              rows: snapshot.data!.map((user) {
                return DataRow(cells: [
                  DataCell(Text(user.name ?? 'Unknown')),
                  DataCell(Text(user.email ?? 'No email')),
                  DataCell(Text(user.currentPlan ?? 'No plan')),
                  DataCell(Text(user.price.toString())),
                //  DataCell(Text(_formatTimestamp(user.subscriptionDetails['startDate']))),
                 // DataCell(Text(_formatTimestamp(user.subscriptionDetails['endDate']))),
                ]);
              }).toList(),
            ),
          );
        }
      },
    );
  }

  Future<List<UserPaymentDetails>> _fetchPaidUsersPaymentDetails() async {
    try {
      final paidUsers = await FirestoreService().fetchPaidUsers();
      return paidUsers;
    } catch (e) {
      print('Error fetching paid users payment details: $e');
      return [];
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is String && timestamp.startsWith('Timestamp')) {
      // Extract seconds from the string
      final seconds = int.tryParse(timestamp.split('seconds=')[1].split(',')[0]);
      if (seconds != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        return DateFormat('yyyy-MM-dd').format(date);
      }
    }
    return 'Invalid Date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/bottomNavigationbar');
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 135, 94),
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color.fromARGB(255, 178, 213, 230),
            child: IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.black,
              ),
              onPressed: () async {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 3, 245, 169).withOpacity(0.1),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search,
                            color: Color.fromARGB(255, 3, 245, 213)),
                      ),
                      onChanged: _filterUsers,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 134, 3, 248),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showUserDialog(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 181, 132),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _exportUsers,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Age Distribution',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildAgeDistributionChart(),
                  const SizedBox(height: 24),
                  const Text('Activity Levels',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildActivityLevelChart(),
                  const SizedBox(height: 24),
                  const Text('Goal Distribution',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildGoalChart(),
                  const SizedBox(height: 24),
                  const Text('Height Distribution',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildHeightChart(),
                  const SizedBox(height: 24),
                  const Text('Weight Distribution',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildWeightChart(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: _isAscending,
                sortColumnIndex: 0,
                headingRowColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 144, 245, 181)
                        .withOpacity(0.1)),
                columns: const [
                  DataColumn(
                      label: Text('Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black))),
                  DataColumn(
                      label: Text('Email',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Age',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Gender',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Height',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Weight',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Goal',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Activity',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Actions',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: filteredUsers.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user["name"])),
                      DataCell(Text(user["email"])),
                      DataCell(Text(user["age"])),
                      DataCell(Text(user["gender"])),
                      DataCell(Text(user["height"])),
                      DataCell(Text(user["weight"])),
                      DataCell(Text(user["goal"])),
                      DataCell(Text(user["activity"])),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color.fromARGB(255, 5, 228, 113)),
                            onPressed: () =>
                                _showUserDialog(docId: user["id"]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color.fromARGB(255, 16, 16, 16)),
                            onPressed: () => _deleteUser(user["id"]),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Payment Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildPaymentDetailsTable(),
          ],
        ),
      ),
    );
  }
}