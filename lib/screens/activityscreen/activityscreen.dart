import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package
import 'package:flutter/material.dart';
import 'package:fitness/models/DetailPageButton.dart';
import 'package:fitness/models/DetailPageTitle.dart';
import 'package:fitness/models/list_wheel_view_scroller.dart';

class Activityscreen extends StatefulWidget {
  const Activityscreen({super.key});

  @override
  State<Activityscreen> createState() => _ActivityscreenState();
}

class _ActivityscreenState extends State<Activityscreen> {
  String selectedActivity = 'Rookie'; // Default activity level

  // Function to save selected activity level to Firestore
  Future<void> _saveActivityLevel(String activity) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        await FirebaseFirestore.instance.collection('data').doc(userId).set({
          'activity_level': activity,
        }, SetOptions(merge: true)); // Use merge to update existing document without overwriting
        print('Activity level saved successfully');
      } else {
        print('No user is currently logged in');
      }
    } catch (error) {
      print('Error saving activity level: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = [
      'Rookie',
      'Beginner',
      'Intermediate',
      'Advance',
      'True Athlete',
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Detailpagetitle(
              text: 'This helps us to create a personalized plan for you',
              title: "YOUR REGULAR PHYSICAL ACTIVITY LEVEL",
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
                        color: selectedActivity == items[index] ? Colors.blue : Colors.white,
                        fontSize: selectedActivity == items[index] ? 24.0 : 18.0,
                        fontWeight: selectedActivity == items[index] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedActivity = items[index];
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
                    print("Back button tapped");
                    Navigator.pop(context);
                  },
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print("Next button tapped");
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      String userId = user.uid;
                      await _saveActivityLevel(selectedActivity);
                      Navigator.pushNamed(context, '/bottomNavigationbar');
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
