import '../models/listing_model.dart';

// Pre-seeded Kigali city services written to Firestore on first launch.
// Ratings are realistic dummies — no API required.
abstract final class KigaliSeedData {
  static List<ListingModel> get listings => [
        // ── CAFES ──────────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Kimironko Café', category: 'Cafe',
          address: 'KG 11 Ave, Kimironko, Kigali',
          contactNumber: '+250788100200',
          description: 'Popular neighbourhood café offering fresh coffee, pastries and light meals in a cosy setting.',
          latitude: -1.9355, longitude: 30.1040,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.8, reviewCount: 45,
        ),
        ListingModel(
          id: '', placeName: 'Green Bean Coffee', category: 'Cafe',
          address: 'KN 5 Rd, Kiyovu, Kigali',
          contactNumber: '+250788200300',
          description: 'Specialty coffee roaster sourcing beans directly from Rwandan farmers. Great workspace vibes.',
          latitude: -1.9502, longitude: 30.0596,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.0, reviewCount: 98,
        ),
        ListingModel(
          id: '', placeName: 'Umuganda Coffee', category: 'Cafe',
          address: 'KG 7 Ave, Remera, Kigali',
          contactNumber: '+250788300400',
          description: 'Community-focused café and workspace with fast Wi-Fi, artisan coffee and Rwandan snacks.',
          latitude: -1.9478, longitude: 30.1121,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.4, reviewCount: 62,
        ),
        ListingModel(
          id: '', placeName: 'Rowanda Brew', category: 'Cafe',
          address: 'KN 78 St, Nyamirambo, Kigali',
          contactNumber: '+250788400500',
          description: 'Vibrant café in Nyamirambo known for cold brew, live music evenings and local art.',
          latitude: -1.9779, longitude: 30.0443,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.2, reviewCount: 74,
        ),

        // ── RESTAURANTS ────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Heaven Restaurant', category: 'Restaurant',
          address: 'KN 29 St, Kiyovu, Kigali',
          contactNumber: '+250788500600',
          description: 'Fine dining with panoramic city views, Rwandan fusion cuisine and a rooftop bar.',
          latitude: -1.9445, longitude: 30.0558,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.6, reviewCount: 203,
        ),
        ListingModel(
          id: '', placeName: 'Cheza Restaurant', category: 'Restaurant',
          address: 'KG 4 Ave, Gikondo, Kigali',
          contactNumber: '+250788600700',
          description: 'Family restaurant serving traditional Rwandan dishes — isombe, ugali and grilled meats.',
          latitude: -1.9601, longitude: 30.0801,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.1, reviewCount: 128,
        ),
        ListingModel(
          id: '', placeName: 'Repub Lounge', category: 'Restaurant',
          address: 'KG 7 Ave, Kacyiru, Kigali',
          contactNumber: '+250788700800',
          description: 'Lively sports bar and grill with international food, big screens and a great outdoor terrace.',
          latitude: -1.9412, longitude: 30.0958,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.3, reviewCount: 176,
        ),

        // ── HOSPITALS ──────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'King Faisal Hospital', category: 'Hospital',
          address: 'KG 544 St, Kacyiru, Kigali',
          contactNumber: '+250788303000',
          description: 'Leading referral hospital providing specialist care, emergency services and advanced diagnostics.',
          latitude: -1.9441, longitude: 30.0906,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.2, reviewCount: 312,
        ),
        ListingModel(
          id: '', placeName: 'Rwanda Military Hospital', category: 'Hospital',
          address: 'KG 9 Ave, Kanombe, Kigali',
          contactNumber: '+250788311000',
          description: 'Military and civilian hospital offering comprehensive medical and surgical services.',
          latitude: -1.9681, longitude: 30.1341,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 3.9, reviewCount: 187,
        ),
        ListingModel(
          id: '', placeName: 'Kibagabaga Hospital', category: 'Hospital',
          address: 'KG 26 Ave, Kibagabaga, Kigali',
          contactNumber: '+250788320000',
          description: 'District hospital serving Gasabo district with general and maternal health services.',
          latitude: -1.9211, longitude: 30.1108,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 3.7, reviewCount: 94,
        ),

        // ── POLICE STATIONS ────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Remera Police Station', category: 'Police Station',
          address: 'KG 14 Ave, Remera, Kigali',
          contactNumber: '+250788111222',
          description: 'Rwanda National Police station serving the Remera and Kimironko districts.',
          latitude: -1.9460, longitude: 30.1088,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 3.5, reviewCount: 44,
        ),
        ListingModel(
          id: '', placeName: 'Nyarugenge Police Station', category: 'Police Station',
          address: 'KN 4 Ave, Nyarugenge, Kigali',
          contactNumber: '+250788111333',
          description: 'Central district police station serving Nyarugenge and City Centre areas.',
          latitude: -1.9530, longitude: 30.0591,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 3.6, reviewCount: 38,
        ),

        // ── LIBRARIES ──────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Kigali Public Library', category: 'Library',
          address: 'KN 3 Ave, Nyarugenge, Kigali',
          contactNumber: '+250788222333',
          description: 'Main public library with books, digital resources, reading rooms and community programmes.',
          latitude: -1.9504, longitude: 30.0590,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.3, reviewCount: 89,
        ),

        // ── PARKS ──────────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Nyandungu Eco Park', category: 'Park',
          address: 'KG 19 Ave, Kacyiru, Kigali',
          contactNumber: '',
          description: 'Urban wetland eco-park with walking trails, birdwatching and picnic areas.',
          latitude: -1.9302, longitude: 30.1022,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.5, reviewCount: 156,
        ),
        ListingModel(
          id: '', placeName: 'Kigali Genocide Memorial', category: 'Park',
          address: 'KN 3 Ave, Gisozi, Kigali',
          contactNumber: '+250788333444',
          description: 'Memorial gardens and museum commemorating the 1994 Genocide against the Tutsi.',
          latitude: -1.9178, longitude: 30.0604,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.7, reviewCount: 421,
        ),

        // ── TOURIST ATTRACTIONS ────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Inema Arts Center', category: 'Tourist Attraction',
          address: 'KG 563 St, Kacyiru, Kigali',
          contactNumber: '+250788444555',
          description: 'Contemporary African art gallery showcasing Rwandan artists and hosting dance performances.',
          latitude: -1.9393, longitude: 30.0942,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.6, reviewCount: 278,
        ),
        ListingModel(
          id: '', placeName: 'Kandt House Museum', category: 'Tourist Attraction',
          address: 'KN 5 Ave, Nyarugenge, Kigali',
          contactNumber: '+250788555666',
          description: 'Historical museum in the colonial-era house of Richard Kandt, founder of Kigali.',
          latitude: -1.9556, longitude: 30.0596,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.2, reviewCount: 134,
        ),

        // ── PHARMACIES ─────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Pharmacy La Colline', category: 'Pharmacy',
          address: 'KN 7 St, Kiyovu, Kigali',
          contactNumber: '+250788666777',
          description: 'Full-service pharmacy stocking prescription medicines, cosmetics and medical supplies.',
          latitude: -1.9498, longitude: 30.0572,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.0, reviewCount: 67,
        ),

        // ── BANKS ──────────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Bank of Kigali – City Branch', category: 'Bank',
          address: 'KN 4 Ave, Nyarugenge, Kigali',
          contactNumber: '+250788777888',
          description: 'Main city branch offering retail banking, forex and digital banking services.',
          latitude: -1.9514, longitude: 30.0602,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 3.8, reviewCount: 112,
        ),

        // ── HOTELS ─────────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Radisson Blu Hotel Kigali', category: 'Hotel',
          address: 'KG 2 Roundabout, Kigali',
          contactNumber: '+250788888999',
          description: 'Five-star hotel with conference facilities, pool, spa and multiple dining options.',
          latitude: -1.9441, longitude: 30.0619,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.5, reviewCount: 389,
        ),

        // ── MARKETS ────────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Kimironko Market', category: 'Market',
          address: 'KG 11 Ave, Kimironko, Kigali',
          contactNumber: '',
          description: "Kigali's largest open-air market selling fresh produce, clothing, crafts and household goods.",
          latitude: -1.9341, longitude: 30.1052,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.1, reviewCount: 245,
        ),

        // ── SCHOOLS ────────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Riviera High School', category: 'School',
          address: 'KG 9 Ave, Kacyiru, Kigali',
          contactNumber: '+250788999000',
          description: 'Leading private secondary school offering Rwandan national curriculum and international programmes.',
          latitude: -1.9388, longitude: 30.0927,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 4.3, reviewCount: 78,
        ),

        // ── GOVERNMENT ─────────────────────────────────────────────────
        ListingModel(
          id: '', placeName: 'Kigali City Hall', category: 'Government Office',
          address: 'KN 3 Ave, Nyarugenge, Kigali',
          contactNumber: '+250788100100',
          description: 'Administrative headquarters of the City of Kigali handling permits, licensing and civic services.',
          latitude: -1.9500, longitude: 30.0580,
          createdBy: 'seed', timestamp: DateTime(2024, 1, 1),
          rating: 3.6, reviewCount: 55,
        ),
      ];

  // Dummy reviews keyed by placeName for seeding sub-collections
  static final Map<String, List<Map<String, dynamic>>> dummyReviews = {
    'Kimironko Café': [
      {'userName': 'Eric', 'stars': 5, 'comment': 'Favourite spot to get work done. Great coffee and friendly staff.', 'daysAgo': 2},
      {'userName': 'Sarah', 'stars': 5, 'comment': 'Relaxing atmosphere, tasty drinks, and good wifi.', 'daysAgo': 5},
      {'userName': 'Patrick', 'stars': 4, 'comment': 'Love the cold brew. Gets busy on weekends though.', 'daysAgo': 10},
    ],
    'Green Bean Coffee': [
      {'userName': 'Alice', 'stars': 4, 'comment': 'Best locally sourced coffee in Kigali. The beans are exceptional.', 'daysAgo': 3},
      {'userName': 'Jean', 'stars': 4, 'comment': 'Great place for a meeting. Quiet and professional atmosphere.', 'daysAgo': 7},
    ],
    'Heaven Restaurant': [
      {'userName': 'David', 'stars': 5, 'comment': 'The rooftop view at sunset is absolutely stunning. Food is excellent.', 'daysAgo': 1},
      {'userName': 'Marie', 'stars': 5, 'comment': 'Perfect for special occasions. The fusion menu is creative and delicious.', 'daysAgo': 4},
      {'userName': 'Claude', 'stars': 4, 'comment': 'Lovely vibe and service. Slightly pricey but worth it.', 'daysAgo': 9},
    ],
    'Nyandungu Eco Park': [
      {'userName': 'Pierre', 'stars': 5, 'comment': 'Beautiful peaceful escape from the city. Saw so many birds!', 'daysAgo': 6},
      {'userName': 'Grace', 'stars': 4, 'comment': 'Well maintained trails. Great for morning jogs.', 'daysAgo': 12},
    ],
    'Inema Arts Center': [
      {'userName': 'Amira', 'stars': 5, 'comment': 'Incredible gallery with works that tell real stories. Highly recommend.', 'daysAgo': 3},
      {'userName': 'Thomas', 'stars': 5, 'comment': 'The dance performances are electrifying. A must-visit.', 'daysAgo': 8},
    ],
    'King Faisal Hospital': [
      {'userName': 'Josephine', 'stars': 4, 'comment': 'Excellent specialist care. Clean and well organised.', 'daysAgo': 5},
      {'userName': 'Samuel', 'stars': 4, 'comment': 'Good facilities. Wait times can be long but doctors are thorough.', 'daysAgo': 15},
    ],
    'Radisson Blu Hotel Kigali': [
      {'userName': 'Laura', 'stars': 5, 'comment': 'Impeccable service, stunning views and a great pool.', 'daysAgo': 2},
      {'userName': 'Mike', 'stars': 4, 'comment': 'Excellent conference facilities and central location.', 'daysAgo': 7},
    ],
  };
}