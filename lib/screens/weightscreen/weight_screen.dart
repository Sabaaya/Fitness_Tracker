import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/constants/color.dart';
import 'package:fitness/models/DetailPageTitle.dart';
import 'package:fitness/models/detailpagebutton.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double weight = 60.0; // Default weight value

  Future<void> saveWeightToFirestore(String userId, double weight) async {
    try {
      await FirebaseFirestore.instance.collection('data').doc(userId).set({
        'weight': weight,
      }, SetOptions(merge: true)); // Merges with existing data
      print('Weight updated successfully: $weight for user: $userId');
    } catch (e) {
      print('Failed to update weight: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> levels = [];

    for (var i = 30; i <= 500; i++) {
      levels.add(i.toString()); // Update to only include numbers
    }

    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.only(
          top: size.height * 0.04,
          left: size.width * 0.03,
          right: size.width * 0.03,
          bottom: size.height * 0.04,
        ),
        child: Column(
          children: [
            const Detailpagetitle(
              title: "What is your Weight",
              text: 'You can change this later in the settings',
              color: Colors.white,
            ),
            SizedBox(height: size.height * 0.055),
            Text(
              '${weight.toStringAsFixed(1)} kg', // Display weight with one decimal place
              style: TextStyle(
                color: PrimaryColor,
                fontSize: size.height * 0.036,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.055),
            Expanded(
              child: ListWheelScrollView(
                itemExtent: size.height * 0.1, // Adjust item extent for better visibility
                magnification: 1.2,
                useMagnifier: true,
                overAndUnderCenterOpacity: 0.3,
                physics: const FixedExtentScrollPhysics(),
                controller: FixedExtentScrollController(initialItem: ((weight - 30).toInt())), // Adjust initialItem calculation
                onSelectedItemChanged: (index) {
                  setState(() {
                    weight = (index + 30).toDouble();
                    print('Selected weight: $weight'); // Debugging line
                  });
                },
                children: levels.map((level) {
                  return Center( // Center items for better alignment
                    child: Text(
                      level,
                      style: TextStyle(
                        color: PrimaryColor,
                        fontSize: size.height * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            DetailPageButton(
              text: 'Next',
              onTap: () async {
                // Get the current user ID from FirebaseAuth
                String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
                print('Saving weight: $weight for user ID: $userId'); // Debugging line
                await saveWeightToFirestore(userId, weight);
                Navigator.pushNamed(context, '/height');
              },
              showBackButton: true,
              onBackTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
