import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/listing_service.dart';
import 'app_shell.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

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

        // seedIfEmpty does its own count check and exits early when the full
        // seed set is present, so calling it on every verified login is safe.
        // Future.microtask defers the call past the current build frame to
        // avoid Riverpod's "modified provider during build" error.
        Future.microtask(() => ListingService().seedIfEmpty());

        return const AppShell();
      },
    );
  }
}
