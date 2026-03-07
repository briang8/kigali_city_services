import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/listing_model.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/service_card.dart';
import '../../widgets/category_chip_bar.dart';
import '../detail/listing_detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late MapController _mapCtrl;
  ListingModel? _selected;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
  }

  void _onMarkerTap(ListingModel l) {
    setState(() => _selected = l);
    // Defer camera move until after current frame to ensure the map widget
    // is fully mounted — prevents "move() called before map rendered" crash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapCtrl.move(LatLng(l.latitude, l.longitude), AppConstants.detailZoom);
      }
    });
  }

  void _fitAll(List<ListingModel> list) {
    if (list.isEmpty) return;
    double minLat = list.first.latitude, maxLat = list.first.latitude;
    double minLng = list.first.longitude, maxLng = list.first.longitude;
    for (final l in list) {
      minLat = math.min(minLat, l.latitude);
      maxLat = math.max(maxLat, l.latitude);
      minLng = math.min(minLng, l.longitude);
      maxLng = math.max(maxLng, l.longitude);
    }
    _mapCtrl.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(filteredListingsProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CategoryChipBar(
              categories: AppConstants.categories,
              selected: selectedCat,
              onSelected: (c) =>
                  ref.read(selectedCategoryProvider.notifier).set(c),
            ),
          ),

          Expanded(
            child: listingsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(
                  child: Text(e.toString(),
                      style: const TextStyle(color: AppColors.error))),
              data: (listings) => Stack(
                children: [
                  // ── Map ────────────────────────────────────────────
                  FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: LatLng(
                          AppConstants.kigaliLat, AppConstants.kigaliLng),
                      initialZoom: AppConstants.defaultZoom,
                      maxZoom: 18,
                      // NO minZoom — setting minZoom causes flutter_map to
                      // cancel tile HTTP requests via AbortController on
                      // Flutter Web, crashing BrowserClient (line 80 of
                      // browser_client.dart). Removing it prevents all abort
                      // calls during zoom-out.
                      onTap: (_, __) => setState(() => _selected = null),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.kigali.kigali_city_services',
                        maxNativeZoom: 19,
                        // Stops flutter_map from aborting failed/out-of-range
                        // tile requests — the abort() call is what crashes
                        // BrowserClient JS interop on Flutter Web.
                        evictErrorTileStrategy: EvictErrorTileStrategy.none,
                      ),
                      MarkerLayer(
                        markers: listings.map((l) {
                          final isSel = _selected?.id == l.id;
                          return Marker(
                            point: LatLng(l.latitude, l.longitude),
                            width: isSel ? 50 : 40,
                            height: isSel ? 50 : 40,
                            child: GestureDetector(
                              onTap: () => _onMarkerTap(l),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.accentLight
                                      : AppColors.accent,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSel ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  ServiceCard.categoryIcon(l.category),
                                  color: AppColors.primaryDark,
                                  size: isSel ? 26 : 20,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // ── Selected listing card ─────────────────────────
                  if (_selected != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailScreen(listing: _selected!),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.35)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  ServiceCard.categoryIcon(_selected!.category),
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selected!.placeName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Row(children: [
                                      StarRow(
                                          rating: _selected!.rating, size: 13),
                                      if (_selected!.reviewCount > 0) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_selected!.reviewCount}'
                                          ' reviews',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ]),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.accent),
                              // Close button — plain GestureDetector, not
                              // IconButton, to avoid nested tap issues
                              GestureDetector(
                                onTap: () => setState(() => _selected = null),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.close,
                                      color: AppColors.textMuted, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── FABs — each must have a unique heroTag ────────
                  // Without unique heroTags, Flutter throws
                  // "Multiple heroes with the same tag" when navigating
                  // between screens that each contain FABs.
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'map_screen_recenter_btn',
                          onPressed: () => _mapCtrl.move(
                            LatLng(
                                AppConstants.kigaliLat, AppConstants.kigaliLng),
                            AppConstants.defaultZoom,
                          ),
                          backgroundColor: AppColors.cardBackground,
                          child: const Icon(Icons.my_location,
                              color: AppColors.accent, size: 20),
                        ),
                        if (listings.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'map_screen_fitall_btn',
                            onPressed: () => _fitAll(listings),
                            backgroundColor: AppColors.cardBackground,
                            child: const Icon(Icons.fit_screen,
                                color: AppColors.accent, size: 20),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
