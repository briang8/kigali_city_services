import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../data/kigali_seed_data.dart';

class ListingService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('listings');

  // ── Seed ──────────────────────────────────────────────────────────────────
  /// Writes the pre-built Kigali city data to Firestore.
  /// Uses deterministic document IDs so it is safe to call on every login.
  /// If the full set is already present it exits after a single read.
  /// If data is partially missing it cleans up orphans and re-seeds.
  Future<void> seedIfEmpty() async {
    try {
      final snap = await _col.where('isUserAdded', isEqualTo: false).get();

      // All seed listings are present — nothing to do.
      if (snap.docs.length >= KigaliSeedData.listings.length) return;

      final batch = _db.batch();

      // Delete any orphaned partial-seed docs so we start clean.
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }

      // Re-seed with deterministic IDs so re-runs are always safe.
      // Firestore batch limit is 500 ops; seed is ~80 ops — well within limit.
      for (int i = 0; i < KigaliSeedData.listings.length; i++) {
        final listing = KigaliSeedData.listings[i];
        final ref = _col.doc('seed_$i');
        batch.set(ref, listing.toMap());

        final reviews = KigaliSeedData.dummyReviews[listing.placeName];
        if (reviews != null) {
          for (int j = 0; j < reviews.length; j++) {
            final r = reviews[j];
            final rRef = ref.collection('reviews').doc('seed_${i}_r_$j');
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
