import 'package:cloud_firestore/cloud_firestore.dart';

// Represents an authenticated user profile stored in Firestore
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  // Build UserModel from a Firestore document snapshot
  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: d['email'] as String? ?? '',
      displayName: d['displayName'] as String? ?? '',
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Build UserModel from a plain map (e.g. Firestore data() cast)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to a Firestore-compatible map for write operations
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
