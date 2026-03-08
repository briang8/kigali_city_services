import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';

// Initialises Firebase inside the widget tree so runApp() is called
// immediately — prevents the black screen in debug mode caused by awaiting
// Firebase.initializeApp() before runApp().
// Guards against duplicate-app on hot restart (native keeps Firebase alive
// while the Dart VM resets).
final _firebaseInitProvider = FutureProvider<FirebaseApp>((ref) {
  if (Firebase.apps.isNotEmpty) return Firebase.apps.first;
  return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: KigaliCityApp()));
}

class KigaliCityApp extends ConsumerWidget {
  const KigaliCityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(_firebaseInitProvider);

    return MaterialApp(
      title: 'Kigali City Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Prevent Edge / Chrome font-scaling from breaking layouts
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      home: firebaseInit.when(
        loading: () => const Scaffold(
          backgroundColor: Color(0xFF0D1B2A),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFFA500)),
          ),
        ),
        error: (e, _) => Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          body: Center(
            child: Text(
              'Failed to initialise Firebase:\n$e',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (_) => const AuthGate(),
      ),
    );
  }
}
