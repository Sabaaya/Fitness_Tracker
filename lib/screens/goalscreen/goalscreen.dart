import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/models/DetailPageTitle.dart';
import 'package:fitness/models/detailpagebutton.dart';
import 'package:fitness/models/list_wheel_view_scroller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package

class Goalscreen extends StatefulWidget {
  const Goalscreen({super.key});

  @override
  State<Goalscreen> createState() => _GoalscreenState();
}

class _GoalscreenState extends State<Goalscreen> {
  String selectedGoal = 'Lose Weight'; // Default value

  Future<void> saveGoalToFirestore(String userId, String goal) async {
    try {
      await FirebaseFirestore.instance.collection('data').doc(userId).set({
        'goal': goal,
      }, SetOptions(merge: true)); // Merge with existing data
      print('Goal updated successfully');
    } catch (e) {
      print('Failed to update goal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = [
      'Lose Weight',
      'Gain Weight',
      'Stay Fit',
      'Build Muscle',
      'Improve Endurance',
      'Stay Healthy'
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Detailpagetitle(
              text: 'This helps us to create a personalized plan for you',
              title: "What is your Goal",
              color: Colors.white,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      items[index],
                      style: TextStyle(
                        color: selectedGoal == items[index] ? Colors.blue : Colors.white,
                        fontSize: selectedGoal == items[index] ? 24.0 : 18.0,
                        fontWeight: selectedGoal == items[index] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedGoal = items[index];
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      String userId = user.uid;
                      await saveGoalToFirestore(userId, selectedGoal);
                      Navigator.pushNamed(context, '/activity');
                    }
                  },
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
