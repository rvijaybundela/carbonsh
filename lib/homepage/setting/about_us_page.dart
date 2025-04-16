import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "About Carbon Shodhak",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Carbon Shodhak is an app focused on real-time vehicle emission tracking and awareness. "
                      "We aim to reduce carbon footprint by helping users monitor and understand their CO and CO₂ levels easily.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
