import 'package:calendar_slider/calendar_slider.dart';
import 'package:fitness/constants/color.dart';
import 'package:fitness/setting_categories.dart/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Import for Random class

class WorkoutProgress extends StatefulWidget {
  const WorkoutProgress({super.key});

  @override
  State<WorkoutProgress> createState() => _WorkoutProgressState();
}

class _WorkoutProgressState extends State<WorkoutProgress> {
  final _firstController = CalendarSliderController();
  final FirestoreService _firestoreService =
      FirestoreService(); // Instantiate your Firestore service
  late String userId;
  Map<String, dynamic> userProgress = {
    'activeCalories': 0.0,
    'steps': 0.0,
    'exerciseTime': 0.0,
    'heartRate': 0.0,
  };
  Map<String, bool> progressMap = {};
  String progressMessage = 'No progress message yet';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';
    _loadUserProgress(DateTime.now());
    _initializeProgressMap();
  }

  Future<void> _loadUserProgress(DateTime date) async {
    try {
      final progress =
          await _firestoreService.getUserProgressForDay(userId, date);
      print("Fetched progress: $progress"); // Debug print
      setState(() {
        userProgress = progress;
        progressMessage = progress['progressMessage'] ?? 'No progress message';
      });
      print("Loaded user progress: $userProgress");
      print("Progress message: $progressMessage");
    } catch (e) {
      print('Error loading user progress: $e');
    }
  }

  Future<void> _initializeProgressMap() async {
    progressMap = await _firestoreService.getUserProgressMap(userId) ?? {};
    setState(() {});
  }

  // Update this method
  Future<void> _updateProgressWithRandomData(
      String activity, int timeSpentInMinutes) async {
    try {
      String message = 'Completed $activity for $timeSpentInMinutes minutes';
      print("Debug: Progress message being set: $message");

      await _firestoreService.updateUserProgressWithRandomData(
        userId: userId,
        category: 'workout',
        completedActivity: activity,
        steps: 0, // Add this line
        exerciseTime: timeSpentInMinutes, // Add this line
        calories: Random().nextInt(300) + 100,
        heartbeat: Random().nextInt(60) +
            60, // Add this line: Random heartbeat between 60-120 bpm
        progressMessage: message, // Add this line
      );

      // Reload progress after update
      await _loadUserProgress(DateTime.now());
      await _initializeProgressMap();
    } catch (e) {
      print('Error updating progress with random data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Debug: Building widget with message: $progressMessage"); // Debug print
    print("Debug: User progress: $userProgress"); // Debug print
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Workout Progress',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/bottomNavigationbar');
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160.0),
          child: CalendarSlider(
            controller: _firstController,
            selectedDayPosition: SelectedDayPosition.center,
            fullCalendarScroll: FullCalendarScroll.vertical,
            backgroundColor: Colors.grey[900],
            fullCalendarWeekDay: WeekDay.short,
            selectedTileBackgroundColor: PrimaryColor,
            monthYearButtonBackgroundColor: Colors.grey[700],
            monthYearTextColor: Colors.white,
            tileBackgroundColor: Colors.grey[700],
            selectedDateColor: Colors.black,
            dateColor: Colors.white,
            tileShadow: BoxShadow(
              color: Colors.black.withOpacity(1),
            ),
            locale: 'en',
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 100)),
            lastDate: DateTime.now().add(const Duration(days: 100)),
            onDateSelected: (date) {
              setState(() {
                _loadUserProgress(date); // Load progress for the selected date
              });
            },
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          final size = MediaQuery.of(context).size;
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.04),
                Text(
                  progressMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: size.height * 0.02),
                Center(
                  // Center widget to center the indicators
                  child: Column(
                    // Wrap in a Column to stack indicators
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    children: [
                      _buildProgressIndicators(),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                ...progressMap.entries.map((entry) => TextCheckboxContainer(
                      text: entry.key,
                      subtext:
                          '10:00am - 11:00am', // Replace with actual time if available
                      value: entry.value,
                      onChanged: (bool? newValue) {
                        if (newValue != null && newValue) {
                          setState(() {
                            progressMap[entry.key] = newValue;
                            _updateProgressWithRandomData(
                                entry.key, 60); // Assuming 60 minutes
                          });
                        }
                      },
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculateCaloriesProgress(double calories) {
    // Assuming a daily goal of 500 active calories
    return calories / 500.0;
  }

  // Add similar calculation methods for steps, time, and heart rate

  Widget _buildProgressIndicator({
    required String label,
    required double value,
    required Color color,
  }) {
    return CircularIndicatorText(
      text: '${(value * 100).toInt()}%',
      subText: label,
      color: color,
      strokeWidth: 14,
      size: 140,
      value: value,
    );
  }

  Widget _buildProgressIndicators() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressIndicator(
          label: 'Calories',
          value:
              _calculateCaloriesProgress(userProgress['activeCalories'] ?? 0.0),
          color: Colors.orange,
        ),
        const SizedBox(height: 20), // Add spacing between indicators
        _buildProgressIndicator(
          label: 'Steps',
          value: (userProgress['steps'] ?? 0.0) /
              10000, // Assuming 10000 steps goal
          color: Colors.blue,
        ),
        const SizedBox(height: 20), // Add spacing between indicators
        _buildProgressIndicator(
          label: 'Exercise',
          value: (userProgress['exerciseTime'] ?? 0.0) /
              60, // Assuming 60 minutes goal
          color: Colors.green,
        ),
        const SizedBox(height: 20), // Add spacing between indicators
        _buildProgressIndicator(
          label: 'Heart Rate',
          value: (userProgress['heartRate'] ?? 0.0) /
              220, // Assuming max heart rate of 220
          color: Colors.red,
        ),
      ],
    );
  }
}

class TextCheckboxContainer extends StatelessWidget {
  const TextCheckboxContainer({
    super.key,
    required this.text,
    required this.subtext,
    required this.value,
    required this.onChanged,
  });

  final String text;
  final String subtext;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.090,
      width: size.width * 0.9,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: value ? PrimaryColor.withOpacity(0.2) : Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: value ? PrimaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: value
                ? PrimaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 11), // Added padding for checkbox
            child: Checkbox(
              onChanged: onChanged,
              value: value,
              activeColor: PrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CircularIndicatorText extends StatelessWidget {
  const CircularIndicatorText({
    super.key,
    required this.text,
    required this.subText,
    required this.color,
    required this.strokeWidth,
    this.size,
    required this.value,
  });

  final String text;
  final double? size;
  final String subText;
  final Color color;
  final double strokeWidth;
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 22, color: Colors.white),
              ),
              Text(
                subText,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
