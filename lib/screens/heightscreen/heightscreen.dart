import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/models/DetailPageButton.dart';
import 'package:fitness/models/DetailPageTitle.dart';
import 'package:fitness/models/list_wheel_view_scroller.dart';
import 'package:flutter/material.dart';

class Heightscreen extends StatefulWidget {
  const Heightscreen({super.key});

  @override
  State<Heightscreen> createState() => _HeightscreenState();
}

class _HeightscreenState extends State<Heightscreen> {
  int selectedHeight = 0; // To store the selected height

  Future<void> saveHeightToFirestore(String userId, int height) async {
    try {
      await FirebaseFirestore.instance.collection('data').doc(userId).set({
        'height': height,
      }, SetOptions(merge: true)); // Merges with existing data
      print('Height updated successfully');
    } catch (e) {
      print('Failed to update height: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = List.generate(200, (index) => (index + 1).toString());

    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.only(
          top: size.height * 0.0,
          left: size.width * 0.01,
          right: size.width * 0.01,
          bottom: size.height * 0.01,
        ),
        child: Column(
          children: [
            const Detailpagetitle(
              text: 'This helps us to create a personalized plan for you',
              title: "What is your Height",
              color: Colors.white,
            ),
            SizedBox(height: size.height * 0.055),
            SizedBox(
              height: size.height * 0.47,
              child: listwheelScrollView(
                items: items,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedHeight = int.parse(items[index]);
                  });
                },
                selectedItem: items[selectedHeight],
                selectedItemTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
                unselectedItemTextStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                ),
              ),
            ),
            DetailPageButton(
              text: "Next",
              onTap: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  String userId = user.uid;
                  await saveHeightToFirestore(userId, selectedHeight);
                  Navigator.pushNamed(context, '/goal');
                } else {
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
