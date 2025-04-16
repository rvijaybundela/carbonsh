import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final helpItems = [
      {
        'question': "How do I connect my vehicle?",
        'answer': "Go to the Profile page and enter your vehicle details.",
        'icon': Icons.directions_car_filled,
      },
      {
        'question': "Where can I view emissions?",
        'answer': "Check the Live Emission tab for real-time CO and CO₂ graphs.",
        'icon': Icons.show_chart,
      },
      {
        'question': "How to change language or theme?",
        'answer': "Navigate to Settings to switch theme and language.",
        'icon': Icons.settings,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: helpItems.length,
        itemBuilder: (context, index) {
          final item = helpItems[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(item['icon'] as IconData, color: Colors.indigo),
              title: Text(item['question'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['answer'] as String),
            ),
          );
        },
      ),
    );
  }
}
