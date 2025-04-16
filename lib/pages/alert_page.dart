import 'package:flutter/material.dart';

class AlertPage extends StatelessWidget {
  final List<Map<String, dynamic>> sheetData;

  AlertPage({required this.sheetData});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> alerts = sheetData.where((entry) {
      final co = double.tryParse(entry['CO'] ?? '') ?? 0;
      final co2 = double.tryParse(entry['CO2'] ?? '') ?? 0;
      return co > 100 || co2 > 400;
    }).toList();

    if (alerts.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No Alerts. All emissions are within safe limits.',
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alerts"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final item = alerts[index];
          final co = item['CO'] ?? 'N/A';
          final co2 = item['CO2'] ?? 'N/A';
          final time = item['Time'] ?? 'Unknown Time';

          return Card(
            color: Colors.red[50],
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 30,
              ),
              title: const Text(
                "High Emission Detected!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "CO: $co ppm\nCO₂: $co2 ppm\nTime: $time",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}
