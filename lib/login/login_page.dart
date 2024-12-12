import 'package:fitness/controller/auth_controller.dart';
import 'package:fitness/login/forgotpassword.dart';
import 'package:fitness/login/sign_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String _email = ''; // Initialize with empty string
  late String _password = ''; // Initialize with empty string
  bool _isLoggingIn = false; // Track login state

  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Remove the check from here to prevent immediate navigation
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (authController.isLoggedIn.value) {
    //     _checkAdminAndNavigate(); // Check admin status after login
    //   }
    // });
  }

  void _checkAdminAndNavigate() async {
    bool isAdmin = authController.isAdmin();
    print('Is user admin: $isAdmin'); // Debugging output
    if (isAdmin) {
      Get.offAllNamed('/bottomNavigationbar'); // Navigate to admin page
    } else {
      Get.offAllNamed(
          '/bottomNavigationbar'); // Navigate to user page (update this as needed)
    }
  }

  void _login() async {
    if (_isLoggingIn) return; // Prevent multiple clicks
    _isLoggingIn = true; // Set logging in state

    if (_email.isEmpty || _password.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty.');
      _isLoggingIn = false; // Reset state
      return;
    }
    try {
      await authController.login(_email, _password);
      if (authController.isLoggedIn.value) {
        print("User logged in successfully."); // Debugging output
        _checkAdminAndNavigate(); // Check admin status after login
      } else {
        print("User is not logged in."); // Debugging output
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      _isLoggingIn = false; // Reset state after login attempt
    }
  }

  Future<void> _logout() async {
    try {
      await authController.logout(); // Ensure this calls the logout method
      Get.offAllNamed('/login'); // Redirect to login page after logout
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Login',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bottomNavigationbar');
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _header(context),
                const SizedBox(height: 20),
                _inputField(context),
                _forgotPassword(context),
                _signup(context),
                _logoutButton(context), // Ensure this is the logout button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/img/logi.png', // Replace with the path to your login image
          width: 200,
          height: 200,
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Add welcome text here
        const Text(
          'Welcome to FitTrack', // Welcome message
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change color if needed
          ),
          textAlign: TextAlign.center, // Center the text
        ),
        const SizedBox(
            height: 20), // Space between welcome text and input fields
        TextField(
          onChanged: (value) {
            _email = value;
          },
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white,
            filled: true,
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) {
            _password = value;
          },
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white,
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:
              _isLoggingIn ? null : _login, // Disable button if logging in
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color.fromARGB(255, 76, 248, 171),
          ),
          child: Text(
            _isLoggingIn ? "Logging in..." : "Login", // Change button text
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
        );
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Color.fromARGB(255, 3, 171, 143)),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text(
        "Don't have an account? ",
        style: TextStyle(color: Colors.white),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SignUpPage(),
            ),
          );
        },
        child: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      )
    ]);
  }

  Widget _logoutButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color.fromARGB(255, 115, 240, 207),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
