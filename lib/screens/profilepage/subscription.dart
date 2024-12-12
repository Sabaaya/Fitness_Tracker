import 'package:fitness/setting_categories.dart/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:fitness/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String? _selectedPlan;
  List<String> _selectedWorkouts = [];
  String? _planDescription;
  final FirestoreService _firestoreService = FirestoreService();
  late Future<bool> _paymentStatus;
  late String _userId;

  final Map<String, String> _planDescriptions = {
    'Basic Plan': 'The Basic Plan provides access to essential workout features including basic exercise routines and tracking capabilities. Ideal for beginners who want to get started with fitness.',
    'Premium Plan': 'The Premium Plan offers a comprehensive suite of features including personalized coaching, advanced analytics, exclusive workout routines, and priority support. Perfect for users seeking advanced features and personalized guidance.'
  };

  final Map<String, List<String>> _workouts = {
    'Basic Plan': [
      'Morning Energizer: A series of light stretching exercises to kickstart your day.',
      'Core Strength: Basic core strengthening exercises to build stability.',
      'Full Body Routine: A balanced workout targeting all major muscle groups.'
    ],
    'Premium Plan': [
      'Advanced Cardio Blast: High-intensity interval training for improved cardiovascular health.',
      'Strength Training Pro: Detailed strength workouts focusing on different muscle groups.',
      'Flexibility Masterclass: Advanced stretching and flexibility exercises for improved range of motion.',
      'Recovery and Wellness: Guided sessions for muscle recovery and overall wellness.'
    ]
  };

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _paymentStatus = _firestoreService.getPaymentStatus(_userId);
  }

  void _onPlanSelected(String plan) {
    setState(() {
      if (_selectedPlan == plan) {
        _selectedPlan = null;
        _planDescription = null;
        _selectedWorkouts = [];
      } else {
        _selectedPlan = plan;
        _planDescription = _planDescriptions[plan];
        _selectedWorkouts = _workouts[plan] ?? [];
      }
    });
  }

  Future<void> _updatePaymentStatus(bool hasPaid) async {
    try {
      await _firestoreService.storePaymentStatus(_userId, hasPaid);
      if (hasPaid) {
        // Add subscription details when marking as paid
        await _firestoreService.updatePaymentStatus(
          _userId,
          hasPaid,
          _selectedPlan ?? 'Basic Plan',
          _selectedPlan == 'Premium Plan' ? 1639 : 819,
          DateTime.now(),
          DateTime.now().add(const Duration(days: 90)),
        );
      }
      setState(() {
        _paymentStatus = Future.value(hasPaid);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hasPaid ? 'Payment recorded' : 'Payment status updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update payment status: $e')),
      );
    }
  }

  void _showInfoDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscription Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Our fitness tracker offers different subscription plans:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '• Basic Plan: ₹819 per month - Access to basic features.\n'
                '• Premium Plan: ₹1639 per month - Includes personalized coaching, advanced analytics, exclusive routines, and priority support.',
              ),
              const SizedBox(height: 16.0),
              const Text(
                'For more information or assistance, please contact our support team.',
                style: TextStyle(color: Color.fromARGB(255, 75, 68, 68)),
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: () async {
                  const url = 'mailto:support@example.com'; // Replace with your support email
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: const Text(
                  'Contact Support',
                  style: TextStyle(color: Color.fromARGB(255, 80, 16, 208), decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color of the back icon here
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: Colors.white,
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _paymentStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            bool hasPaid = snapshot.data ?? false;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Status Section
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: hasPaid ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Status: ${hasPaid ? 'Paid' : 'Not Paid'}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _updatePaymentStatus(!hasPaid),
                            style: ElevatedButton.styleFrom(backgroundColor: hasPaid ? Colors.grey : const Color.fromARGB(255, 34, 224, 211)),
                            child: Text(hasPaid ? 'Reset Payment Status' : 'Record Payment'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Current Subscription Section
                    
                    const SizedBox(height: 16.0),

                    // Subscription Plans List
                    const Text(
                      'Available Plans',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    SubscriptionPlanCard(
                      name: 'Basic Plan',
                      price: '₹819 / month',
                      description: _planDescriptions['Basic Plan']!,
                      onTap: () => Navigator.pushNamed(context, '/basic'),
                      isSelected: _selectedPlan == 'Basic Plan',
                    ),
                    const SizedBox(height: 8.0),
                    SubscriptionPlanCard(
                      name: 'Premium Plan',
                      price: '₹1639 / month',
                      description: _planDescriptions['Premium Plan']!,
                      onTap: () => Navigator.pushNamed(context, '/premium'),
                      isSelected: _selectedPlan == 'Premium Plan',
                    ),
                    const SizedBox(height: 17.0),

                    // Plan Details
                    if (_selectedPlan != null) ...[
                      Text(
                        'Selected Plan: $_selectedPlan',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Description: $_planDescription',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Workouts Included:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      for (var workout in _selectedWorkouts)
                        Text(
                          '- $workout',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                    const SizedBox(height: 20.0),

                    // Manage Subscription Buttons
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the HomepageNavbar when cancel is pressed
                              Navigator.pushNamed(context, '/bottomNavigationbar');
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: PrimaryColor),
                            child: const Text('Cancel Subscription', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class SubscriptionPlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String description;
  final VoidCallback onTap;
  final bool isSelected;

  const SubscriptionPlanCard({super.key, 
    required this.name,
    required this.price,
    required this.description,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
