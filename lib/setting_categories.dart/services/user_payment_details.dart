import 'package:cloud_firestore/cloud_firestore.dart';

class UserPaymentDetails {
  final String id;
  final String? name;
  final String? email;
  final bool hasPaid;
  final String? currentPlan;
  final Timestamp? lastUpdated;
  final Map<String, dynamic> subscriptionDetails;
  final String? plan;
  final double? price;
  final Timestamp? startDate;
  final Timestamp? endDate;
  final DateTime? startDateDateTime;
  final DateTime? endDateDateTime;
  UserPaymentDetails({
    required this.id,
    this.name,
    this.email,
    required this.hasPaid,
    this.currentPlan,
    this.lastUpdated,
    required this.subscriptionDetails,
    this.plan,
    this.price,
    this.startDate,
    this.endDate,
    required String userId,
  }) : startDateDateTime = startDate?.toDate(),
       endDateDateTime = endDate?.toDate();
}

class SubscriptionDetails {
  final double? price;
  final Timestamp? startDate;
  final Timestamp? endDate;

  SubscriptionDetails({this.price, this.startDate, this.endDate});

  factory SubscriptionDetails.fromMap(Map<String, dynamic> map) {
    return SubscriptionDetails(
      price: map['price']?.toDouble(),
      startDate: map['startDate'],
      endDate: map['endDate'],
    );
  }
}
