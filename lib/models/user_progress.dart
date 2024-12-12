class UserProgress {
  final double activeCalories;
  final double steps;
  final double exerciseTime;
  final double heartRate;

  UserProgress({
    required this.activeCalories,
    required this.steps,
    required this.exerciseTime,
    required this.heartRate,
  });
    // Factory method to create a UserProgress instance from a Map
  factory UserProgress.fromMap(Map<String, dynamic> data) {
    return UserProgress(
      activeCalories: double.parse(data['activeCalories'] ?? '0'),
      steps: double.parse(data['steps'] ?? '0'),
      heartRate: double.parse(data['heartRate'] ?? '0'),
      exerciseTime: double.parse(data['exerciseTime'] ?? '0'),
    );
  }

  // Method to convert UserProgress instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'activeCalories': activeCalories,
      'steps': steps,
      'exerciseTime': exerciseTime,
      'heartRate': heartRate,
    };
  }
}
