import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signupWithName(
    String name,
    String email,
    String password,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final newUser = cred.user;
    if (newUser == null) return;
    await newUser.updateDisplayName(name.trim());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .set({
      'name': name.trim(),
      'email': email.trim(),
      'addresses': <dynamic>[],
      'payments': <dynamic>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Google Sign-In.
  /// Returns null if the user cancels the picker.
  /// Throws [FirebaseAuthException] or [GoogleSignInException] on failure.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user;
    if (user == null) return userCred;

    // Create a Firestore user doc if this is a new Google user.
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name':      user.displayName ?? '',
        'email':     user.email ?? '',
        'addresses': <dynamic>[],
        'payments':  <dynamic>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCred;
  }

  Future<void> signOut() async {
    // GoogleSignIn.signOut() can throw on web or when the user signed in
    // with email (not Google). Swallow the error so _auth.signOut() always runs.
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  static String errorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for that email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';
        case 'invalid-credential':
          return 'Invalid email or password.';
        default:
          return e.message ?? 'Authentication failed. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
