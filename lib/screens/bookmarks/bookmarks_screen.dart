import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_theme.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/service_card.dart';
import '../detail/listing_detail_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedAsync = ref.watch(bookmarkedListingsProvider);
    final bookmarkIds     = ref.watch(bookmarkIdsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('Bookmarks',
                    style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 13)),
                const SizedBox(width: 8),
                // Toggle all bookmarks visibility (simulated)
                Consumer(builder: (_, ref, __) {
                  final isOn = bookmarkIds.isNotEmpty;
                  return Switch(
                    value: isOn,
                    onChanged: null, // visual only — toggled per item
                    activeColor: AppColors.accent,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      body: bookmarkedAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
            child: Text(e.toString(),
                style: const TextStyle(color: AppColors.error))),
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_outlined,
                      color: AppColors.textMuted, size: 64),
                  SizedBox(height: 16),
                  Text('No bookmarks yet',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Tap the bookmark icon on any service to save it.',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final l = listings[i];
              return ServiceCard(
                listing: l,
                isBookmarked: bookmarkIds.contains(l.id),
                onBookmarkToggle: () =>
                    ref.read(bookmarkNotifierProvider.notifier).toggle(l.id),
                onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listing: l))),
              );
            },
          );
        },
      ),
    );
  }
}