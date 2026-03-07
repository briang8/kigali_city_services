import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';
import 'auth_provider.dart';

// ── Service singleton ─────────────────────────────────────────────────────
final listingServiceProvider =
    Provider<ListingService>((_) => ListingService());

// ── All listings stream ───────────────────────────────────────────────────
final allListingsStreamProvider = StreamProvider<List<ListingModel>>(
    (ref) => ref.watch(listingServiceProvider).streamAllListings());

// ── User listings stream ──────────────────────────────────────────────────
// Sorted in Dart (not Firestore) to avoid requiring a composite index on
// [createdBy + timestamp] which would need manual Firestore console setup.
final userListingsStreamProvider = StreamProvider<List<ListingModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(listingServiceProvider).streamUserListings(uid).map((list) {
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  });
});

// ── Category filter ───────────────────────────────────────────────────────
class _CategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void set(String v) => state = v;
}

final selectedCategoryProvider =
    NotifierProvider<_CategoryNotifier, String>(_CategoryNotifier.new);

// ── Search query ──────────────────────────────────────────────────────────
class _SearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final searchQueryProvider =
    NotifierProvider<_SearchNotifier, String>(_SearchNotifier.new);

// ── Filtered derived provider ─────────────────────────────────────────────
final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final all = ref.watch(allListingsStreamProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return all.whenData((listings) => listings.where((l) {
        final matchCat = category == 'All' || l.category == category;
        final matchSearch = query.isEmpty ||
            l.placeName.toLowerCase().contains(query) ||
            l.address.toLowerCase().contains(query) ||
            l.category.toLowerCase().contains(query);
        return matchCat && matchSearch;
      }).toList());
});

// ── CRUD notifier ─────────────────────────────────────────────────────────
class ListingNotifier extends AsyncNotifier<void> {
  ListingService get _svc => ref.read(listingServiceProvider);
  String get _uid => ref.read(currentUidProvider);

  @override
  Future<void> build() async {}

  Future<bool> createListing(ListingModel listing) async {
    if (_uid.isEmpty) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _svc.createListing(
        listing.copyWith(createdBy: _uid, timestamp: DateTime.now())));
    return !state.hasError;
  }

  // Seed listings (createdBy == 'seed') are editable/deletable by any
  // signed-in user so coordinates and stale data can be corrected.
  bool _canModify(ListingModel listing) =>
      _uid.isNotEmpty &&
      (listing.createdBy == _uid || listing.createdBy == 'seed');

  Future<bool> updateListing(ListingModel listing) async {
    if (!_canModify(listing)) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _svc.updateListing(listing));
    return !state.hasError;
  }

  Future<bool> deleteListing(ListingModel listing) async {
    if (!_canModify(listing)) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _svc.deleteListing(listing.id));
    return !state.hasError;
  }

  void resetState() => state = const AsyncData(null);
}

final listingNotifierProvider =
    AsyncNotifierProvider<ListingNotifier, void>(ListingNotifier.new);

// ── Reviews stream ────────────────────────────────────────────────────────
final reviewsStreamProvider = StreamProvider.family<List<ReviewModel>, String>(
    (ref, listingId) =>
        ref.watch(listingServiceProvider).streamReviews(listingId));

// ── Review submission notifier ────────────────────────────────────────────
class ReviewNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit({
    required String listingId,
    required int stars,
    required String comment,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid.isEmpty) return false;

    // Guard against duplicate reviews before showing loading state
    final already =
        await ref.read(listingServiceProvider).hasUserReviewed(listingId, uid);
    if (already) return false;

    state = const AsyncLoading();

    final profile = await ref.read(userProfileProvider(uid).future);
    final name = (profile?.displayName.isNotEmpty == true)
        ? profile!.displayName
        : 'Anonymous';

    state =
        await AsyncValue.guard(() => ref.read(listingServiceProvider).addReview(
              listingId: listingId,
              review: ReviewModel(
                id: '',
                uid: uid,
                userName: name,
                stars: stars,
                comment: comment,
                timestamp: DateTime.now(),
              ),
            ));
    return !state.hasError;
  }

  void reset() => state = const AsyncData(null);
}

final reviewNotifierProvider =
    AsyncNotifierProvider<ReviewNotifier, void>(ReviewNotifier.new);

// ── Bookmark IDs stream ───────────────────────────────────────────────────
final bookmarkIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(listingServiceProvider).streamBookmarkIds(uid);
});

// ── Bookmark toggle notifier ──────────────────────────────────────────────
class BookmarkNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(String listingId) async {
    final uid = ref.read(currentUidProvider);
    if (uid.isEmpty) return;
    final svc = ref.read(listingServiceProvider);
    final ids = ref.read(bookmarkIdsProvider).valueOrNull ?? [];
    if (ids.contains(listingId)) {
      await svc.removeBookmark(uid, listingId);
    } else {
      await svc.addBookmark(uid, listingId);
    }
  }
}

final bookmarkNotifierProvider =
    NotifierProvider<BookmarkNotifier, void>(BookmarkNotifier.new);

// ── Bookmarked listings (derived) ─────────────────────────────────────────
final bookmarkedListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final ids = ref.watch(bookmarkIdsProvider);
  final all = ref.watch(allListingsStreamProvider);

  return all.whenData((listings) {
    final idSet = ids.valueOrNull?.toSet() ?? {};
    return listings.where((l) => idSet.contains(l.id)).toList();
  });
});
