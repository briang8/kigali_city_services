abstract final class AppConstants {
  // Default map center — Kigali City Centre
  static const double kigaliLat = -1.9441;
  static const double kigaliLng = 30.0619;

  static const double defaultZoom = 13.0;
  static const double detailZoom  = 15.5;

  // All category labels used across the app
  static const List<String> categories = [
    'All',
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Cafe',
    'Park',
    'Tourist Attraction',
    'Pharmacy',
    'Bank',
    'School',
    'Hotel',
    'Market',
    'Government Office',
    'Other',
  ];

  // Categories shown in the Add Listing dropdown (no "All")
  static List<String> get categoryOptions =>
      categories.where((c) => c != 'All').toList();
}