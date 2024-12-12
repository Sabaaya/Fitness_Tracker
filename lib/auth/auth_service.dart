import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Sign in
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

      // Save user information to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
      await prefs.setString('userId', userCredential.user?.uid ?? '');
      await prefs.setString('userInitial', email.isNotEmpty ? email[0].toUpperCase() : '');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear user information from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userEmail');
      await prefs.remove('userId');
      await prefs.remove('userInitial');

      await auth.signOut();
    } catch (e) {
      throw Exception("Sign out failed: $e");
    }
  }

  // Get current user email
  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  // Get current user ID
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Get current user initial
  Future<String?> getUserInitial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userInitial');
  }

  loginWithEmailPassword(String text, String text2) {}
}
