import 'package:fitness/login/sign_page.dart';
import 'package:flutter/material.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 1, 19), // Background color
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 0.9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative header
              Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: size.width * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              // Decorative container
              Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 244, 248),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your email address to reset your password.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * 0.02,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Email input field
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Color.fromARGB(255, 4, 7, 14)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 222, 223, 225).withOpacity(0.1),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: size.height * 0.01),
                    // New Password input field
                    TextField(
                      controller: _newPasswordController,
                      focusNode: _newPasswordFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: const TextStyle(color: Color.fromARGB(255, 4, 7, 14)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 222, 223, 225).withOpacity(0.1),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Confirm Password input field
                    TextField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: Color.fromARGB(255, 4, 7, 14)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 222, 223, 225).withOpacity(0.1),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Reset Password button
                    ElevatedButton(
                      onPressed: () {
                        // Perform reset password logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: size.width * 0.01,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Link to go back to login
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate back to login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
                          );
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontSize: size.width * 0.02,
                            color: const Color.fromARGB(255, 11, 1, 28),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
