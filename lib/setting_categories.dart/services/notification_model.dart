import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class NotificationModel {
    final String id;
    final String message;
    final DateTime timestamp;

    NotificationModel({
        required this.id,
        required this.message,
        required this.timestamp,
    });

    // Factory method to create a NotificationModel from a Firestore document
    factory NotificationModel.fromFirestore(Map<String, dynamic> data) {
        return NotificationModel(
            id: data['id'] ?? '',
            message: data['message'] ?? '',
            timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
    }
}
