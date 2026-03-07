import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/service_card.dart';
import '../../widgets/category_chip_bar.dart';
import '../detail/listing_detail_screen.dart';
import '../directory/add_listing_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredListingsProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final bookmarkIds = ref.watch(bookmarkIdsProvider).valueOrNull ?? [];

    return Scaffold(
      // ── Sticky header: title + search + chips ──────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          color: AppColors.primaryDark,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city,
                          color: AppColors.accent, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Kigali City',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      // Live result count badge
                      filteredAsync.whenOrNull(
                            data: (list) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${list.length} places',
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ) ??
                          const SizedBox(),
                    ],
                  ),
                ),

                // Search bar — always visible, never scrolls away
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) =>
                        ref.read(searchQueryProvider.notifier).set(v),
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search for a service…',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textMuted, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.textMuted, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref.read(searchQueryProvider.notifier).set('');
                              })
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Horizontally scrolling category chips ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CategoryChipBar(
              categories: AppConstants.categories,
              selected: selectedCat,
              onSelected: (c) =>
                  ref.read(selectedCategoryProvider.notifier).set(c),
            ),
          ),

          // ── Section label ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Text(
              selectedCat == 'All' ? 'Near You' : selectedCat,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // ── Listings list ─────────────────────────────────────────────
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(
                  child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(e.toString(),
                    style: const TextStyle(color: AppColors.error)),
              )),
              data: (listings) {
                if (listings.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            color: AppColors.textMuted, size: 52),
                        SizedBox(height: 12),
                        Text(
                          'No services found',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Try a different category or search term',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: listings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final l = listings[i];
                    return ServiceCard(
                      listing: l,
                      isBookmarked: bookmarkIds.contains(l.id),
                      onBookmarkToggle: () => ref
                          .read(bookmarkNotifierProvider.notifier)
                          .toggle(l.id),
                      onTap: () => Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => ListingDetailScreen(listing: l),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_add_fab',
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddListingScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Service',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
      ),
    );
  }
}
