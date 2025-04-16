import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LiveEmissionPage extends StatefulWidget {
  @override
  _LiveEmissionPageState createState() => _LiveEmissionPageState();
}

class _LiveEmissionPageState extends State<LiveEmissionPage> {
  String _selectedRange = 'Live'; // Initial selected range
  List<Map<String, dynamic>> _sheetData = [
    // Sample data for CO and CO2 levels over time (replace with your actual data)
    {'Time': '2025-04-20T12:00:00', 'CO': '300', 'CO2': '500'},
    {'Time': '2025-04-19T12:00:00', 'CO': '310', 'CO2': '490'},
    {'Time': '2025-04-18T12:00:00', 'CO': '280', 'CO2': '470'},
    // Add more entries as needed
  ];

  // Function to filter the data based on the selected range (Live, Weekly, Monthly)
  List<Map<String, dynamic>> _filterDataBasedOnRange(String range) {
    DateTime now = DateTime.now();
    switch (range) {
      case 'Live':
        return _sheetData; // Live data, no filtering
      case 'Weekly':
        return _sheetData.where((entry) {
          final date = DateTime.tryParse(entry['Time'] ?? '');
          if (date != null) {
            return now.difference(date).inDays <= 7; // Only data from the last week
          }
          return false;
        }).toList();
      case 'Monthly':
        return _sheetData.where((entry) {
          final date = DateTime.tryParse(entry['Time'] ?? '');
          if (date != null) {
            return now.difference(date).inDays <= 30; // Only data from the last month
          }
          return false;
        }).toList();
      default:
        return _sheetData;
    }
  }

  // Function to build the live emission graph
  Widget _buildLiveEmissionGraph() {
    List<FlSpot> coSpots = [];
    List<FlSpot> co2Spots = [];

    // Filter the data based on the selected range (Live, Weekly, Monthly)
    List<Map<String, dynamic>> filteredData = _filterDataBasedOnRange(_selectedRange);

    for (int i = 0; i < filteredData.length; i++) {
      final entry = filteredData[i];
      final coValue = double.tryParse(entry['CO']?.toString() ?? '');
      final co2Value = double.tryParse(entry['CO2']?.toString() ?? '');

      if (coValue != null) {
        coSpots.add(FlSpot(i.toDouble(), coValue));
      }
      if (co2Value != null) {
        co2Spots.add(FlSpot(i.toDouble(), co2Value));
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.circle, color: Colors.red, size: 12),
                    SizedBox(width: 4),
                    Text("CO", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 16),
                    Icon(Icons.circle, color: Colors.green, size: 12),
                    SizedBox(width: 4),
                    Text("CO2", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                DropdownButton<String>(
                  value: _selectedRange,
                  underline: Container(),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  items: ['Live', 'Weekly', 'Monthly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRange = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              double chartHeight = MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 400;

              return SizedBox(
                height: chartHeight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            interval: 50, // Adjust based on your range
                            getTitlesWidget: (value, meta) {
                              final roundedValue = value.toInt();
                              if (roundedValue % 50 != 0) return const SizedBox.shrink();

                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  '$roundedValue',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: coSpots,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          isCurved: true,
                          spots: co2Spots,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carbon Shodhak - Live Emission'),
      ),
      body: _buildLiveEmissionGraph(), // Calls the graph builder
    );
  }
}
