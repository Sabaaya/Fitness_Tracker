import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness/setting_categories.dart/services/firestore_services.dart';

class WorkoutCategories extends StatefulWidget {
  const WorkoutCategories({super.key});

  @override
  State<WorkoutCategories> createState() => _WorkoutCategoriesState();
}

class _WorkoutCategoriesState extends State<WorkoutCategories> {
  static List<String> workoutCategories = [
    "Rookies",
    "beginner",
    "intermediate",
    "advanced",
    "True Athlete"
  ];

  int selectedCategory = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'user123'; // Current user ID
  final FirestoreService _firestoreService = FirestoreService();
  late Stopwatch _stopwatch;
  String _progressMessage = 'No progress message yet';

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Workout Categories',
              style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),
                SingleChildScrollView(
                  // Wrap with SingleChildScrollView for horizontal scrolling
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    isSelected: List.generate(workoutCategories.length,
                        (index) => index == selectedCategory),
                    onPressed: (int index) async {
                      if (mounted) {
                        setState(() {
                          selectedCategory = index;
                        });
                        String category = workoutCategories[selectedCategory];
                        await _updateProgress(
                            category, 'In Progress'); // Track progress
                      }
                    },
                    children: workoutCategories.map((category) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: selectedCategory ==
                                  workoutCategories.indexOf(category)
                              ? const Color.fromARGB(255, 128, 215, 14)
                              : Colors.black,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: selectedCategory ==
                                        workoutCategories.indexOf(category)
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Display images and videos based on the selected category
                FutureBuilder<QuerySnapshot>(
                  future: _firestore
                      .collection('workout_categories')
                      .doc(workoutCategories[selectedCategory])
                      .collection('items')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No data available'));
                    }

                    var documents = snapshot.data!.docs;

                    return Column(
                      children: documents.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print(
                                      "Image clicked: ${data['title']}"); // Console message
                                  _playVideo(data["video"],
                                      workoutCategories[selectedCategory]);
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: size.width * 0.9,
                                      height: size.height * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Image.network(
                                        data["image"],
                                        width: size.width * 0.9,
                                        height: size.height * 0.3,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: size.height * 0.12,
                                      left: size.width * 0.4,
                                      child: const Icon(
                                        Icons.play_circle_fill,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned(
                                      top: size.height * 0.18,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data["title"],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              data["time"],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                Text(_progressMessage,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Play video and track the progress
  void _playVideo(String videoPath, String category) async {
    print(
        "1. _playVideo called with videoPath: $videoPath, category: $category");
    try {
      await _updateProgress(category, 'In Progress');
      print("2. Progress updated for category: $category");

      String videoUrl = await _getVideoUrl(videoPath);
      print("3. Resolved video URL: $videoUrl");

      if (videoUrl.isNotEmpty) {
        print("4. Pushing VideoPlayerScreen with videoPath: $videoUrl");
        _stopwatch.start();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoPath: videoUrl),
          ),
        );
        _stopwatch.stop();
        print("5. Returned from VideoPlayerScreen");
        await _updateWorkoutProgress(category);
        print("6. _updateWorkoutProgress completed");
      } else {
        throw Exception('Invalid video path');
      }
    } catch (e) {
      print('Error in _playVideo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing video: $e')),
      );
    }
  }

  // Update progress function to track the workout status
  Future<void> _updateProgress(String category, String status) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(category)
        .set({
      'status': status,
      'lastCompletedWorkout': DateTime.now(),
    }, SetOptions(merge: true));
  }

  // Get progress status for a category
  Future<String> _getProgress(String category) async {
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(category)
        .get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      return data['status'] ?? 'Not Started';
    } else {
      return 'Not Started';
    }
  }

  Future<String> _getVideoUrl(String videoPath) async {
    print("Getting video URL for path: $videoPath");
    if (videoPath.startsWith('assets/')) {
      return videoPath; // Return as-is for asset paths
    } else if (videoPath.startsWith('https://') ||
        videoPath.startsWith('http://')) {
      return videoPath; // Return as-is for direct URLs
    } else {
      print("Unsupported video path format: $videoPath");
      return '';
    }
  }

  Future<void> _updateWorkoutProgress(String category) async {
    try {
      int watchTimeInSeconds = _stopwatch.elapsed.inSeconds;
      await _firestoreService.updateUserProgressWithVideoData(
        userId: userId,
        category: category,
        completedActivity: category,
        watchTimeInSeconds: watchTimeInSeconds,
      );

      // Fetch and display updated progress
      await _fetchAndDisplayProgress();
    } catch (e) {
      print("Error updating progress: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: $e')),
      );
    }
  }

  Future<void> _fetchAndDisplayProgress() async {
    try {
      final progress =
          await _firestoreService.getUserProgressForDay(userId, DateTime.now());
      setState(() {
        _progressMessage = 'Progress: ${progress['progressMessage']}\n'
            'Calories: ${progress['activeCalories']}\n'
            'Steps: ${progress['steps']}\n'
            'Exercise Time: ${progress['exerciseTime']} minutes\n'
            'Heart Rate: ${progress['heartRate']} bpm';
      });
      print(_progressMessage);
    } catch (e) {
      print("Error fetching progress: $e");
    }
  }
}

// Video player screen
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isControllerInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print("Video URL: ${widget.videoPath}"); // Add this line
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _isControllerInitialized = true;
        });
        _controller.play();
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Error initializing video: $error';
        });
        print(_errorMessage);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Center(
        child: _isControllerInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : _errorMessage.isNotEmpty
                ? Text(_errorMessage)
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
    _controller.dispose();
    super.dispose();
  }
}

// Add this function to your _WorkoutCategoriesState class
void _testFunction(BuildContext context, String title, String category) {
  print("_testFunction called with title: $title, category: $category");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Clicked: $title in $category')),
  );
}
