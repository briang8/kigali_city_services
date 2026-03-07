import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/listing_model.dart';

// ── ServiceCard ───────────────────────────────────────────────────────────────
// Matches screenshot: name, star row, distance/review count, trailing bookmark
class ServiceCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final Widget? trailing;

  const ServiceCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmarkToggle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Category icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoryIcon(listing.category),
                  color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),

            // Name + stars + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + rating number on same row
                  Row(
                    children: [
                      Expanded(
                        child: Text(listing.placeName,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (listing.rating > 0) ...[
                        const SizedBox(width: 6),
                        Text(listing.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                color: AppColors.starColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const Icon(Icons.star,
                            color: AppColors.starColor, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Star row
                  StarRow(rating: listing.rating, size: 14),
                  const SizedBox(height: 4),
                  // Address / review count
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textMuted, size: 12),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(listing.address,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (listing.reviewCount > 0) ...[
                        const SizedBox(width: 6),
                        Text('${listing.reviewCount} reviews',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Bookmark or custom trailing
            const SizedBox(width: 8),
            if (trailing != null)
              trailing!
            else
              GestureDetector(
                onTap: onBookmarkToggle,
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border_outlined,
                  color: isBookmarked ? AppColors.accent : AppColors.textMuted,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital_outlined;
      case 'Police Station':
        return Icons.local_police_outlined;
      case 'Library':
        return Icons.local_library_outlined;
      case 'Restaurant':
        return Icons.restaurant_outlined;
      case 'Cafe':
        return Icons.local_cafe_outlined;
      case 'Park':
        return Icons.park_outlined;
      case 'Tourist Attraction':
        return Icons.attractions_outlined;
      case 'Pharmacy':
        return Icons.local_pharmacy_outlined;
      case 'Bank':
        return Icons.account_balance_outlined;
      case 'School':
        return Icons.school_outlined;
      case 'Hotel':
        return Icons.hotel_outlined;
      case 'Market':
        return Icons.storefront_outlined;
      case 'Government Office':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.place_outlined;
    }
  }
}

// ── StarRow ───────────────────────────────────────────────────────────────────
class StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const StarRow({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icon;
        if (i < rating.floor()) {
          icon = Icons.star;
        } else if (i < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: AppColors.starColor, size: size);
      }),
    );
  }
}
