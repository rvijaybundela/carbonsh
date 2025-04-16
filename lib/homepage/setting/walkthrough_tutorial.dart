import 'package:flutter/material.dart';

class WalkthroughTutorialPage extends StatelessWidget {
  const WalkthroughTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'Step 1: Sign Up or Login',
        'desc': 'Create a new account or log in to access your dashboard.',
        'icon': Icons.login,
      },
      {
        'title': 'Step 2: Connect Your Vehicle',
        'desc': 'Add your vehicle details to start tracking emissions.',
        'icon': Icons.directions_car,
      },
      {
        'title': 'Step 3: View Live Emissions',
        'desc': 'Check real-time CO and CO₂ emissions with graphs.',
        'icon': Icons.show_chart,
      },
      {
        'title': 'Step 4: Analyze Stats',
        'desc': 'Explore weekly/monthly statistics to understand trends.',
        'icon': Icons.bar_chart,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Walkthrough Tutorial"),
        backgroundColor: Colors.amber[700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber[100],
                child: Icon(step['icon'], color: Colors.amber[800]),
              ),
              title: Text(step['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(step['desc']),
            ),
          );
        },
      ),
    );
  }
}
