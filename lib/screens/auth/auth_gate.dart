import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/listing_service.dart';
import 'app_shell.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

// Tracks whether seed has already been triggered this session.
// Prevents seedIfEmpty() from being called on every widget rebuild.
final _seedCalledProvider = StateProvider<bool>((_) => false);

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFA500)),
        ),
      ),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();
        if (!user.emailVerified) return const EmailVerificationScreen();

        // Seed once per session — use Future.microtask so the state mutation
        // happens after the current build frame, avoiding Riverpod's
        // "modified provider during build" error.
        final seeded = ref.read(_seedCalledProvider);
        if (!seeded) {
          Future.microtask(() {
            ref.read(_seedCalledProvider.notifier).state = true;
            ListingService().seedIfEmpty();
          });
        }

        return const AppShell();
      },
    );
  }
}
