import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// Singleton AuthService instance shared across all providers
final authServiceProvider = Provider<AuthService>((_) => AuthService());

// Reactive stream of the current Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Async notifier that manages sign-up, sign-in, and sign-out actions
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async => ref.watch(authServiceProvider).currentUser;

  // Create a new account and update state
  Future<void> signUp(String email, String password,
      [String displayName = '']) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await ref
          .read(authServiceProvider)
          .signUp(email: email, password: password, displayName: displayName);
      return cred.user;
    });
  }

  // Authenticate with existing credentials and update state
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await ref
          .read(authServiceProvider)
          .signIn(email: email, password: password);
      return cred.user;
    });
  }

  // Sign out and clear the current user state
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = const AsyncData(null);
  }
}

// Provider exposing the AuthNotifier
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

// Helper provider that safely exposes the current uid as a plain String
// Returns empty string when not authenticated — never throws
final currentUidProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.uid ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

// Fetches the full UserModel profile from Firestore by uid
final userProfileProvider =
    FutureProvider.family<UserModel?, String>((ref, uid) async {
  if (uid.isEmpty) return null;
  return ref.watch(authServiceProvider).getUserProfile(uid);
});
