import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/constants/color.dart';
import 'package:fitness/models/DetailPageButton.dart';
import 'package:fitness/models/detailpagetitle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package

class GenderPage extends StatefulWidget {
  const GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  bool isMale = true;
  bool isFemale = false;
  String selectedGender = 'Male'; // Default value

  Future<void> saveGenderToFirestore(String userId, String gender) async {
    try {
      await FirebaseFirestore.instance.collection('data').doc(userId).set({
        'gender': gender,
      }, SetOptions(merge: true)); // Merge with existing data
      print('Gender updated successfully');
    } catch (e) {
      print('Failed to update gender: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.only(
          top: size.height * 0.001,
          left: size.width * 0.03,
          right: size.width * 0.03,
          bottom: size.height * 0.001,
        ),
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            const Detailpagetitle(
              title: "TELL US ABOUT YOURSELF",
              text: "This will help us to find the best content for you",
              color: Colors.white,
            ),
            SizedBox(height: size.height * 0.01),
            GenderIcon(
              icon: Icons.male,
              title: 'Male',
              onTap: () {
                setState(() {
                  isMale = true;
                  isFemale = false;
                  selectedGender = 'Male';
                });
              },
              isSelected: isMale,
            ),
            SizedBox(height: size.height * 0.01),
            GenderIcon(
              icon: Icons.female,
              title: 'Female',
              onTap: () {
                setState(() {
                  isMale = false;
                  isFemale = true;
                  selectedGender = 'Female';
                });
              },
              isSelected: isFemale,
            ),
            const Spacer(),
            DetailPageButton(
              text: "Next",
              onTap: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  String userId = user.uid;
                  await saveGenderToFirestore(userId, selectedGender);
                  Navigator.pushNamed(context, '/age');
                } else {
                  // Handle the case where the user is not logged in
                  print('No user is currently logged in');
                }
              },
              showBackButton: true,
              onBackTap: () {
                Navigator.pop(context); // Handles back navigation
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GenderIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const GenderIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: isSelected ? PrimaryColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: size.width * 0.1,
                color: isSelected ? Colors.black : Colors.white,
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: size.width * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
