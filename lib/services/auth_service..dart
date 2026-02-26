import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Handles all Firebase Authentication and user profile operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream that emits the current user or null on auth state change
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Return the currently signed-in Firebase user
  User? get currentUser => _auth.currentUser;

  // Register a new user, send verification email, and create Firestore profile
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    await _createUserProfile(credential.user!);
    return credential;
  }

  // Sign in with email and password credentials
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out the currently authenticated user
  Future<void> signOut() async => await _auth.signOut();

  // Resend the verification email to the current user
  Future<void> resendVerificationEmail() async =>
      await _auth.currentUser?.sendEmailVerification();

  // Reload user object to get updated email verification status
  Future<void> reloadUser() async =>
      await _auth.currentUser?.reload();

  // Fetch the UserModel profile document from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // Write a new user profile document to the Firestore users collection
  Future<void> _createUserProfile(User user) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      createdAt: DateTime.now(),
    );
    await _db
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
  }
}