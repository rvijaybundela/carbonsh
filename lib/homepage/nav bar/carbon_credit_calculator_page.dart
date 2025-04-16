import 'package:flutter/material.dart';

class CarbonCreditCalculatorPage extends StatefulWidget {
  @override
  _CarbonCreditCalculatorPageState createState() =>
      _CarbonCreditCalculatorPageState();
}

class _CarbonCreditCalculatorPageState
    extends State<CarbonCreditCalculatorPage> {
  final TextEditingController _emissionController = TextEditingController();
  String _selectedFuel = 'Petrol';
  double? _calculatedCredits;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric'];

  double _calculateCredits(double emissions, String fuelType) {
    // Example multipliers, replace with actual values as needed
    final Map<String, double> multipliers = {
      'Petrol': 0.02,
      'Diesel': 0.025,
      'CNG': 0.015,
      'Electric': 0.005,
    };

    return emissions * (multipliers[fuelType] ?? 0.02);
  }

  void _onCalculatePressed() {
    final double? emissions = double.tryParse(_emissionController.text.trim());

    if (emissions == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid emission value')),
      );
      return;
    }

    final double credits = _calculateCredits(emissions, _selectedFuel);
    setState(() {
      _calculatedCredits = credits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Credit Calculator'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Emission (kg CO₂)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emissionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 120.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Fuel Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedFuel,
                items: _fuelTypes
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedFuel = val!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onCalculatePressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)), // Button color
                  ),
                  child: const Text(
                    'Calculate Credits',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_calculatedCredits != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: Text(
                    'Estimated Carbon Credits: ${_calculatedCredits!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
