import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_services.dart';

class SleepTrackerHome extends StatefulWidget {
  const SleepTrackerHome({super.key});

  @override
  _SleepTrackerHomeState createState() => _SleepTrackerHomeState();
}

class _SleepTrackerHomeState extends State<SleepTrackerHome> {
  final List<SleepData> sleepHistory = [];

  DateTime bedtime = DateTime.now().subtract(const Duration(hours: 8));
  DateTime wakeTime = DateTime.now();

  String userName = ''; // Variable to store user name
  String userEmail = ''; // Variable to store user email

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data
    _fetchSleepData(); // Fetch sleep data from Firestore
  }

  void _fetchUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';
      DocumentSnapshot userDoc = await FirestoreService().getUserData(userId);
      
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name']; // Store user name
          userEmail = userDoc['email']; // Store user email
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _fetchSleepData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId'; // Get actual user ID
      List<Map<String, dynamic>> fetchedData = await FirestoreService().getSleepData(userId);
      List<SleepData> sleepDataList = fetchedData.map((data) => SleepData.fromMap(data)).toList();
      if (mounted) {
        setState(() {
          sleepHistory.clear();
          sleepHistory.addAll(sleepDataList);
        });
      }
    } catch (e) {
      print('Error fetching sleep data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 213, 222),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 91, 220, 158),
        title: const Text('Sleep Tracker',style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSleepSummary(),
              const SizedBox(height: 24),
              _buildSleepHistory(),
              const SizedBox(height: 24),
              _buildSleepInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepSummary() {
    if (sleepHistory.isEmpty) return Container(); // Handle empty state
    final lastNight = sleepHistory.last;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Night\'s Sleep',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.access_time,
                  value: '${lastNight.duration.toStringAsFixed(1)}h',
                  label: 'Duration',
                ),
                _buildSummaryItem(
                  icon: Icons.star,
                  value: '${lastNight.quality}',
                  label: 'Quality',
                ),
                _buildSummaryItem(
                  icon: Icons.nightlight_round,
                  value: DateFormat('hh:mm a').format(lastNight.date),
                  label: 'Bedtime',
                ),
                _buildSummaryItem(
                  icon: Icons.wb_sunny,
                  value: DateFormat('hh:mm a').format(lastNight.date.add(Duration(hours: lastNight.duration.toInt()))),
                  label: 'Wake time',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSleepHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          // Calculate the date based on the index
                          final date = DateTime.now().subtract(Duration(days:1- value.toInt()));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(DateFormat('E').format(date)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: sleepHistory
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.duration))
                          .toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: const Color.fromARGB(255, 6, 168, 152)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showSleepLogDialog,
              child: const Text('Log Sleep Data', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Sleep',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Bedtime',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('hh:mm a').format(bedtime),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(bedtime),
                      );
                      if (time != null) {
                        setState(() {
                          bedtime = DateTime(
                            bedtime.year,
                            bedtime.month,
                            bedtime.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Wake time',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('hh:mm a').format(wakeTime),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(wakeTime),
                      );
                      if (time != null) {
                        setState(() {
                          wakeTime = DateTime(
                            wakeTime.year,
                            wakeTime.month,
                            wakeTime.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Sleep Quality'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < (sleepHistory.isNotEmpty ? sleepHistory.last.quality : 0) ? Icons.star : Icons.star_border,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      if (sleepHistory.isNotEmpty) {
                        sleepHistory.last.quality = index + 1;
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Here you would typically save the sleep log to a database or state management solution
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep log saved')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text('Save Sleep Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepLogDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime selectedBedtime = bedtime; // Use the state variable
        DateTime selectedWakeTime = wakeTime; // Use the state variable
        int selectedQuality = 3; // Default quality

        return AlertDialog(
          title: const Text('Log Sleep Data', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Bedtime:'),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedBedtime),
                  );
                  if (time != null) {
                    setState(() {
                      selectedBedtime = DateTime(
                        selectedBedtime.year,
                        selectedBedtime.month,
                        selectedBedtime.day,
                        time.hour,
                        time.minute,
                      );
                      bedtime = selectedBedtime; // Update the state variable
                    });
                  }
                },
                child: Text(DateFormat('hh:mm a').format(selectedBedtime)),
              ),
              const Text('Select Wake Time:'),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedWakeTime),
                  );
                  if (time != null) {
                    setState(() {
                      selectedWakeTime = DateTime(
                        selectedWakeTime.year,
                        selectedWakeTime.month,
                        selectedWakeTime.day,
                        time.hour,
                        time.minute,
                      );
                      wakeTime = selectedWakeTime; // Update the state variable
                    });
                  }
                },
                child: Text(DateFormat('hh:mm a').format(selectedWakeTime)),
              ),
              const Text('Sleep Quality:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedQuality ? Icons.star : Icons.star_border,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedQuality = index + 1;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Save the sleep data
                // Adjust for next day if wake time is before bedtime
                if (selectedWakeTime.isBefore(selectedBedtime)) {
                  selectedWakeTime = selectedWakeTime.add(const Duration(days: 1));
                }

                final duration = selectedWakeTime.difference(selectedBedtime).inHours.toDouble();

                // Ensure duration is not negative
                if (duration < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid time selection.')),
                  );
                  return; // Prevent saving
                }

                final sleepData = SleepData(selectedBedtime, duration, selectedQuality);

                // Get user ID
                String userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId'; // Replace with actual user ID

                // Save to Firestore
                await FirestoreService().saveSleepData(
                  userId,
                  userName, // Use the fetched user name
                  userEmail, // Use the fetched user email
                  selectedBedtime, // Pass DateTime directly
                  selectedWakeTime, // Pass DateTime directly
                  selectedQuality, // Pass int directly
                );

                setState(() {
                  sleepHistory.add(sleepData);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class SleepData {
  final DateTime date;
  final double duration;
  int quality;

  SleepData(this.date, this.duration, this.quality);

  // Add this method to convert a Map to SleepData
  factory SleepData.fromMap(Map<String, dynamic> data) {
    return SleepData(
      data['sleepDate'].toDate(), // Ensure this is a Timestamp
      data['sleepDuration'].toDouble(),
      data['quality'] ?? 0, // Default quality if not present
    );
  }
}
