// Central app-wide constants for categories and map defaults
class AppConstants {
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

  // categoryOptions excludes 'All' for use in form dropdowns
  static List<String> get categoryOptions =>
      categories.where((c) => c != 'All').toList();

  // Kigali city center coordinates
  static const double kigaliLat = -1.9441;
  static const double kigaliLng = 30.0619;
  static const double defaultZoom = 13.0;
  static const double detailZoom = 16.0;
}
