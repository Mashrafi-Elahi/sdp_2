import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes (logged in / logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current logged-in user
  User? get currentUser => _auth.currentUser;

  /// Sign up with email and password, and create a user profile in Firestore
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Save user record in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'loginCount': 1,
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthErrorMessage(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign up: $e';
    }
  }

  /// Sign in with email and password, and increment the login counter
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Increment loginCount and update lastLoginAt in Firestore
        final userDocRef = _firestore.collection('users').doc(user.uid);
        await userDocRef.set({
          'uid': user.uid,
          'email': user.email ?? email.trim(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'loginCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthErrorMessage(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign in: $e';
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream of total registered user count from Firestore
  Stream<int> getUserCountStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.length;
    });
  }

  /// Stream of current user's profile data (including loginCount)
  Stream<DocumentSnapshot<Map<String, dynamic>>>? getCurrentUserDataStream() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  /// Stream of all registered users (for user list in dashboard)
  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs.map((doc) => doc.data()).toList();
          return users;
        });
  }

  /// Format friendly error messages
  static String _getReadableAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password or email. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address entered is not valid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few minutes.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
