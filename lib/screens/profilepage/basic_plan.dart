import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing payment status
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import for launching URLs

class BasicPlanPage extends StatelessWidget {
  const BasicPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Plan'),
        backgroundColor: const Color.fromARGB(255, 142, 227, 156),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildWorkoutList(context),
            _buildPaymentButton(context), // Add the payment button here
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 164, 187, 225),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Plan',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            '₹819 / month',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 16.0),
          Text(
            'This plan includes a variety of basic workouts to help you stay fit and healthy. Enjoy personalized workout routines and more!',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    final workouts = [
      {
        'title': 'Morning Cardio',
        'description': 'A quick morning cardio session to kickstart your day.',
        'image': 'assets/img/a5.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Full Body Strength',
        'description': 'A full-body strength workout to build muscle and endurance.',
        'image': 'assets/img/a2.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Yoga for Flexibility',
        'description': 'Improve your flexibility with this relaxing yoga routine.',
        'image': 'assets/img/b1.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      // Additional workout items
      {
        'title': 'Evening Meditation',
        'description': 'Relax and meditate to calm your mind.',
        'image': 'assets/img/b3.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'Core Strengthening',
        'description': 'Strengthen your core with this powerful routine.',
        'image': 'assets/img/b8.jpg',
        'video': 'assets/video/exercise1.mp4',
      },
      {
        'title': 'HIIT Workout',
        'description': 'A high-intensity interval training workout for maximum fat burn.',
        'image': 'assets/img/b5.jpg',
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
                  onPressed: () => _checkPaymentAndPlayVideo(context, workout['video']!),
                  child: const Text('Watch Video'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    const String paymentUrl = "https://pages.razorpay.com/pl_OwIzzXwwRllwkJ/view";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => _launchURLAndMarkPayment(context, paymentUrl),
        icon: const Icon(Icons.payment),
        label: const Text('Make Payment'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 165, 237, 167),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          textStyle: const TextStyle(fontSize: 18,color: Colors.black),
        ),
      ),
    );
  }

  Future<void> _launchURLAndMarkPayment(BuildContext context, String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);

      // Mark payment as complete after launching the URL
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPaid', true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _checkPaymentAndPlayVideo(BuildContext context, String videoUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPaid = prefs.getBool('isPaid') ?? false;

    if (isPaid) {
      // If payment is completed, play the video
      _playVideo(context, videoUrl);
    } else {
      // If payment is not completed, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please make the payment to watch the video.')),
      );
    }
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

  @override
  void initState() {
    super.initState();
    // Load video from asset or network
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
