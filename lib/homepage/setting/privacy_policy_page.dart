import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 20),
          const Text(
            "Your Privacy Matters",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "We collect minimal user data to improve your experience. All data is stored securely and never shared with third parties.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
          ),
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "By using this app, you agree to our privacy practices as described above. You can review or delete your data at any time.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
