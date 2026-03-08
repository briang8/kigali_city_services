import '../models/listing_model.dart';

// Pre-seeded Kigali city services written to Firestore on first launch.
// Ratings are realistic dummies — no API required.
abstract final class KigaliSeedData {
  static List<ListingModel> get listings => [
        // ── RESTAURANTS ────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Heaven Restaurant & Boutique Hotel',
          category: 'Restaurant',
          address: '7 KN 29 St, Kigali',
          contactNumber: '0788486581',
          description:
              'Fine dining with panoramic city views, Rwandan fusion cuisine and a rooftop bar.',
          latitude: -1.94608119440907,
          longitude: 30.064998636889058,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── HOSPITALS ──────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'King Faisal Hospital',
          category: 'Hospital',
          address: 'KG 544 St, Kacyiru, Kigali',
          contactNumber: '0788123200',
          description:
              'Leading referral hospital providing specialist care, emergency services and advanced diagnostics.',
          latitude: -1.9436325027840347,
          longitude: 30.09533674884769,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),
        ListingModel(
          id: '',
          placeName: 'Muslims New Hospital',
          category: 'Hospital',
          address: 'KN 123 St',
          contactNumber: '',
          description: '',
          latitude: -1.9677594428322653,
          longitude: 30.067145967782317,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 3.0,
          reviewCount: 1,
        ),

        // ── POLICE STATIONS ────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'RIB Remera Station',
          category: 'Police Station',
          address: 'KG 201 St, Kigali',
          contactNumber: '',
          description: 'Rwanda Investigation Bureau Remera station',
          latitude: -1.9587657877528828,
          longitude: 30.10726568215967,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── LIBRARIES ──────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Kigali Public Library',
          category: 'Library',
          address: 'KN 8 Ave, Kigali',
          contactNumber: '0788500777',
          description:
              'Main public library with books, digital resources, reading rooms and community programmes.',
          latitude: -1.9346337569299734,
          longitude: 30.078720912420334,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── PARKS ──────────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Nyandungu Eco Park',
          category: 'Park',
          address: 'Nyandungu, Kigali',
          contactNumber: '0792052475',
          description:
              'Urban wetland eco-park with walking trails, birdwatching and picnic areas.',
          latitude: -1.9536585428032371,
          longitude: 30.144195136020144,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── OTHER ──────────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Kigali Genocide Memorial',
          category: 'Other',
          address: 'KG 14 Ave, Gisozi, Kigali',
          contactNumber: '0784651051',
          description:
              'Memorial gardens and museum commemorating the 1994 Genocide against the Tutsi.',
          latitude: -1.9312600989655182,
          longitude: 30.060125760546306,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),
        ListingModel(
          id: '',
          placeName: 'Kibagabaga Anglican Church',
          category: 'Other',
          address: 'KG 19 Ave, Kigali',
          contactNumber: '',
          description: '',
          latitude: -1.931980557580725,
          longitude: 30.11381899464578,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 5.0,
          reviewCount: 1,
        ),

        // ── TOURIST ATTRACTIONS ────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Kandt House Museum',
          category: 'Tourist Attraction',
          address: 'KN 90 St, Kigali',
          contactNumber: '0738650993',
          description:
              'Historical museum in the colonial-era house of Richard Kandt',
          latitude: -1.946696886458306,
          longitude: 30.05353266660175,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── HOTELS ─────────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Radisson Blu Hotel Kigali',
          category: 'Hotel',
          address: 'Convention Ctr Roundabout, Kigali',
          contactNumber: '252 252 252',
          description:
              'Five-star hotel with conference facilities, pool, spa and multiple dining options.',
          latitude: -1.9544447302275014,
          longitude: 30.092724496763083,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── MARKETS ────────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Kimironko Market',
          category: 'Market',
          address: 'KG 11 Ave, Kimironko, Kigali',
          contactNumber: '',
          description:
              "Kigali's largest open-air market selling fresh produce, clothing, crafts and household goods.",
          latitude: -1.9497559779490317,
          longitude: 30.126210396332763,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── SCHOOLS ────────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'African Leadership University',
          category: 'School',
          address: 'Kigali',
          contactNumber: '0784650219',
          description:
              'Prominent University in Rwanda that offers top tier education and a diverse community',
          latitude: -1.9303247988843875,
          longitude: 30.15320833500471,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),

        // ── GOVERNMENT ─────────────────────────────────────────────────
        ListingModel(
          id: '',
          placeName: 'Kigali City Hall',
          category: 'Government Office',
          address: 'KN 3 Ave, Nyarugenge, Kigali',
          contactNumber: '252 572 255',
          description:
              'Administrative headquarters of the City of Kigali handling permits, licensing and civic services.',
          latitude: -1.9484209949199636,
          longitude: 30.06026118162562,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),
        ListingModel(
          id: '',
          placeName: 'Ministry of Justice',
          category: 'Government Office',
          address: 'KG 1 Roundabout, Kigali',
          contactNumber: '0788303896',
          description: '',
          latitude: -1.9565555809736815,
          longitude: 30.08453611700156,
          createdBy: 'BG',
          timestamp: DateTime(2026, 3, 6, 9, 0),
          rating: 0,
          reviewCount: 0,
        ),
      ];
}
