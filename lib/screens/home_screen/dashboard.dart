import 'package:flutter/material.dart';

class FitnessDashboard extends StatelessWidget {
  const FitnessDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color.fromARGB(255, 22, 218, 179), Colors.blue[400]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildMetricsCards(),
                        const SizedBox(height: 30),
                        _buildActivityGraph(),
                        const SizedBox(height: 30),
                        _buildRecentActivities(),
                        const SizedBox(height: 30),
                         _buildWorkoutHistory(), // This method is not defined
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushNamed(context, '/bottomNavigationbar');
                },
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitness Dashboard',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Welcome back, User!',
                    style: TextStyle(color: Colors.black26),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Color.fromARGB(255, 205, 170, 170),
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricCard('Steps', '500', Icons.directions_walk),
            _buildMetricCard('Calories', '80', Icons.local_fire_department),
            _buildMetricCard('Heartrate', '75', Icons.favorite),
          ],
        ),
        const SizedBox(height: 20),
        _buildTimeSpentCard(),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: const Color.fromARGB(255, 131, 172, 218)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 6, 78, 161),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 5, 65, 133)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSpentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time Spent',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              Icon(Icons.timer, color: Colors.blue[800]),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeSpentItem('Sleep', '7 hours', 0.45),
              _buildTimeSpentItem('Strength', '30 min', 0.3),
              _buildTimeSpentItem('Workout', '5 min', 0.25),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSpentItem(String activity, String duration, double percentage) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 13,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 10, 39, 72)),
              ),
              Center(
                child: Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          activity,
          style: TextStyle(fontSize: 12, color: Colors.blue[800]),
        ),
      ],
    );
  }

  Widget _buildActivityGraph() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workouts History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: ActivityGraphPainter([100, 200, 150, 300, 250, 400]), // Pass example activity data
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {'name': 'Workout', 'duration': '30 min', 'calories': '250 kcal'},
      {'name': 'Yoga', 'duration': '45 min', 'calories': '150 kcal'},
      {'name': 'Cycling', 'duration': '60 min', 'calories': '400 kcal'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ...activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, String> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fitness_center, color: Colors.blue[800]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${activity['duration']} | ${activity['calories']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistory() {
    // Implement your workout history widget here
    return Container(); // Placeholder for the actual implementation
  }
}

class ActivityGraphPainter extends CustomPainter {
  final List<double> activityData;

  ActivityGraphPainter(this.activityData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 205, 126, 242)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color.fromARGB(255, 186, 114, 235)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create points based on activity data
    final points = activityData.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      return Offset(size.width * index / (activityData.length - 1), size.height * (1 - value / 400)); // Adjust scaling
    }).toList();

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
          (p0.dx + p1.dx) / 2,
          p0.dy,
          p1.dx,
          p1.dy,
        );
      }

      // Draw gradient under the line
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromARGB(255, 111, 160, 216).withOpacity(0.3),
          const Color.fromARGB(255, 103, 162, 230).withOpacity(0.1),
          Colors.blue[800]!.withOpacity(0.0),
        ],
      );

      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final gradientPaint = Paint()..shader = gradient.createShader(rect);

      final filledPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(filledPath, gradientPaint);
      canvas.drawPath(path, paint);

      // Draw dots
      for (final point in points) {
        canvas.drawCircle(point, 5, dotPaint);
        canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      }

      // Draw x-axis labels
      final textStyle = TextStyle(color: Colors.grey[600], fontSize: 10);
      final textSpan = TextSpan(style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < points.length; i++) {
        textPainter.text = TextSpan(text: days[i], style: textStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(points[i].dx - textPainter.width / 2, size.height + 5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}