import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fitness/screens/profilepage/usermodle.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        _user = UserModel(
          id: user.uid,
          name: user.displayName ?? '',
          profileImage: user.photoURL ?? '',
          joinedDate: user.metadata.creationTime?.toIso8601String() ?? '',
          isPro: false, // You may need to fetch this value from Firestore
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle authentication errors
      print('Error during login: $e');
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        _user = UserModel(
          id: user.uid,
          name: name,
          profileImage: user.photoURL ?? '',
          joinedDate: user.metadata.creationTime?.toIso8601String() ?? '',
          isPro: false,
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle sign-up errors
      print('Error during sign up: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      // Handle errors
      print('Error sending password reset email: $e');
    }
  }

  void logout() {
    _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
