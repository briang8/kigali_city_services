import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../data/kigali_seed_data.dart';

class ListingService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('listings');

  // ── Seed ──────────────────────────────────────────────────────────────────
  /// Syncs the dart-file seed data with Firestore on every verified login.
  ///
  /// Rules:
  ///  - New entries in the dart file → written to Firestore (deterministic IDs).
  ///  - Entries removed from the dart file → deleted from Firestore.
  ///  - Entries already in Firestore are left untouched so app-side edits
  ///    (coordinates, description, etc.) are never overwritten.
  ///  - App-deleted seed listings stay deleted (we don't re-create them).
  Future<void> seedIfEmpty() async {
    try {
      // Expected IDs for the current dart file.
      final expectedIds = List.generate(
        KigaliSeedData.listings.length,
        (i) => 'seed_$i',
      );

      // Check a generous range to catch stale docs from old dart file versions
      // (e.g. if the file previously had 19 entries and now has 14, we need
      // to find and delete seed_14 through seed_18).
      final checkIds = List.generate(
        KigaliSeedData.listings.length + 20,
        (i) => 'seed_$i',
      );

      // Parallel doc-ID fetch — works regardless of isUserAdded value, so
      // app-edited seed docs (isUserAdded: true) are correctly detected.
      final snaps = await Future.wait(checkIds.map((id) => _col.doc(id).get()));
      final existingIds = {
        for (final s in snaps)
          if (s.exists) s.id
      };

      final expectedSet = expectedIds.toSet();
      // IDs in Firestore but no longer in the dart file → delete.
      final toDelete = existingIds.difference(expectedSet);
      // IDs in the dart file but missing from Firestore → create.
      final toCreate = expectedSet.difference(existingIds);

      // Nothing to do — dart file and Firestore are in sync.
      if (toDelete.isEmpty && toCreate.isEmpty) return;

      final batch = _db.batch();

      // Remove stale seed docs.
      for (final id in toDelete) {
        batch.delete(_col.doc(id));
      }

      // Write only the missing entries; existing ones are never touched.
      for (int i = 0; i < KigaliSeedData.listings.length; i++) {
        final docId = 'seed_$i';
        if (!toCreate.contains(docId)) continue;

        final listing = KigaliSeedData.listings[i];
        final ref = _col.doc(docId);
        batch.set(ref, listing.toMap());
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
        .get(const GetOptions(source: Source.server));
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
