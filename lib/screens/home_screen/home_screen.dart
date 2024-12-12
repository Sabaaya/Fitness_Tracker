import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitness/constants/color.dart';
import 'package:fitness/constants/padding_margin.dart';
import '../videoplayer/video_player.dart'; // Adjust the import if necessary
import 'package:get/get.dart';
import 'package:fitness/controller/auth_controller.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedCategory = 0;
  int selectedImageIndex = -1;
  String? _userName;

  Map<int, List<String>> categoryImages = {
    0: ['assets/img/g_4.jpg', 'assets/img/of_1.jpg', 'assets/img/g_4.jpg'],
    1: ['assets/img/b3.jpg', 'assets/img/b_4.jpg', 'assets/img/b_2.jpg'],
    2: ['assets/img/on_3.jpeg', 'assets/img/b_2.jpg', 'assets/img/b3.jpg'],
  };

  List<String> videoUrls = [
    'assets/video/exercise1.mp4',
    'assets/video/exercise1.mp4',
    'assets/video/exercise1.mp4',
    'assets/video/exercise1.mp4',
  ];
  final AuthController _authController = Get.find<AuthController>();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    bool isAdmin = await _authController.isUserAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('profile').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login'); // Navigate to Login
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: PrimaryColor, // Set the text color
            ),
            child: const Text('Login'),
          ),
          // Sign Up Button
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/sign'); // Navigate to Signup
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: PrimaryColor, // Set the text color
            ),
            child: const Text('Sign Up'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 166, 234, 8),
                child: Text(
                  _userName != null && _userName!.isNotEmpty
                      ? _userName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Fitness Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/bottomNavigationbar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.start),
              title: const Text('Get started'),
              onTap: () {
                Navigator.pushNamed(context, '/onboarding');
              },
            ),
            if (_isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin'),
                onTap: () {
                  Navigator.pushNamed(context, '/admin');
                },
              ),

            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bed),
              title: const Text('Sleep'),
              onTap: () {
                Navigator.pushNamed(context, '/sleep');
              },
            ),

            ListTile(
              leading: const Icon(Icons.tips_and_updates),
              title: const Text('Tips'),
              onTap: () {
                Navigator.pushNamed(context, '/tips');
              },
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('Subscription'),
              onTap: () {
                Navigator.pushNamed(context, '/subscription');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              onTap: () {
                Navigator.pushNamed(context, '/privacy');
              },
            ),

            // Add other ListTiles here
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: size.height * 0.001),
          child: Container(
            padding: AppPadding.horizontalPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${_userName ?? 'User'}', // Updated this line
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.002),
                Text(
                  "Manage Workouts",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: size.width * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's workout plan",
                      style: TextStyle(
                        fontSize: size.width * 0.025,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/videoplayer');
                  },
                  child: Container(
                    width: size.width * 0.9,
                    height: size.height * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VideoPlayerScreen(
                                  videoPath: 'assets/video/exercise1.mp4',
                                  videoUrl: 'assets/video/exercise1.mp4',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: size.width * 0.9,
                            height: size.height * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                image: AssetImage('assets/img/on_1.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 10,
                          left: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Day 01 - Warm Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "| 9:00 AM - 10:00 AM",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Workout Categories",
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/workoutCategories');
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: PrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                ToggleButtons(
                  isSelected: List.generate(
                    3,
                    (index) => index == selectedCategory,
                  ),
                  onPressed: (int index) {
                    setState(() {
                      selectedCategory = index;
                      selectedImageIndex = -1; // Reset image selection
                    });
                  },
                  children:
                      ['Beginner', 'Intermediate', 'Advanced'].map((category) {
                    return Container(
                      height: size.height * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedCategory ==
                                ['Beginner', 'Intermediate', 'Advanced']
                                    .indexOf(category)
                            ? PrimaryColor
                            : Colors.black,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: selectedCategory ==
                                      ['Beginner', 'Intermediate', 'Advanced']
                                          .indexOf(category)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: size.height * 0.03),
                SizedBox(
                  height: size.height * 0.2,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryImages[selectedCategory]!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoPlayerScreen(
                                videoPath: 'assets/video/exercise1.mp4',
                                videoUrl: 'assets/video/exercise1.mp4',
                                // Comment out all parameters to see what's required
                                // videoUrl: 'assets/video/b${index + 1}.mp4',
                                // videoPath: 'assets/video/b${index + 1}.mp4',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.015),
                          width: size.width * 0.4,
                          height: size.height * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(
                                  categoryImages[selectedCategory]![index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  'New Workout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  height: size.height * 0.2,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3, // Number of new workout images
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoPlayerScreen(
                                videoPath: 'assets/video/exercise1.mp4',
                                videoUrl: 'assets/video/exercise1.mp4',
                                // Add all required parameters here
                                // videoAsset: 'assets/video/exercise${index + 1}.mp4',
                                // other required parameters...
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.015),
                          width: size.width * 0.4,
                          height: size.height * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage('assets/img/b${index + 1}.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
