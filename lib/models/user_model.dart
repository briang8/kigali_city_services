import 'package:cloud_firestore/cloud_firestore.dart';

// Represents an authenticated user profile stored in Firestore
class UserModel {
  final String uid;
  final String email;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
  });

  // Build UserModel from a Firestore document map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to a Firestore-compatible map for write operations
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}