import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase is included
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/home_page.dart'; // Assuming you have a HomePage

class AuthButtons extends StatefulWidget {
  const AuthButtons({super.key});

  @override
  _AuthButtonsState createState() => _AuthButtonsState();
}

class _AuthButtonsState extends State<AuthButtons> {
  bool _isInitialized = false; // Flag to track if Firebase has been initialized
  User? _user; // To hold the current user

  Future<void> _initializeFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
      debugPrint("✅ Firebase successfully initialized");
    }

    // After initialization, check if the user is logged in
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user; // Update the user state
      _isInitialized = true; // Set initialized to true
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase(); // Initialize Firebase when the widget is created
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator()); // Show loading indicator while initializing Firebase
    }

    if (_user != null) {
      // If user is logged in, navigate to the HomePage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
    }

    // If user is not logged in, show Login/Sign Up buttons
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAuthButton(context, 'Login', Colors.blue, const LoginPage()),
        const SizedBox(width: 20),
        _buildAuthButton(context, 'Sign Up', Colors.orange, const SignUpPage()),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context, String text, Color color, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
