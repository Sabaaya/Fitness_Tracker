import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/constants/color.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _email;
  String? _name;
  int? _age;
  String? _gender;
  int? _height;
  int? _weight;
  String? _goal;
  String? _activity;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    print("_fetchUserData started");
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        print("Current user: ${user.uid}, Email: ${user.email}, DisplayName: ${user.displayName}");
        
        DocumentSnapshot userDoc = await _firestore.collection('data').doc(user.uid).get();
        
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          print("Fetched data: $data");
          
          setState(() {
            _email = data['email'] ?? user.email ?? 'N/A';
            print("Name from Firestore: ${data['name']}");
            _name = data['name'] ?? user.displayName ?? 'N/A';
            print("Name set in state: $_name");
            _age = data['age'];
            _gender = data['gender'] ?? 'N/A';
            _height = data['height'];
            _weight = data['weight'];
            _goal = data['goal'] ?? 'N/A';
            _activity = data['activity_level'] ?? 'N/A';
          });
          
          print("Updated state - Email: $_email, Name: $_name, Age: $_age, Gender: $_gender, Height: $_height, Weight: $_weight, Goal: $_goal, Activity: $_activity");
        } else {
          print("User document does not exist. Creating new profile...");
          await _createUserProfile(user);
        }
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _createUserProfile(User user) async {
    print("_createUserProfile started for user ${user.uid}");
    try {
      String defaultName = user.displayName ?? user.email?.split('@')[0] ?? 'New User';
      Map<String, dynamic> userData = {
        'email': user.email,
        'name': defaultName,
        'age': 30,
        'gender': 'Not Specified',
        'height': 170,
        'weight': 70,
        'goal': 'Stay Fit',
        'activity_level': 'Beginner',
      };
      print("Attempting to save user data: $userData");
      await _firestore.collection('data').doc(user.uid).set(userData);
      print("User profile created successfully");
      await _fetchUserData();
    } catch (e) {
      print("Error creating user profile: $e");
    }
  }

  Future<void> _updateUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('data').doc(user.uid).update({
          'name': _name,
          'age': _age,
          'gender': _gender,
          'height': _height,
          'weight': _weight,
          'goal': _goal,
          'activity_level': _activity,
        });
        print("Profile updated successfully");
        await _fetchUserData();
      } catch (e) {
        print("Error updating profile: $e");
      }
    } else {
      print("No user is currently signed in.");
    }
  }

  Widget _buildProfileItem(String label, String? value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 15, 15, 15)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
        subtitle: Text(value ?? 'N/A'),
        trailing: label != 'Email' ? const Icon(Icons.edit) : null,
        onTap: label != 'Email' ? () => _showEditDialog(label, value) : null,
      ),
    );
  }

  void _showEditDialog(String label, String? currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              setState(() {
                switch (label) {
                  case 'Name':
                    _name = controller.text;
                    break;
                  case 'Age':
                    _age = int.tryParse(controller.text);
                    break;
                  case 'Gender':
                    _gender = controller.text;
                    break;
                  case 'Height':
                    _height = int.tryParse(controller.text);
                    break;
                  case 'Weight':
                    _weight = int.tryParse(controller.text);
                    break;
                  case 'Goal':
                    _goal = controller.text;
                    break;
                  case 'Activity Level':
                    _activity = controller.text;
                    break;
                }
              });
              _updateUserProfile();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        leading: IconButton(onPressed: () {
           Navigator.of(context).pushReplacementNamed('/bottomNavigationbar'); 

        }, icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Profile'),
       
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color.fromARGB(255, 172, 240, 62),
                child: Text(
                  _name != null && _name!.isNotEmpty ? _name![0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 40, color: Color.fromARGB(255, 11, 10, 10)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileItem('Email', _email, Icons.email),
            _buildProfileItem('Name', _name, Icons.person),
            _buildProfileItem('Age', _age?.toString(), Icons.cake),
            _buildProfileItem('Gender', _gender, Icons.wc),
            _buildProfileItem('Height', _height?.toString(), Icons.height),
            _buildProfileItem('Weight', _weight?.toString(), Icons.fitness_center),
            _buildProfileItem('Goal', _goal, Icons.flag),
            _buildProfileItem('Activity Level', _activity, Icons.directions_run),
          ],
        ),
      ),
    );
  }
}