import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/models/DetailPageTitle.dart';
import 'package:fitness/models/detailpagebutton.dart';
import 'package:fitness/models/list_wheel_view_scroller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package

class Agescreen extends StatefulWidget {
  const Agescreen({super.key});

  @override
  State<Agescreen> createState() => _AgescreenState();
}

class _AgescreenState extends State<Agescreen> {
  int selectedAge = 0; // Index of the selected age

  Future<void> saveAgeToFirestore(String userId, int age) async {
    try {
      await FirebaseFirestore.instance.collection('data').doc(userId).set({
        'age': age,
      }, SetOptions(merge: true)); // Merge with existing data
      print('Age updated successfully');
    } catch (e) {
      print('Failed to update age: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = [];
    for (int i = 1; i < 100; i++) {
      items.add(i.toString());
    }

    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.only(
          top: size.height * 0.0,
          left: size.width * 0.01,
          right: size.width * 0.01,
          bottom: size.height * 0.01,
        ),
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Detailpagetitle(
              title: "How old are you".toUpperCase(),
              text: "This helps us create your personalized plan",
              color: Colors.white,
            ),
            SizedBox(height: size.height * 0.055),
            SizedBox(
              height: size.height * 0.5,
              child: listwheelScrollView(
                items: items,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedAge = index;
                  });
                },
                selectedItem: items[selectedAge], // Show selected item
                selectedItemTextStyle: const TextStyle( // Add this line
                  color: Colors.white, // Customize the text style as needed
                  fontSize: 24.0,
                ), 
                unselectedItemTextStyle: const TextStyle( // Provide a default TextStyle
                  color: Colors.grey, // Customize as needed
                  fontSize: 18.0,
                ),
              ),
            ),
            DetailPageButton(
              text: 'Next',
              onTap: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  String userId = user.uid;
                  await saveAgeToFirestore(userId, int.parse(items[selectedAge]));
                  Navigator.pushNamed(context, '/weight');
                } else {
                  // Handle the case where the user is not logged in
                  print('No user is currently logged in');
                }
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
