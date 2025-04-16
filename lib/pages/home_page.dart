import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/pages/alert_page.dart';
import 'package:untitled/homepage/setting/about_us_page.dart';
import 'package:untitled/homepage/setting/help_page.dart';
import 'package:untitled/homepage/nav bar/carbon_credit_calculator_page.dart'; // Optional: use if you want chart instead of table
import 'package:fl_chart/fl_chart.dart';
import 'package:untitled/homepage/setting/settings_page.dart';
import 'package:untitled/homepage/setting/privacy_policy_page.dart';
import 'package:untitled/homepage/setting/lincese_details.dart';
import 'package:untitled/homepage/setting/walkthrough_tutorial.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _sheetData = [];
  bool _isLoading = true;
  String _selectedRange = 'Live';

  @override
  void initState() {
    super.initState();
    fetchGoogleSheetData();
  }

  Future<void> fetchGoogleSheetData() async {
    const sheetUrl =
        'https://opensheet.vercel.app/1cJb2GS2jKHujHrY4W8NHyNT2CZutLcQDKqBIL0lpLjY/Sheet1';

    try {
      final response = await http.get(Uri.parse(sheetUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _sheetData = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  bool hasAlerts() {
    return _sheetData.any((entry) {
      final co = double.tryParse(entry['CO'] ?? '') ?? 0;
      final co2 = double.tryParse(entry['CO2'] ?? '') ?? 0;
      return co > 100 || co2 > 400;
    });
  }

  int alertCount() {
    return _sheetData.where((entry) {
      final co = double.tryParse(entry['CO'] ?? '') ?? 0;
      final co2 = double.tryParse(entry['CO2'] ?? '') ?? 0;
      return co > 100 || co2 > 400;
    }).length;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }


  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildLiveEmissionGraph();
      case 2:
        return _buildStatsGraphs();
      case 3:
        return AlertPage(sheetData: _sheetData); // Display alert page
      case 4:
        return _buildAccountPage();
      default:
        return _buildHomeBody();
    }
  }

  Widget _buildLiveEmissionGraph() {
    List<FlSpot> coSpots = [];
    List<FlSpot> co2Spots = [];

    // Filter the data based on the selected range (Live, Weekly, Monthly)
    List<Map<String, dynamic>> filteredData = _filterDataBasedOnRange(
        _selectedRange);

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
                  hint: const Text('Select Range'),
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
              double chartHeight = MediaQuery
                  .of(context)
                  .orientation == Orientation.landscape ? 300 : 400;
              double fontSize = constraints.maxWidth < 350 ? 8 : 10;

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
                              // Round to int to avoid duplicates like 399.9 and 400
                              final roundedValue = value.toInt();

                              // Only show titles on multiples of interval
                              if (roundedValue % 50 != 0) {
                                return const SizedBox.shrink();
                              }

                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  '$roundedValue',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
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
            return now.difference(date).inDays <= 7;
          }
          return false;
        }).toList();
      case 'Monthly':
        return _sheetData.where((entry) {
          final date = DateTime.tryParse(entry['Time'] ?? '');
          if (date != null) {
            return now
                .difference(date)
                .inDays <= 30; // Only data from the last month
          }
          return false;
        }).toList();
      default:
        return _sheetData;
    }
  }

  Widget _buildStatsGraphs() {
    double getMaxY(List<BarChartGroupData> groups) {
      double max = 0;
      for (var group in groups) {
        for (var rod in group.barRods) {
          if (rod.toY > max) max = rod.toY;
        }
      }
      return max;
    }

    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < _sheetData.length; i++) {
      final co = double.tryParse(_sheetData[i]['CO']?.toString() ?? '');
      final co2 = double.tryParse(_sheetData[i]['CO2']?.toString() ?? '');

      List<BarChartRodData> rods = [];

      if (co != null) {
        rods.add(BarChartRodData(
          toY: co,
          width: 14,
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4),
        ));
      }

      if (co2 != null) {
        rods.add(BarChartRodData(
          toY: co2,
          width: 14,
          color: Colors.greenAccent,
          borderRadius: BorderRadius.circular(4),
        ));
      }

      if (rods.isNotEmpty) {
        barGroups.add(
          BarChartGroupData(x: i, barRods: rods, barsSpace: 6),
        );
      }
    }

    double chartMaxY = getMaxY(barGroups) + 5; // Add headroom for bars

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CO & CO₂ Statistics",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Custom Legend Row
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CO',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 20,
                      height: 20,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CO₂',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: 320,
                    width: barGroups.length * 60, // wider spacing for more readable bars
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: chartMaxY,
                        barGroups: barGroups,
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide.none,
                            top: BorderSide.none,
                            right: BorderSide.none,
                            bottom: BorderSide(width: 1, color: Colors.grey),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (rod.toY == 0) return null;
                              String label = rod.color == Colors.redAccent ? 'CO: ' : 'CO₂: ';
                              return BarTooltipItem(
                                '$label${rod.toY.toStringAsFixed(2)}',
                                const TextStyle(color: Colors.white, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= _sheetData.length) return const SizedBox.shrink();

                                String time = _sheetData[index]['TIME']?.toString() ?? '';
                                String short = time.split(' ').length > 1 ? time.split(' ')[1] : time;

                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 4,
                                  child: Transform.rotate(
                                    angle: -0.5,
                                    child: Text(short, style: const TextStyle(fontSize: 10)),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, interval: 1),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }


  Widget _buildAccountPage() {
    String displayName = "Guest User";
    String email = "guest@example.com";

    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      displayName = currentUser.displayName ?? "Guest User";
      email = currentUser.email ?? "guest@example.com";
    } else {
      displayName = "Not Logged In";
      email = "Please log in to view details.";
    }

    const String vehicleId = "#123456";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                "Vehicle ID: $vehicleId",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHomeBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sheetData.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final columnKeys = _sheetData.first.keys.toList();
    final lastEntry = _sheetData.last;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Latest Data Card
              Card(
                color: Colors.lightBlue[50],
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Latest Data",
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 10),
                      Text("CO₂: ${lastEntry['MQ135'] ?? 'N/A'}"),
                      Text("CO: ${lastEntry['MQ7'] ?? 'N/A'}"),
                      Text("Time: ${lastEntry['Time'] ?? 'N/A'}"),
                    ],
                  ),
                ),
              ),
              // Reload Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  fetchGoogleSheetData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Reload Data"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Data Table Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateColor.resolveWith((
                          states) => Colors.blue.shade100),
                      dataRowColor: WidgetStateColor.resolveWith((
                          states) => Colors.grey.shade50),
                      columnSpacing: 20,
                      columns: columnKeys.map((key) {
                        return DataColumn(
                          label: Text(
                            key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      rows: List<DataRow>.generate(_sheetData.length, (index) {
                        final row = _sheetData[index];
                        return DataRow(
                          cells: columnKeys.map((key) {
                            return DataCell(
                              Text(
                                row[key]?.toString() ?? '',
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400), // limit width on large screens
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text(
                  "vJ Nath",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: const Text(
                  "vjnath18@gmail.com",
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('assets/user.png'),
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDrawerItem(Icons.info_outline, "About Us", Colors.orange, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()));
                      }),
                      _buildDrawerItem(Icons.help_outline, "Help", Colors.purple, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
                      }),
                      _buildDrawerItem(Icons.settings, "Settings", Colors.grey, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (ctx) {
                            return Builder(
                              builder: (newContext) => const SettingsPage(),
                            );
                          },
                        ));
                      }),

                      _buildDrawerItem(Icons.privacy_tip_outlined, "Privacy Policy", Colors.blue, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
                      }),
                      _buildDrawerItem(Icons.book_outlined, "License", Colors.teal, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LicensePageCustom()));
                      }),
                      _buildDrawerItem(Icons.school_outlined, "Walkthrough Tutorial", Colors.amber, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const WalkthroughTutorialPage()));
                      }),
                      _buildDrawerItem(Icons.calculate, "Carbon Credit Calculator", Colors.green, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CarbonCreditCalculatorPage()));
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout == true) {
                      _navigateToLogin();
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDrawerItem(IconData icon, String title, Color iconColor,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: iconColor.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
                Icons.chevron_right_rounded, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),  // Keep the height as you want
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 6,  // Add elevation for shadow effect
          backgroundColor: Colors.transparent,  // Transparent background for gradient
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF00C6FF)], // Gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,  // Shadow for the AppBar
                  blurRadius: 6,          // Slight blur radius for shadow
                  offset: Offset(0, 3),   // Shadow offset (vertical)
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), // Rounded corners at the bottom
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          centerTitle: true,  // Center the title
          title: const Text(
            'Carbon शोधक', // Hindi title
            style: TextStyle(
              fontSize: 30, // Adjust the font size
              fontWeight: FontWeight.bold, // Bold font for emphasis
              color: Colors.white, // White text color
              letterSpacing: 1.5,  // Slight letter spacing for better readability
              shadows: [
                Shadow(
                  blurRadius: 3,  // Slight blur for text shadow
                  color: Colors.black45,  // Text shadow color
                  offset: Offset(1, 1),  // Offset of the shadow
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white), // Logout icon
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout == true) {
                  _navigateToLogin();
                }
              },
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.white), // Icon theme color
        ),
      ),
      drawer: _buildAppDrawer(),
      body: _getBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -1),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final iconData = [
                Icons.home_rounded,
                Icons.show_chart_rounded,
                Icons.bar_chart_rounded,
                Icons.notifications_rounded,
                Icons.person_rounded,
              ][index];
              final label = ['Home', 'Live', 'Stats', 'Alerts', 'Account'][index];

              final isSelected = _selectedIndex == index;

              // Define distinct colors for each tab when selected
              final selectedColors = [
                Colors.blue,
                Colors.green,
                Colors.purple,
                Colors.orange,
                Colors.teal,
              ];
              final selectedColor = selectedColors[index];

              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconData,
                        size: 24,
                        color: isSelected ? selectedColor : Colors.black54,
                        semanticLabel: label, // Add semantic label for accessibility
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? selectedColor : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}




