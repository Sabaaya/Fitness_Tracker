import 'package:fitness/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:fitness/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Initialize Firebase and Firestore instances
final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  Future<void> _signup(BuildContext context) async {
    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'username': _username,
          'email': _email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful!'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Signing in with email and password is not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        default:
          errorMessage = 'An unknown error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: PrimaryColor,
          title: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/bottomNavigationbar');
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  const SizedBox(height: 60.0),
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: PrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Create your account",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  )
                ],
              ),
              Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _username = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
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
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
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
                      prefixIcon: const Icon(Icons.password),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, left: 3),
                child: ElevatedButton(
                  onPressed: () {
                    _signup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color.fromARGB(255, 5, 248, 106),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
