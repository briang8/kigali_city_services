# Kigali City Services

A mobile app built with Flutter that lets people in Kigali, Rwanda find and manage local services like hospitals, banks, restaurants, police stations, and more. You can browse listings, and signed-in users can add new places, leave reviews, and bookmark spots they want to remember.

---

## What it does

- Browse a directory of Kigali city services filtered by category or keyword search to help users locate and navigate essential public services and places to have fun, etc.
- View each place on an interactive map with a pin, then tap to open navigation in Google Maps or your default maps app
- Sign up and log in with email and password (email verification required before access)
- Add, edit, and delete your own listings with a name, category, address, GPS coordinates, phone number, and description
- Leave a star rating and written review on any listing
- Bookmark listings to save them for later
- A pre-loaded set of real Kigali locations is seeded into the database on first launch so the app is not empty

---

Features

- Email and password authentication with email verification gate
- Pre-seeded directory of real Kigali city services (hospitals, banks, restaurants, police stations, airports, and more)
- Full-text search and category filter on the directory
- Create, edit, and delete your own listings
- Listing detail screen with embedded OpenStreetMap and navigation link
- Star rating and review system stored in Firestore sub-collections
- Bookmark listings to a personal saved list
- Settings screen showing user profile and verified badge
- Dark theme throughout

---

## Tech stack

| What | Tool |
|---|---|
| UI framework | Flutter (Dart) |
| Backend / database | Firebase Firestore |
| Authentication | Firebase Auth |
| State management | Riverpod (flutter_riverpod 2.x) |
| Maps | flutter_map with OpenStreetMap tiles (no API key needed) |
| Navigation links | url_launcher |

---

## Project structure

```
lib/
  main.dart                    app entry point, Firebase init
  firebase_options.dart        auto-generated Firebase config

  constants/
    app_constants.dart         category list, shared constants
    app_theme.dart             dark theme colours and text styles

  data/
    kigali_seed_data.dart      pre-built listing and review data seeded on first run

  models/
    listing_model.dart         ListingModel + ReviewModel data classes
    user_model.dart            UserModel data class

  providers/
    auth_provider.dart         auth state, sign-up, sign-in, sign-out
    listing_provider.dart      stream providers, search/filter, CRUD notifier
    settings_provider.dart     notification and nearby-alerts toggle state

  screens/
    app_shell.dart             bottom navigation host (IndexedStack)
    auth/
      auth_gate.dart           decides whether to show login or app shell
      login_screen.dart        sign-in form
      signup_screen.dart       sign-up form
      email_verification_screen.dart  prompt to verify email before entering app
    directory/
      directory_screen.dart    main listing grid with search and filter bar
      add_listing_screen.dart  form to create or edit a listing
    detail/
      detail_screen.dart       full listing detail with map, reviews, and actions
    my_listings/
      my_listings_screen.dart  listings created by the current user
    map/
      map_screen.dart          full-screen map with all listing pins
    bookmarks/
      bookmarks_screen.dart    saved/bookmarked listings
    settings/
      settings_screen.dart     user profile card, toggles, sign-out

  services/
    auth_service.dart          Firebase Auth calls and Firestore user profile writes
    listing_service.dart       Firestore CRUD, seeding, reviews stream

  widgets/
    service_card.dart          reusable listing card widget + CategoryChipBar
    category_chip_bar.dart     horizontal scrollable category filter
```

---

## Firestore database structure

```
listings/                        (collection)
  {listingId}/
    placeName       string
    category        string
    address         string
    contactNumber   string
    description     string
    latitude        number
    longitude       number
    createdBy       string  (user uid)
    timestamp       timestamp
    rating          number
    reviewCount     number
    isUserAdded     boolean

    reviews/                     (sub-collection)
      {reviewId}/
        uid         string
        userName    string
        stars       number
        comment     string
        timestamp   timestamp

users/                           (collection)
  {uid}/
    uid             string
    email           string
    displayName     string
    createdAt       timestamp

    bookmarks/                   (sub-collection)
      {listingId}   document (presence = bookmarked)
```

---

## Firestore security rules summary

- Listings are readable by everyone
- Only signed-in users can create a listing
- Only the listing owner can update or delete it
- Reviews are readable by everyone, creatable by any signed-in user
- User profile documents and bookmarks are only accessible by the owning user

---

## How to run the project on an emulator

### 1. Prerequisites

Make sure you have these installed before starting:

- Flutter SDK (3.x or later) — https://docs.flutter.dev/get-started/install
- Android Studio with the Android emulator set up, or an Android device
- Java 17 (required by the Android Gradle build)
- Node.js and the Firebase CLI if you want to re-deploy Firestore rules

Confirm Flutter is ready by running:

```
flutter doctor
```

All green ticks are ideal. A missing Android licence is the most common issue — fix it with `flutter doctor --android-licenses`.

### 2. Clone the repository and install packages

```
git clone <this-repo-url>
cd kigali_city_services
flutter pub get
```

### 3. Firebase setup

The `google-services.json` file for Android is already in `android/app/`. The Firebase project is `kigali-city-services-54822`.

If you need to connect a different Firebase project, replace `google-services.json` and regenerate `lib/firebase_options.dart` using the FlutterFire CLI:

```
flutterfire configure
```

### 4. Start an emulator

Open Android Studio, go to Device Manager, and start an emulator (Pixel 5 is a good choice). Wait until it fully boots to the home screen.

### 5. Run the app

```
flutter run
```

Flutter will detect the running emulator and install the app automatically. The first launch seeds the Kigali listing data into Firestore so the directory is populated straight away.

## Notes

- The map uses OpenStreetMap tiles so no Google Maps API key is needed
- Email verification is enforced — after sign-up you will receive a verification email(Make sure to check your spam folder as that's where it will be sent because the app is not a verified app yet) and the app will wait on a holding screen until you confirm it
- The seed data runs only once. If you clear the Firestore `listings` collection in the Firebase Console, it will re-seed on the next app launch


Thanks you for checking out this app!!!
