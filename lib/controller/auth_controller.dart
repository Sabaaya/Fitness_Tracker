import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isAdmin = false.obs;
  var isLoggedIn = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    ever(isLoggedIn, _handleAuthStateChange); // Listen for changes in login state
    _auth.authStateChanges().listen((User? user) {
      isLoggedIn.value = user != null; // Update login state
    });
  }

  void _handleAuthStateChange(bool loggedIn) {
    if (loggedIn) {
      if (Get.currentRoute != '/bottomNavigationbar') {
        Get.offAllNamed('/bottomNavigationbar'); // Redirect to the main page
      }
    } else {
      Get.offAllNamed('/login'); // Redirect to login if logged out
    }
  }

  Future<bool> _checkAdminStatus(User user) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        print("User document exists: ${doc.data()}"); // Debugging output
        isAdmin.value = doc.get('role') == 'admin';
        print("Is user admin: ${isAdmin.value}"); // Debugging output
        return isAdmin.value;
      } else {
        print("User document does not exist."); // Debugging output
        return false;
      }
    } catch (error) {
      print("Error checking admin status: $error");
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isLoggedIn.value = true; // Update login state
      // Check admin status after login
      await _checkAdminStatus(_auth.currentUser!); // Ensure this returns a bool
    } catch (e) {
      print("Login failed: $e");
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      isAdmin.value = false;
      isLoggedIn.value = false; // Update the logged-in state
      Get.offAllNamed('/login'); // Ensure this navigates to the login page
    } catch (e) {
      print('Error during logout: $e');
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<bool> isUserAdmin() async {
    User? user = currentUser; // Get the current user
    if (user == null) return false; // If no user is logged in, return false
    // Check if the user is an admin based on your logic
    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists && doc.get('role') == 'admin'; // Check admin role
  }

  @override
  void dispose() {
    // Cancel any listeners or streams here if needed
    super.dispose();
  }
}