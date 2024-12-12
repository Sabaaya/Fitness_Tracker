import 'package:cloud_firestore/cloud_firestore.dart';

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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }
}

