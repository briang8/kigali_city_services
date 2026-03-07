import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../data/kigali_seed_data.dart';

class ListingService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('listings');

  // ── Seed ──────────────────────────────────────────────────────────────────
  /// Writes the pre-built Kigali city data to Firestore exactly once.
  /// Safe to call multiple times — returns immediately if data exists.
  Future<void> seedIfEmpty() async {
    try {
      // Only check for seed listings (isUserAdded: false).
      // User-added listings must NOT prevent seeding.
      final snap =
          await _col.where('isUserAdded', isEqualTo: false).limit(1).get();
      if (snap.docs.isNotEmpty) return;

      // Firestore batch limit is 500 operations.
      // Our seed has ~20 listings × ~3 reviews = ~80 ops — well within limit.
      final batch = _db.batch();
      for (final listing in KigaliSeedData.listings) {
        final ref = _col.doc();
        batch.set(ref, listing.toMap());

        final reviews = KigaliSeedData.dummyReviews[listing.placeName];
        if (reviews != null) {
          for (final r in reviews) {
            final rRef = ref.collection('reviews').doc();
            batch.set(rRef, {
              'uid': 'seed',
              'userName': r['userName'],
              'stars': r['stars'],
              'comment': r['comment'],
              'timestamp': Timestamp.fromDate(
                DateTime.now().subtract(Duration(days: r['daysAgo'] as int)),
              ),
            });
          }
        }
      }
      await batch.commit();
    } catch (_) {
      // Seed failure is non-fatal — app works without seed data
    }
  }

  // ── Stream all listings ───────────────────────────────────────────────────
  Stream<List<ListingModel>> streamAllListings() => _col
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ListingModel.fromDoc).toList());

  // ── Stream listings by user ───────────────────────────────────────────────
  // Uses only .where() — NO .orderBy() — to avoid needing a composite index.
  // Sorting is done in Dart inside listing_provider.dart.
  Stream<List<ListingModel>> streamUserListings(String uid) => _col
      .where('createdBy', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(ListingModel.fromDoc).toList());

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<void> createListing(ListingModel listing) => _col.add(listing.toMap());

  Future<void> updateListing(ListingModel listing) =>
      _col.doc(listing.id).update(listing.toMap());

  Future<void> deleteListing(String id) => _col.doc(id).delete();

  // ── Reviews ───────────────────────────────────────────────────────────────
  Stream<List<ReviewModel>> streamReviews(String listingId) => _col
      .doc(listingId)
      .collection('reviews')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ReviewModel.fromDoc).toList());

  /// Atomically adds a review and updates the listing's aggregate rating.
  Future<void> addReview({
    required String listingId,
    required ReviewModel review,
  }) async {
    final listingRef = _col.doc(listingId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(listingRef);
      final data = snap.data()!;
      final oldRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final oldCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
      final newCount = oldCount + 1;
      final newRating = ((oldRating * oldCount) + review.stars) / newCount;

      tx.update(listingRef, {
        'rating': newRating,
        'reviewCount': newCount,
      });
      tx.set(listingRef.collection('reviews').doc(), review.toMap());
    });
  }

  /// Returns true if the given user has already submitted a review.
  Future<bool> hasUserReviewed(String listingId, String uid) async {
    final snap = await _col
        .doc(listingId)
        .collection('reviews')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────
  // Stored at: users/{uid}/bookmarks/{listingId}
  Stream<List<String>> streamBookmarkIds(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('bookmarks')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toList());

  Future<void> addBookmark(String uid, String listingId) => _db
      .collection('users')
      .doc(uid)
      .collection('bookmarks')
      .doc(listingId)
      .set({'addedAt': FieldValue.serverTimestamp()});

  Future<void> removeBookmark(String uid, String listingId) => _db
      .collection('users')
      .doc(uid)
      .collection('bookmarks')
      .doc(listingId)
      .delete();
}
