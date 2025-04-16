import 'package:flutter/material.dart';

class LicensePageCustom extends StatelessWidget {
  const LicensePageCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("License"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.gavel_outlined, size: 80, color: Colors.teal),
          const SizedBox(height: 20),
          const Text(
            "Software License Agreement",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "This app is licensed under the MIT License. You are free to use, modify, and distribute this software with appropriate credit.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "© 2025 Carbon Shodhak Team",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}
