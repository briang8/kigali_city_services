import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  final ListingModel? listing;
  const AddListingScreen({super.key, this.listing});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _descCtrl;

  // ── Coordinates stored as plain Dart doubles ──────────────────────────
  // NEVER use TextEditingController for lat/lng on Flutter Web.
  // Controller.text returns a JS String object, and calling .trim() on it
  // throws: "TypeError: this[...].text[$trim] is not a function"
  // Using plain doubles and updating them on map tap eliminates this crash.
  late double _lat;
  late double _lng;

  // True once the user has tapped the map (or when editing an existing listing)
  late bool _locationPinned;

  late LatLng _markerPos;
  late MapController _mapCtrl;
  String _selectedCategory = AppConstants.categoryOptions.first;

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();

    if (_isEditing) {
      final l = widget.listing!;
      _nameCtrl = TextEditingController(text: l.placeName);
      _addressCtrl = TextEditingController(text: l.address);
      _contactCtrl = TextEditingController(text: l.contactNumber);
      _descCtrl = TextEditingController(text: l.description);
      _selectedCategory = l.category;
      _lat = l.latitude;
      _lng = l.longitude;
      _markerPos = LatLng(l.latitude, l.longitude);
      _locationPinned = true; // existing listing already has a location
    } else {
      _nameCtrl = TextEditingController();
      _addressCtrl = TextEditingController();
      _contactCtrl = TextEditingController();
      _descCtrl = TextEditingController();
      // Default to Kigali city centre — valid coordinates from the start
      _lat = AppConstants.kigaliLat;
      _lng = AppConstants.kigaliLng;
      _markerPos = LatLng(AppConstants.kigaliLat, AppConstants.kigaliLng);
      _locationPinned = false; // nudge user to tap
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // Called every time user taps the map — updates doubles directly
  void _onMapTap(TapPosition _, LatLng pos) {
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _markerPos = pos;
      _locationPinned = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(currentUidProvider);
    if (uid.isEmpty) {
      _snack('Authentication error. Please log in again.', AppColors.error);
      return;
    }

    // _lat and _lng are always valid doubles — no tryParse needed
    final listing = ListingModel(
      id: _isEditing ? widget.listing!.id : '',
      placeName: _nameCtrl.text.trim(),
      category: _selectedCategory,
      address: _addressCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: _lat,
      longitude: _lng,
      createdBy: uid,
      timestamp: _isEditing ? widget.listing!.timestamp : DateTime.now(),
      isUserAdded: true,
    );

    final notifier = ref.read(listingNotifierProvider.notifier);
    final ok = _isEditing
        ? await notifier.updateListing(listing)
        : await notifier.createListing(listing);

    if (!mounted) return;

    if (ok) {
      _snack(_isEditing ? 'Service updated!' : 'Service added!',
          AppColors.success);
      ref.read(listingNotifierProvider.notifier).resetState();
      Navigator.of(context).pop();
    } else {
      final err = ref.read(listingNotifierProvider).asError?.error.toString();
      _snack('Error: ${err ?? 'Something went wrong'}', AppColors.error);
      ref.read(listingNotifierProvider.notifier).resetState();
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(listingNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Service' : 'Add a Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Service Details'),
              const SizedBox(height: 14),

              // Place name
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Place or Service Name *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Category *'),
                items: AppConstants.categoryOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Address *'),
                maxLines: 2,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Address is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Contact
              TextFormField(
                controller: _contactCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number (optional)',
                  prefixText: '+250 ',
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

              _sectionLabel('Pin on Map'),
              const SizedBox(height: 8),

              // Location status indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _locationPinned
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _locationPinned
                        ? AppColors.success.withOpacity(0.4)
                        : AppColors.accent.withOpacity(0.35),
                  ),
                ),
                child: Row(children: [
                  Icon(
                    _locationPinned
                        ? Icons.gps_fixed
                        : Icons.touch_app_outlined,
                    color:
                        _locationPinned ? AppColors.success : AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _locationPinned
                        ? Text(
                            '${_lat.toStringAsFixed(5)},  '
                            '${_lng.toStringAsFixed(5)}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          )
                        : const Text(
                            'Tap the map to pin the exact location',
                            style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                  if (_locationPinned)
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 18),
                ]),
              ),
              const SizedBox(height: 10),

              // Map
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 220,
                  child: FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: _markerPos,
                      initialZoom: AppConstants.defaultZoom,
                      maxZoom: 18,
                      // NO minZoom — prevents flutter_map from calling
                      // AbortController.abort() which crashes BrowserClient
                      // on Flutter Web (browser_client.dart:80)
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.kigali.kigali_city_services',
                        maxNativeZoom: 19,
                        // Prevents flutter_map from aborting tile requests,
                        // which would crash BrowserClient JS interop on web
                        evictErrorTileStrategy: EvictErrorTileStrategy.none,
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: _markerPos,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppColors.accent,
                            size: 40,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primaryDark),
                      )
                    : Text(_isEditing ? 'Update Service' : 'Add Service'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(
        t.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );
}
