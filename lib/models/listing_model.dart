import 'package:cloud_firestore/cloud_firestore.dart';

// ── ListingModel ─────────────────────────────────────────────────────────────
class ListingModel {
  final String id;
  final String placeName;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;
  final double rating;
  final int reviewCount;
  // false = seeded Kigali data, true = added by an app user
  final bool isUserAdded;

  const ListingModel({
    required this.id,
    required this.placeName,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isUserAdded = false,
  });

  factory ListingModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      placeName: d['placeName'] as String? ?? '',
      category: d['category'] as String? ?? 'Other',
      address: d['address'] as String? ?? '',
      contactNumber: d['contactNumber'] as String? ?? '',
      description: d['description'] as String? ?? '',
      latitude: (d['latitude'] as num?)?.toDouble() ?? -1.9441,
      longitude: (d['longitude'] as num?)?.toDouble() ?? 30.0619,
      createdBy: d['createdBy'] as String? ?? '',
      timestamp: d['timestamp'] != null
          ? (d['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0,
      isUserAdded: d['isUserAdded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'placeName': placeName,
        'category': category,
        'address': address,
        'contactNumber': contactNumber,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'createdBy': createdBy,
        'timestamp': Timestamp.fromDate(timestamp),
        'rating': rating,
        'reviewCount': reviewCount,
        'isUserAdded': isUserAdded,
      };

  ListingModel copyWith({
    String? id,
    String? placeName,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
    double? rating,
    int? reviewCount,
    bool? isUserAdded,
  }) =>
      ListingModel(
        id: id ?? this.id,
        placeName: placeName ?? this.placeName,
        category: category ?? this.category,
        address: address ?? this.address,
        contactNumber: contactNumber ?? this.contactNumber,
        description: description ?? this.description,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        createdBy: createdBy ?? this.createdBy,
        timestamp: timestamp ?? this.timestamp,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        isUserAdded: isUserAdded ?? this.isUserAdded,
      );
}

// ── ReviewModel ──────────────────────────────────────────────────────────────
class ReviewModel {
  final String id;
  final String uid;
  final String userName;
  final int stars;
  final String comment;
  final DateTime timestamp;

  const ReviewModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.stars,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      uid: d['uid'] as String? ?? '',
      userName: d['userName'] as String? ?? 'Anonymous',
      stars: (d['stars'] as num?)?.toInt() ?? 0,
      comment: d['comment'] as String? ?? '',
      timestamp: d['timestamp'] != null
          ? (d['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'userName': userName,
        'stars': stars,
        'comment': comment,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
