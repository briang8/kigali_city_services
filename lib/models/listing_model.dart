import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a service or place listing stored in Firestore
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
  });

  // Build ListingModel from a Firestore document snapshot
  factory ListingModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      placeName: data['placeName'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      address: data['address'] as String? ?? '',
      contactNumber: data['contactNumber'] as String? ?? '',
      description: data['description'] as String? ?? '',
      latitude:
          (data['latitude'] as num?)?.toDouble() ?? -1.9441,
      longitude:
          (data['longitude'] as num?)?.toDouble() ?? 30.0619,
      createdBy: data['createdBy'] as String? ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  // Convert to a Firestore-compatible map for write operations
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
      };

  // Return a new instance with only the specified fields changed
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
  }) {
    return ListingModel(
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
    );
  }
}