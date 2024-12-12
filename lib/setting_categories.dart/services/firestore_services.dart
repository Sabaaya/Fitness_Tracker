import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness/models/user_progress.dart';
import 'package:fitness/setting_categories.dart/services/user_payment_details.dart';
import 'notification_model.dart';
import 'package:uuid/uuid.dart';
// For date formatting
// Add this import at the top of your file
//Update with the correct path


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Uuid _uuid = const Uuid();

  // Contact Forms Methods
  /// Sends a contact form to Firestore.
  Future<void> sendContactForm(String name, String email, String message) async {
    validateContactForm(name, email, message);
    try {
      await _db.collection('contact_forms').add({
        'name': name,
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Contact form sent successfully');
    } catch (e) {
      print('Failed to send contact form data: $e');
      throw Exception('Failed to send contact form data: $e');
    }
  }

  /// Validates the contact form data.
  void validateContactForm(String name, String email, String message) {
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      throw Exception('All contact form fields must be filled.');
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw Exception('Invalid email address.');
    }
  }

  // Users Methods
  /// Creates a new user in Firestore.
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String gender,
    required int age,
    required double weight,
    required double height,
    required String goal,
    required String activityLevel,
  }) async {
    validateUserData(name, email, gender, age, weight, height, goal, activityLevel);
    try {
      await _db.collection('data').doc(uid).set({
        'name': name,
        'email': email,
        'gender': gender,
        'age': age,
        'weight': weight,
        'height': height,
        'goal': goal,
        'activity_level': activityLevel,
      });
      print('User created successfully');
    } catch (e) {
      print('Failed to create user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  /// Validates user data before creating a user.
  void validateUserData(String name, String email, String gender, int age, double weight, double height, String goal, String activityLevel) {
    if (name.isEmpty || email.isEmpty || gender.isEmpty || goal.isEmpty || activityLevel.isEmpty) {
      throw Exception('All user fields must be filled.');
    }
    if (age <= 0 || weight <= 0 || height <= 0) {
      throw Exception('Age, weight, and height must be positive numbers.');
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw Exception('Invalid email address.');
    }
  }

  /// Updates specific fields of a user document.
  Future<void> updateUserField(String uid, Map<String, dynamic> updates) async {
    try {
      await _db.collection('data').doc(uid).update(updates);
      print('User field updated successfully');
    } catch (e) {
      print('Failed to update user field: $e');
      throw Exception('Failed to update user field: $e');
    }
  }

  Future<Map<String, bool>?> getUserProgressMap(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('workout')
          .get();

      if (docSnapshot.exists) {
        return Map<String, bool>.from(docSnapshot.data()?['progressMap'] ?? {});
      }
      return {};
    } catch (e) {
      print('Error getting user progress map: $e');
      return null;
    }
  }

  /// Retrieves user data from Firestore.
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _db.collection('data').doc(uid).get();
    } catch (e) {
      print('Failed to get user data: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Deletes a user document from Firestore.
  Future<void> deleteUser(String uid) async {
    try {
      await _db.collection('data').doc(uid).delete();
      print('User deleted successfully');
    } catch (e) {
      print('Failed to delete user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Fetches all users from Firestore.
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _db.collection('data').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Failed to get all users: $e');
      throw Exception('Failed to get all users: $e');
    }
  }

  // Workout Categories Methods
  /// Retrieves workout categories from Firestore.
  Future<List<Map<String, dynamic>>> getWorkoutCategories() async {
    try {
      print("Fetching workout categories from Firestore...");
      final snapshot = await _db.collection('workout_categories').get();
      print("Workout categories fetched successfully.");
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Failed to load workout categories: $e");
      throw Exception('Failed to load workout categories: $e');
    }
  }

  /// Updates the progress and completion status of a workout category.
  Future<void> updateCategoryProgress(String categoryId, bool completed, double progress) async {
    try {
      print("Updating category $categoryId with progress $progress...");
      await _db.collection('user_progress').doc(categoryId).update({
        'completed': completed,
        'progress': progress,
      });
      print("Category $categoryId updated successfully.");
    } catch (e) {
      print("Failed to update category progress: $e");
      throw Exception('Failed to update category progress: $e');
    }
  }

  // User Progress Methods
  /// Updates or creates user progress data.
  Future<void> updateUserProgress({
    required String userId,
    required String category,
    required Map<String, bool> progressMap,
    required double activeCalories,
    required double steps,
    required double exerciseTime,
    required double heartRate, required String progressMessage, required DateTime date,
  }) async {
    try {
      
      // Convert the progressMap to Firestore-friendly format
      final progressMapString = progressMap.map((key, value) => MapEntry(key, value.toString()));

      // Check if the document exists
      final docRef = _db.collection('exercise_progress').doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // If the document exists, update the progress for the given category
        await docRef.update({
          'progress.$category': progressMapString,
          'activeCalories': activeCalories,
          'steps': steps,
          'exerciseTime': exerciseTime,
          'heartRate': heartRate,
        });
      } else {
        // If the document doesn't exist, create a new one with the initial progress
        await docRef.set({
          'progress': {
            category: progressMapString,
          },
          'activeCalories': activeCalories,
          'steps': steps,
          'exerciseTime': exerciseTime,
          'heartRate': heartRate,
        });
      }

      print('User progress updated successfully');
    } catch (e) {
      print('Failed to update user progress: $e');
      throw Exception('Failed to update user progress: $e');
    }
  }

  /// Calculates the progress percentage for a specific category.
  Future<double> calculateProgressPercentage(String userId, String category) async {
    try {
      final doc = await _db.collection('exercise_progress').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final progressMap = data?['progress']?[category] as Map<String, dynamic>?;

        if (progressMap == null) {
          throw Exception('Progress map not found for category $category');
        }

        final totalDays = progressMap.length;
        final completedDays = progressMap.values.where((status) => status == 'true').length;

        return (completedDays / totalDays) * 100;
      } else {
        print('User document does not exist');
        return 0.0;
      }
    } catch (e) {
      print('Failed to calculate progress percentage: $e');
      throw Exception('Failed to calculate progress percentage: $e');
    }
  }

  // Exercise Tracking Methods
  /// Records exercise data in Firestore.
  Future<void> recordExercise({
    required String userId,
    required String exerciseId,
    required double calories,
    required int steps,
    required Duration timeSpent,
    required DateTime date,
  }) async {
    validateExerciseData(userId, exerciseId, calories, steps, timeSpent);
    try {
      await _db.collection('exercise_records').add({
        'user_id': userId,
        'exercise_id': exerciseId,
        'calories': calories,
        'steps': steps,
        'time_spent': timeSpent.inSeconds, // Store time in seconds
        'date': date,
      });
      print('Exercise recorded successfully');
    } catch (e) {
      print('Failed to record exercise: $e');
      throw Exception('Failed to record exercise: $e');
    }
  }

  /// Validates exercise data before recording.
  void validateExerciseData(String userId, String exerciseId, double calories, int steps, Duration timeSpent) {
    if (userId.isEmpty || exerciseId.isEmpty) {
      throw Exception('User ID and Exercise ID must not be empty.');
    }
    if (calories < 0 || steps < 0 || timeSpent.isNegative) {
      throw Exception('Calories, steps, and time spent must be non-negative.');
    }
  }

  

  /// Fetches user progress data for a specific day
  Future<Map<String, dynamic>> getUserProgressForDay(String userId, DateTime date) async {
    try {
       final dateString = date.toIso8601String().split('T')[0]; // Use only the date part
      // Fetch data from Firestore
      final snapshot = await _db.collection('user_progress')
          .doc(userId)
          .collection('progress')
          .doc(dateString)
          .get();

      if (snapshot.exists) {
        print("Firestore data: ${snapshot.data()}"); // Debug print
        return snapshot.data() as Map<String, dynamic>;
      }
      else {
        return {
          'activeCalories': 80,
          'steps': 500,
          'exerciseTime': 5,
          'heartRate': 40,
          'progressMessage': 'Workout Completed',
        };
      }
    } catch (e) {
      print('Error fetching  user progress: $e');
      return{
        'activeCalories': 0.0,
        'steps': 0.0,
        'exerciseTime': 0.0,
        'heartRate': 0.0,
        'progressMessage': 'No progress message',

      };
      
    }
  }

  /// Calculates daily active calories based on user's activity
  double calculateDailyActiveCalories(double weight, int steps, double exerciseTime) {
    // A very simple formula: 0.04 calories per step + 5 calories per minute of exercise
    return (0.04 * steps) + (5 * exerciseTime / 60);
  }

  /// Estimates average heart rate based on exercise time and intensity
  double estimateAverageHeartRate(int age, double exerciseTime, String intensity) {
    // Maximum heart rate estimation
    double maxHR = 220 - age.toDouble();
    
    // Percentage of max HR based on intensity
    double hrPercentage = intensity == 'high' ? 0.8 : (intensity == 'medium' ? 0.7 : 0.6);
    
    // Estimated average heart rate during exercise
    double exerciseHR = maxHR * hrPercentage;
    
    // Assuming resting heart rate of 70 bpm for non-exercise time
    double restingHR = 70;
    
    // Calculate weighted average
    return ((exerciseHR * exerciseTime) + (restingHR * (1440 - exerciseTime))) / 1440;
  }

  /// Generates random progress data for a completed workout
  Map<String, dynamic> generateRandomProgress() {
    final random = Random();
    return {
      'activeCalories': 50 + random.nextInt(151), // 50-200 calories
      'steps': 500 + random.nextInt(1501), // 500-2000 steps
      'exerciseTime': 10 + random.nextInt(21), // 10-30 minutes
      'heartRate': 100 + random.nextInt(41), // 100-140 bpm
    };
  }

  /// Updates user progress with randomly generated data
  Future<void> updateUserProgressWithRandomData({
    required String userId,
    required String category,
    required String completedActivity,
    required int exerciseTime,
    required int steps,
    required int heartbeat,
    required int calories, required String progressMessage,
  }) async {
    try {
      final random = Random();
      final progressData = {
        'activeCalories': 50 + random.nextInt(151), // 50-200 calories
        'steps': 1000 + random.nextInt(2001), // 1000-3000 steps
        'exerciseTime': exerciseTime.toDouble(),
        'heartRate': 60 + random.nextInt(61), // 60-120 bpm
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(DateTime.now().toIso8601String().split('T')[0])
          .set(progressData, SetOptions(merge: true));

      print('User progress updated with random data successfully');
    } catch (e) {
      print('Failed to update user progress with random data: $e');
      throw Exception('Failed to update user progress with random data: $e');
    }
  }

  Future<void> updateUserProgressMap(String userId, String activity, bool completed) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'progressMap': {activity: completed}
    }, SetOptions(merge: true));
  }

  // Notification Methods
  /// Saves the user's FCM token to Firestore
  Future<void> saveUserFCMToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _db.collection('notifications').doc(userId).collection('notifications').doc(userId).update({'fcmToken': token});
        print('FCM Token saved successfully');
      }
    } catch (e) {
      print('Failed to save FCM token: $e');
      throw Exception('Failed to save FCM token: $e');
    }
  }

  /// Adds a new notification to Firestore
  Future<void> addNotification(String userId, String title, String message) async {
    try {
      await _db.collection('notifications').doc(userId).collection('notifications').add({
        'title': title,
        'message': message,
        'time': FieldValue.serverTimestamp(),
        'read': false,
      });
      print('Notification added successfully');
    } catch (e) {
      print('Failed to add notification: $e');
      throw Exception('Failed to add notification: $e');
    }
  }
  /// Retrieves notifications for a user
   Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc.data())) // Extract data
            .toList());
   }

  /// Marks a notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
      print('Notification marked as read');
    } catch (e) {
      print('Failed to mark notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Updates user progress with calculated data based on video watch time
  Future<void> updateUserProgressWithVideoData({
    required String userId,
    required String category,
    required String completedActivity,
    required int watchTimeInSeconds,
  }) async {
    try {
      // Calculate progress data based on watch time
      final progressData = _calculateProgressData(watchTimeInSeconds);

      // Update Firestore
      await _db
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(DateTime.now().toIso8601String().split('T')[0])
          .set(progressData, SetOptions(merge: true));

      print('User progress updated with video data:');
      print('Watch Time: ${progressData['exerciseTime']} minutes');
      print('Calories Burned: ${progressData['activeCalories']}');
      print('Steps: ${progressData['steps']}');
      print('Average Heart Rate: ${progressData['heartRate']} bpm');

    } catch (e) {
      print('Failed to update user progress with video data: $e');
      throw Exception('Failed to update user progress with video data: $e');
    }
  }

  Map<String, dynamic> _calculateProgressData(int watchTimeInSeconds) {
    final random = Random();
    final watchTimeInMinutes = watchTimeInSeconds / 60;

    // Calculate calories burned (rough estimate)
    final caloriesBurned = watchTimeInMinutes * 3; // Assuming 3 calories per minute

    // Estimate steps (very rough estimate)
    final steps = watchTimeInMinutes * 50; // Assuming 50 steps per minute

    // Generate a random heart rate between 60 and 120 bpm
    final heartRate = 60 + random.nextInt(61);

    return {
      'exerciseTime': watchTimeInMinutes.round(),
      'activeCalories': caloriesBurned.round(),
      'steps': steps.round(),
      'heartRate': heartRate,
    };
  }

  // Sleep Methods
  /// Saves sleep data to Firestore.
  Future<void> saveSleepData(String userId, String name,String email,DateTime bedtime, DateTime wakeTime, int quality) async {
    try {
      final duration = wakeTime.difference(bedtime).inHours.toDouble();
      await _db.collection('sleep').doc(userId).collection('sleep_data').add({
        'bedtime': bedtime,
        'wakeTime': wakeTime,
        'duration': duration,
        'quality': quality,
        'date': DateTime.now(), // Store the current date
        'name': name, // Add user's name
        'email': email, // Add user's email
      });
      print('Sleep data saved successfully');
    } catch (e) {
      print('Failed to save sleep data: $e');
      throw Exception('Failed to save sleep data: $e');
    }
  }

  /// Retrieves sleep data for a specific user.
  Future<List<Map<String, dynamic>>> getSleepData(String userId) async {
    try {
      final snapshot = await _db.collection('sleep').doc(userId).collection('sleep_data').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Failed to get sleep data: $e');
      throw Exception('Failed to get sleep data: $e');
    }
  }

  /// Deletes a specific sleep entry.
  Future<void> deleteSleepData(String userId, String sleepId) async {
    try {
      await _db.collection('sleep').doc(userId).collection('sleep_data').doc(sleepId).delete();
      print('Sleep data deleted successfully');
    } catch (e) {
      print('Failed to delete sleep data: $e');
      throw Exception('Failed to delete sleep data: $e');
    }
  }

  /// Updates a specific sleep entry.
  Future<void> updateSleepData(String userId, String sleepId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('sleep').doc(userId).collection('sleep_data').doc(sleepId).update(updates);
      print('Sleep data updated successfully');
    } catch (e) {
      print('Failed to update sleep data: $e');
      throw Exception('Failed to update sleep data: $e');
    }
  }

  

  // Method to save activity data
  Future<void> saveActivityData(String userId, List<double> activityData) async {
    try {
      await _db.collection('activityData').doc(userId).set({
        'activity': activityData,
      }, SetOptions(merge: true)); // Use merge to update existing data
      print('Activity data saved successfully');
    } catch (e) {
      print('Error saving activity data: $e');
      throw Exception('Failed to save activity data: $e');
    }
  }

  // Method to get activity data
  Future<List<double>> getActivityData(String userId) async {
    try {
      final snapshot = await _db.collection('activityData').doc(userId).get();

      if (snapshot.exists) {
        return List<double>.from(snapshot.data()?['activity'] ?? []);
      } else {
        throw Exception('Activity data not found');
      }
    } catch (e) {
      print('Error fetching activity data: $e');
      rethrow;
    }
  }

  /// Retrieves user progress data for a specific user.
  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_progress') // Ensure this is the correct collection name
          .doc('DZ1znac7dnfXl2n9cNaKeJFlLak2') // Use the correct document ID
          .get();

      if (snapshot.exists) {
        return UserProgress(
          activeCalories: snapshot.data()?['activeCalories'] ?? 0,
          steps: snapshot.data()?['steps'] ?? 0,
          heartRate: snapshot.data()?['heartrate'] ?? 0,
          exerciseTime: snapshot.data()?['exerciseTime'] ?? 0,
        );
      } else {
        print('User progress not found for userId: $userId');
        throw Exception('User progress not found');
      }
    } catch (e) {
      print('Error fetching user progress: $e');
      rethrow; // Rethrow the error for handling in the UI
    }
  }

  /// Stores the BMI value for a user.
  Future<void> storeBMI(String userId, double bmi) async {
    try {
      await _db.collection('user_bmi').doc(userId).set({
        'bmi': bmi,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to update existing data
      print('BMI stored successfully');
    } catch (e) {
      print('Failed to store BMI: $e');
      throw Exception('Failed to store BMI: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBMHistory(String userId) async {
    try {
        // Fetch the user document from Firestore
        DocumentSnapshot doc = await _db.collection('user_bmi').doc(userId).get();
        
        // Check if the document exists
        if (doc.exists) {
            // Extract the bmi_history array
            List<dynamic> bmiHistory = (doc.data() as Map<String, dynamic>)['bmi_history'] ?? [];
            
            // Convert the dynamic list to a list of timestamps with proper type handling
            List<Timestamp> timestamps = bmiHistory.map((item) {
                if (item['timestamp'] is String) {
                    // Convert String to Timestamp if necessary
                    return Timestamp.fromMillisecondsSinceEpoch(int.parse(item['timestamp']));
                } else if (item['timestamp'] is Timestamp) {
                    return item['timestamp'];
                } else {
                    // Handle null or unexpected types
                    return null; // or throw an error
                }
            }).where((timestamp) => timestamp != null).cast<Timestamp>().toList();
            
            // Convert the dynamic list to a list of maps
            return bmiHistory.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
            print('No BMI history found for user: $userId');
            return [];
        }
    } catch (e) {
        print('Failed to retrieve BMI history: $e');
        throw Exception('Failed to retrieve BMI history: $e');
    }
  }

  // Payment Status Methods
  /// Stores the payment status for a user
  Future<void> storePaymentStatus(String userId, bool hasPaid) async {
    try {
      await _db.collection('user_payments').doc(userId).set({
        'hasPaid': hasPaid,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('Payment status stored successfully');
    } catch (e) {
      print('Error storing payment status: $e');
      throw Exception('Failed to store payment status: $e');
    }
  }

  /// Retrieves the payment status for a user
  Future<bool> getPaymentStatus(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('user_payments').doc(userId).get();
      if (doc.exists) {
        return doc.get('hasPaid') as bool;
      } else {
        return false; // Default to not paid if no record exists
      }
    } catch (e) {
      print('Error getting payment status: $e');
      throw Exception('Failed to get payment status: $e');
    }
  }

  /// Retrieves all users and their payment status
  Future<List<Map<String, dynamic>>> getAllUsersPaymentStatus() async {
    try {
      QuerySnapshot snapshot = await _db.collection('user_payments').get();
      return snapshot.docs.map((doc) {
        return {
          'userId': doc.id,
          'hasPaid': doc.get('hasPaid') as bool,
          'lastUpdated': doc.get('lastUpdated') as Timestamp,
        };
      }).toList();
    } catch (e) {
      print('Error getting all users payment status: $e');
      throw Exception('Failed to get all users payment status: $e');
    }
  }

  Future<void> updatePaymentStatus(String userId, bool hasPaid, String planName, double price, DateTime startDate, DateTime endDate) async {
    try {
      final userDoc = await _db.collection('data').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      await _db.collection('user_payments').doc(userId).set({
        'name': userData['name'],
        'email': userData['email'],
        'hasPaid': hasPaid,
        'currentPlan': planName,
        'lastUpdated': FieldValue.serverTimestamp(),
        'subscriptionDetails': {
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'price': price,
        },
      }, SetOptions(merge: true));
      print('Payment status updated successfully');
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Failed to update payment status: $e');
    }
  }

  Future<List<UserPaymentDetails>> getAllUsersPaymentDetails() async {
    try {
      List<UserPaymentDetails> usersPaymentDetails = [];

      // First, try to fetch from 'data' collection
      QuerySnapshot dataSnapshot = await _db.collection('data').get();
      for (var doc in dataSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        String userId = doc.id;

        // Try to fetch payment details from 'user_payments' collection
        DocumentSnapshot paymentDoc = await _db.collection('user_payments').doc(userId).get();
        Map<String, dynamic> paymentData = paymentDoc.data() as Map<String, dynamic>? ?? {};

        Map<String, dynamic> subscriptionDetails = paymentData['subscriptionDetails'] ?? {};

        UserPaymentDetails userPaymentDetails = UserPaymentDetails(
          userId: userId,
          hasPaid: paymentData['hasPaid'] ?? false,
          lastUpdated: paymentData['lastUpdated'] ?? Timestamp.now(),
          currentPlan: paymentData['currentPlan'] ?? 'N/A',
          name: userData['name'] ?? 'Unknown',
          email: userData['email'] ?? 'No email',
          plan: paymentData['currentPlan'] ?? 'N/A',
          price: subscriptionDetails['price']?.toDouble() ?? 0.0,
          
          id: userId,
          subscriptionDetails: subscriptionDetails,
        );

        usersPaymentDetails.add(userPaymentDetails);
      }

      return usersPaymentDetails;
    } catch (e) {
      print('Error getting all users payment details: $e');
      throw Exception('Failed to get all users payment details: $e');
    }
  }

  Future<List<UserPaymentDetails>> fetchPaidUsers() async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('user_payments');
      final querySnapshot = await usersRef.get();
      
      print('Number of documents found: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        print('No paid users found');
        return [];
      }
      
      List<UserPaymentDetails> paidUsers = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final userId = doc.id;
        
        print('Raw user data: $data'); // Debug print
        
        Map<String, dynamic> subscriptionDetails = {};
        if (data['subscriptionDetails'] is Map) {
          subscriptionDetails = Map<String, dynamic>.from(data['subscriptionDetails'] ?? {});
        } else if (data['subscriptionDetails'] is List) {
          var subDetailsList = data['subscriptionDetails'] as List;
          if (subDetailsList.isNotEmpty) {
            subscriptionDetails = Map<String, dynamic>.from(subDetailsList.first);
          }
        }
        
        try {
          // Extract start and end dates
          DateTime? startDate;
          DateTime? endDate;

          if (subscriptionDetails.containsKey('startDate')) {
            startDate = _parseDateTime(subscriptionDetails['startDate']);
          }
          if (subscriptionDetails.containsKey('endDate')) {
            endDate = _parseDateTime(subscriptionDetails['endDate']);
          }

          paidUsers.add(UserPaymentDetails(
            id: userId,
            name: data['name']?.toString() ?? 'Unknown',
            email: data['email']?.toString() ?? 'No email',
            hasPaid: data['hasPaid'] as bool,
            currentPlan: data['currentPlan']?.toString() ?? 'Basic',
            lastUpdated: _parseDateTime(data['lastUpdated']) != null ? Timestamp.fromDate(_parseDateTime(data['lastUpdated'])!) : null,
            subscriptionDetails: subscriptionDetails,
            plan: data['currentPlan']?.toString() ?? 'Basic',
            price: subscriptionDetails['price']?.toDouble() ?? 0.0,
            userId: userId,
            startDate: startDate != null ? Timestamp.fromDate(startDate) : null,
            endDate: endDate != null ? Timestamp.fromDate(endDate) : null,
          ));
        } catch (e) {
          print('Error processing user $userId: $e');
          continue;
        }
      }
      
      print('Number of paid users processed: ${paidUsers.length}');
      return paidUsers;
    } catch (e) {
      print('Error fetching paid users: $e');
      return [];
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
