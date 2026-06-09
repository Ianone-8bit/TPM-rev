import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/hunter_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? hunter;

  @override
  void initState() {
    super.initState();
    loadHunter();
  }

  Future<void> loadHunter() async {
    String username = await AuthService.instance.currentUser();
    final data = await HunterService.instance.getHunter(username);
    setState(() {
      hunter = data;
    });
  }

  String getRank(int level) {
    if (level >= 50) return 'S';
    if (level >= 40) return 'A';
    if (level >= 30) return 'B';
    if (level >= 20) return 'C';
    if (level >= 10) return 'D';
    return 'E';
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hunter == null) {
      return const Center(child: CircularProgressIndicator());
    }

    int level = hunter!['level'];
    int exp = hunter!['exp'];
    int gold = hunter!['gold'];
    String rank = getRank(level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF), width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF00E5FF), blurRadius: 20, spreadRadius: 2)
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFF1E1E1E),
                child: Icon(Icons.person, size: 60, color: Color(0xFF00E5FF)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            hunter!['username'].toString().toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
              shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
            ),
            child: Text(
              "CLASS: ASSASSIN", // Mock class
              style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 40),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("HUNTER STATUS", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)),
                  const Divider(color: Colors.white24, height: 30),
                  _buildStatRow("RANK", rank, Icons.military_tech),
                  const SizedBox(height: 15),
                  _buildStatRow("LEVEL", "$level", Icons.trending_up),
                  const SizedBox(height: 15),
                  _buildStatRow("EXP", "$exp / 100", Icons.stars),
                  const SizedBox(height: 15),
                  _buildStatRow("GOLD", "$gold", Icons.attach_money),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout, color: Colors.black),
              label: const Text('SYSTEM LOGOUT', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}