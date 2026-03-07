import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/service_card.dart';
import '../directory/add_listing_screen.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState
    extends ConsumerState<ListingDetailScreen> {
  // Local copy so optimistic rating updates work without waiting for
  // Firestore to push the new value back through the stream
  late ListingModel _listing;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
  }

  void _showRatingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _RatingSheet(
        listing: _listing,
        onSubmitted: (updated) =>
            setState(() => _listing = updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid          = ref.watch(currentUidProvider);
    final isOwner      = uid.isNotEmpty && uid == _listing.createdBy;
    final bookmarkIds  =
        ref.watch(bookmarkIdsProvider).valueOrNull ?? [];
    final isBookmarked = bookmarkIds.contains(_listing.id);
    final reviewsAsync =
        ref.watch(reviewsStreamProvider(_listing.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(_listing.placeName,
            overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Bookmark toggle
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border_outlined,
              color: isBookmarked
                  ? AppColors.accent
                  : AppColors.textMuted,
            ),
            onPressed: () => ref
                .read(bookmarkNotifierProvider.notifier)
                .toggle(_listing.id),
          ),
          // Edit button — only shown to the listing creator
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textMuted),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        AddListingScreen(listing: _listing)),
              ),
            ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  _CategoryBadge(category: _listing.category),
                  const SizedBox(height: 16),

                  // Rating summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _listing.rating > 0
                              ? 'AV. ${_listing.rating.toStringAsFixed(1)} rating'
                              : 'No ratings yet',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            StarRow(
                                rating: _listing.rating, size: 20),
                            const SizedBox(width: 10),
                            if (_listing.reviewCount > 0)
                              Text(
                                  '${_listing.reviewCount} reviews',
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description / icon banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Icon(
                            ServiceCard.categoryIcon(
                                _listing.category),
                            color: AppColors.accent,
                            size: 44),
                        if (_listing.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _listing.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.5),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: _listing.address),

                  // Contact number (tappable)
                  if (_listing.contactNumber.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(
                          'tel:${_listing.contactNumber}')),
                      child: _InfoRow(
                          icon: Icons.phone_outlined,
                          text: _listing.contactNumber,
                          color: AppColors.accent),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Rate this service button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showRatingSheet,
                      child:
                          const Text('Rate this service'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location section header
                  const Text(
                    'Location',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  // Embedded map — interactions disabled so scrolling
                  // the detail page does not accidentally pan the map
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                              _listing.latitude,
                              _listing.longitude),
                          initialZoom: AppConstants.detailZoom,
                          // Disable all interaction on the detail map
                          interactionOptions:
                              const InteractionOptions(
                                  flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.kigali.kigali_city_services',
                            maxNativeZoom: 19,
                            // Prevents abort() crash on Flutter Web
                            evictErrorTileStrategy:
                                EvictErrorTileStrategy.none,
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_listing.latitude,
                                    _listing.longitude),
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white,
                                        width: 2),
                                  ),
                                  child: Icon(
                                    ServiceCard.categoryIcon(
                                        _listing.category),
                                    color: AppColors.primaryDark,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Get Directions button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(
                            'https://www.google.com/maps/dir/?api=1'
                            '&destination=${_listing.latitude},'
                            '${_listing.longitude}'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon:
                          const Icon(Icons.directions_outlined),
                      label: const Text('Get Directions'),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Reviews header
                  Row(
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      if (_listing.reviewCount > 0)
                        Text(
                          '${_listing.rating.toStringAsFixed(1)}'
                          ' · ${_listing.reviewCount} reviews',
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Reviews list
          reviewsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                      color: AppColors.accent),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Text(e.toString(),
                    style: const TextStyle(
                        color: AppColors.error)),
              ),
            ),
            data: (reviews) {
              if (reviews.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Text(
                      'No reviews yet — be the first!',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: _ReviewCard(review: reviews[i]),
                    ),
                    childCount: reviews.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Rating bottom sheet ───────────────────────────────────────────────────────
class _RatingSheet extends ConsumerStatefulWidget {
  final ListingModel listing;
  final ValueChanged<ListingModel> onSubmitted;
  const _RatingSheet(
      {required this.listing, required this.onSubmitted});

  @override
  ConsumerState<_RatingSheet> createState() =>
      _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<_RatingSheet> {
  int _stars   = 0;
  int _hovered = 0;
  final _commentCtrl = TextEditingController();
  static const _labels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent'
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) return;

    final ok = await ref
        .read(reviewNotifierProvider.notifier)
        .submit(
          listingId: widget.listing.id,
          stars: _stars,
          comment: _commentCtrl.text.trim(),
        );

    if (!mounted) return;

    if (ok) {
      // Optimistic update — adjust displayed rating immediately
      final old      = widget.listing.rating;
      final cnt      = widget.listing.reviewCount;
      final newRating = ((old * cnt) + _stars) / (cnt + 1);
      widget.onSubmitted(widget.listing.copyWith(
          rating: newRating, reviewCount: cnt + 1));
      ref.read(reviewNotifierProvider.notifier).reset();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks for your review!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('You have already reviewed this service.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(reviewNotifierProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 18),
          const Text(
            'Rate this Service',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            widget.listing.placeName,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Interactive star row with hover (web) + tap (mobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star   = i + 1;
              final active =
                  star <= (_hovered > 0 ? _hovered : _stars);
              return GestureDetector(
                onTap: () => setState(() => _stars = star),
                child: MouseRegion(
                  onEnter: (_) =>
                      setState(() => _hovered = star),
                  onExit:  (_) =>
                      setState(() => _hovered = 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5),
                    child: Icon(
                      active
                          ? Icons.star
                          : Icons.star_border,
                      color: active
                          ? AppColors.starColor
                          : AppColors.textMuted,
                      size: 44,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _stars > 0 ? _labels[_stars] : 'Tap a star to rate',
            style: TextStyle(
              color: _stars > 0
                  ? AppColors.accent
                  : AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Optional comment
          TextField(
            controller: _commentCtrl,
            style:
                const TextStyle(color: AppColors.textPrimary),
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'Write a comment (optional)',
                alignLabelWithHint: true),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed:
                (_stars == 0 || isLoading) ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryDark),
                  )
                : const Text('Submit Review'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(review.timestamp);
    final age  = diff.inDays > 0
        ? '${diff.inDays}d ago'
        : diff.inHours > 0
            ? '${diff.inHours}h ago'
            : 'Just now';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    AppColors.accent.withOpacity(0.15),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                age,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StarRow(rating: review.stars.toDouble(), size: 15),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"${review.comment}"',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ServiceCard.categoryIcon(category),
              color: AppColors.accent, size: 15),
          const SizedBox(width: 6),
          Text(
            category,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  final Color    color;
  const _InfoRow(
      {required this.icon,
      required this.text,
      this.color = AppColors.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: AppColors.textMuted, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: color, fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }
}