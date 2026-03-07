import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    await cred.user?.sendEmailVerification();
    // Mirror profile into Firestore so the settings screen can display it
    await _db.collection('users').doc(cred.user!.uid).set(
          UserModel(
            uid: cred.user!.uid,
            email: email,
            displayName: displayName,
            createdAt: DateTime.now(),
          ).toMap(),
        );
    return cred;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  /// Reload the current user's Firebase token (used to detect email verification)
  Future<void> reloadUser() async => _auth.currentUser?.reload();

  /// Re-send the email verification link to the current user
  Future<void> resendVerificationEmail() async =>
      _auth.currentUser?.sendEmailVerification();

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid).get();
      if (snap.exists) return UserModel.fromDoc(snap);
    } catch (_) {
      // Firestore read failed — fall through to Auth-based fallback
    }

    // Profile doc missing or unreadable — build from Firebase Auth
    final user = _auth.currentUser;
    if (user == null) return null;
    final profile = UserModel(
      uid: uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      createdAt: DateTime.now(),
    );
    try {
      await _db.collection('users').doc(uid).set(profile.toMap());
    } catch (_) {}
    return profile;
  }
}
