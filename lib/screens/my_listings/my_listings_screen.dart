import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_theme.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/service_card.dart';
import '../detail/listing_detail_screen.dart';
import '../directory/add_listing_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(userListingsStreamProvider);
    final uid           = ref.watch(currentUidProvider);

    return Scaffold(
      appBar: AppBar(
          title: const Text('My Listings'),
          automaticallyImplyLeading: false),
      body: listingsAsync.when(
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
                  Icon(Icons.list_alt_outlined,
                      color: AppColors.textMuted, size: 64),
                  SizedBox(height: 16),
                  Text('No listings yet',
                      style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Tap + to add your first service listing.',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final l = listings[i];
              return ServiceCard(
                listing: l,
                onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listing: l))),
                trailing: uid == l.createdBy
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.accent, size: 20),
                            onPressed: () => Navigator.of(ctx).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AddListingScreen(listing: l))),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () => _confirmDelete(ctx, ref, l),
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'my_listings_add',
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddListingScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Service',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, ListingModel l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Listing',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${l.placeName}"? This cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(listingNotifierProvider.notifier).deleteListing(l);
    }
  }
}