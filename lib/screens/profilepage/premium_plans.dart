import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class PremiumPlanPage extends StatefulWidget {
  const PremiumPlanPage({super.key});

  @override
  _PremiumPlanPageState createState() => _PremiumPlanPageState();
}

class _PremiumPlanPageState extends State<PremiumPlanPage> {
  bool hasPaid = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  // Check if the user has paid
  Future<void> _checkPaymentStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasPaid = prefs.getBool('hasPaid') ?? false;
    });
  }

  // Method to handle successful payment
  Future<void> _onPaymentSuccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasPaid', true);
    setState(() {
      hasPaid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Plan'),
        backgroundColor: const Color.fromARGB(255, 146, 170, 226),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            if (!hasPaid) _buildPaymentButton(), // Show payment button if not paid
            _buildWorkoutList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 222, 159, 208),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Plan',
            style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            '₹1599 / month',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 16.0),
          Text(
            'This plan offers advanced workouts designed for more intense training. Get access to exclusive content and advanced routines to push your fitness to the next level!',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Payment button widget
  Widget _buildPaymentButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          const paymentUrl = 'https://pages.razorpay.com/pl_OwIzzXwwRllwkJ/view';
          // Open the payment URL and handle payment success
          if (await canLaunch(paymentUrl)) {
            await launch(paymentUrl);
            _onPaymentSuccess(); // Call this after payment is successful
          } else {
            throw 'Could not launch $paymentUrl';
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 127, 203, 129),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        ),
        child: const Text(
          'Subscribe Now',
          style: TextStyle(fontSize: 18,color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildWorkoutList() {
    final workouts = [
      {
        'title': 'HIIT Session',
        'description': 'A high-intensity interval training session to boost your metabolism.',
        'image': 'assets/img/a4.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Advanced Strength Training',
        'description': 'A strength training routine designed for advanced users.',
        'image': 'assets/img/b7.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Power Yoga',
        'description': 'A dynamic yoga session to improve flexibility and strength.',
        'image': 'assets/img/a9.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Core Blaster',
        'description': 'Intense core workout to improve abdominal strength.',
        'image': 'assets/img/a4.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Plyometrics',
        'description': 'Explosive movements to enhance your agility and speed.',
        'image': 'assets/img/i5.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Pilates Fusion',
        'description': 'A fusion of Pilates and strength training for a balanced workout.',
        'image': 'assets/img/i8.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'CrossFit Circuit',
        'description': 'A full-body workout circuit to increase endurance.',
        'image': 'assets/img/i5.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Tabata Training',
        'description': 'Short and intense workouts to maximize fat burn.',
        'image': 'assets/img/i8.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(workout['image']!),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  workout['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  workout['description']!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: hasPaid
                      ? () => _playVideo(context, workout['video']!)
                      : null, // Disable button if not paid
                  child: Text(hasPaid ? 'Watch Video' : 'Unlock by Subscribing'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _playVideo(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
