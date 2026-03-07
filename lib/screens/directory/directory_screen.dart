import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/listing_provider.dart';
import '../detail/listing_detail_screen.dart';
import 'add_listing_screen.dart';
import '../../widgets/service_card.dart';
import '../../widgets/category_chip_bar.dart';

// Main browsable directory with real-time search and category filtering
class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredListings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Fixed header with title and search
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              expandedHeight: 148,
              backgroundColor: AppColors.primaryDark,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kigali Services',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            ref.read(searchQueryProvider.notifier).set(val),
                        decoration: InputDecoration(
                          hintText: 'Search services, places...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CategoryChipBar(
                  categories: AppConstants.categories,
                  selected: selectedCategory,
                  onSelected: (cat) =>
                      ref.read(selectedCategoryProvider.notifier).set(cat),
                ),
              ),
            ),

            // Listings grid
            filteredListings.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: AppColors.textMuted,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No listings found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = listings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ServiceCard(
                            listing: listing,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(
                                  listing: listing,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: listings.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading listings',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        err.toString(),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AddListingScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Listing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
