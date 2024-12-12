import 'package:flutter/material.dart';
import 'package:fitness/constants/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/setting_categories.dart/services/firestore_services.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime time;
  final bool read;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<NotificationModel>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      print("Current user ID: $userId");
      _notificationsStream = FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            print("Snapshot docs length: ${snapshot.docs.length}");
            List<NotificationModel> notifications = snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList();
            
            // Add static notifications if the list is empty
            if (notifications.isEmpty) {
              notifications = _getStaticNotifications(userId);
            }
            
            return notifications;
          })
          .handleError((error) {
            print("Error in stream: $error");
            return _getStaticNotifications(user.uid);
          });
    } else {
      print("No user logged in");
      _notificationsStream = Stream.value(_getStaticNotifications('guest'));
    }
  }

  List<NotificationModel> _getStaticNotifications(String userId) {
    return [
      NotificationModel(
        id: 'static1',
        userId: userId,
        title: 'Welcome to the app!',
        message: 'Thank you for joining us.',
        time: DateTime.now(),
        read: false,
      ),
      NotificationModel(
        id: 'static2',
        userId: userId,
        title: 'New Feature Available',
        message: 'Check out our latest update!',
        time: DateTime.now().subtract(const Duration(days: 1)),
        read: false,
      ),
    ];
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, '/bottomNavigationbar'),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 4,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          print("Connection state: ${snapshot.connectionState}");
          print("Has data: ${snapshot.hasData}");
          print("Data length: ${snapshot.data?.length ?? 0}");

          if (snapshot.hasError) {
            print("Error in StreamBuilder: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<NotificationModel> notifications = snapshot.data ?? [];

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationItem(
                title: notification.title,
                message: notification.message,
                time: notification.time.toString(),
                read: notification.read,
                onTap: () => _markAsRead(notification.id),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool read;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: read ? Colors.white : Colors.blue[50],
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold, color: Colors.black)),
        subtitle: Text(message, style: const TextStyle(color: Colors.black)),
        trailing: Text(time, style: const TextStyle(color: Color.fromARGB(255, 71, 68, 68))),
        onTap: onTap,
      ),
    );
  }
}
