import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase is imported

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showUserInfo = true;
  User? _currentUser; // Track the Firebase user

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final vehicleIdController = TextEditingController();
  final modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _currentUser = FirebaseAuth.instance.currentUser;
        emailController.text = _currentUser?.email ?? '';
      });
      debugPrint("✅ Firebase successfully initialized");
    } catch (e) {
      debugPrint("❌ Firebase initialization failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF23293A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: const Color(0xFF2ECC71),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabButton("User Info", showUserInfo, () {
                  setState(() => showUserInfo = true);
                }),
                const SizedBox(width: 16),
                _tabButton("Vehicle Info", !showUserInfo, () {
                  setState(() => showUserInfo = false);
                }),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: showUserInfo ? _buildUserInfoCard() : _buildVehicleInfoCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.grey[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("User Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _inputField("Name", nameController),
            const SizedBox(height: 12),
            _inputField("Email", emailController, enabled: false), // Email is fetched from Firebase
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Save Info"),
            ),
            const SizedBox(height: 20),
            if (nameController.text.isNotEmpty || emailController.text.isNotEmpty)
              _infoDisplay({
                'Name': nameController.text,
                'Email': emailController.text,
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Vehicle Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _inputField("Vehicle ID", vehicleIdController),
            const SizedBox(height: 12),
            _inputField("Model", modelController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Save Info"),
            ),
            const SizedBox(height: 20),
            if (vehicleIdController.text.isNotEmpty || modelController.text.isNotEmpty)
              _infoDisplay({
                'Vehicle ID': vehicleIdController.text,
                'Model': modelController.text,
              }),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _infoDisplay(Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            "${entry.key}: ${entry.value}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }
}