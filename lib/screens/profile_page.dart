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
    setState(() => hunter = data);
  }

  String getBadge(int level) {
    if (level >= 50) return 'Legend';
    if (level >= 40) return 'Master';
    if (level >= 30) return 'Expert';
    if (level >= 20) return 'Intermediate';
    if (level >= 10) return 'Learner';
    return 'Beginner';
  }

  String getBadgeEmoji(int level) {
    if (level >= 50) return '🏆';
    if (level >= 40) return '⭐';
    if (level >= 30) return '💎';
    if (level >= 20) return '🥈';
    if (level >= 10) return '🥉';
    return '🌱';
  }

  Color getBadgeColor(int level) {
    if (level >= 50) return const Color(0xFFFFD700);
    if (level >= 40) return const Color(0xFF7C3AED);
    if (level >= 30) return const Color(0xFF06B6D4);
    if (level >= 20) return const Color(0xFF10B981);
    if (level >= 10) return const Color(0xFFD97706);
    return const Color(0xFF6B7280);
  }

  String getMotivation(int level) {
    if (level >= 50) return 'Kamu sudah mencapai puncak! Inspirasi orang lain.';
    if (level >= 40) return 'Luar biasa! Tinggal selangkah lagi ke Legend.';
    if (level >= 30) return 'Kamu sudah expert! Terus pertahankan konsistensimu.';
    if (level >= 20) return 'Bagus sekali! Kamu sudah di jalur yang tepat.';
    if (level >= 10) return 'Progresmu terlihat! Terus lakukan kebiasaan baikmu.';
    return 'Setiap langkah kecil itu berarti. Tetap semangat! 💪';
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Keluar?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Kamu yakin ingin keluar dari akun ini?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
    }

    int level = hunter!['level'];
    int exp = hunter!['exp'];
    int gold = hunter!['gold'];
    String badge = getBadge(level);
    String emoji = getBadgeEmoji(level);
    Color badgeColor = getBadgeColor(level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // ── Avatar + Name ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C3AED).withOpacity(0.3),
                  const Color(0xFF10B981).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF10B981)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          hunter!['username'].toString()[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F0F1A), width: 2),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  hunter!['username'].toString(),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    '$emoji $badge',
                    style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  getMotivation(level),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                      height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Progress Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        color: Color(0xFF7C3AED), size: 20),
                    SizedBox(width: 8),
                    Text("Statistik Saya",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatRow("Level", "$level", Icons.trending_up_rounded,
                    const Color(0xFF7C3AED)),
                const Divider(color: Colors.white12, height: 24),
                _buildStatRow("Badge", badge, Icons.emoji_events_outlined,
                    badgeColor),
                const Divider(color: Colors.white12, height: 24),
                _buildStatRow("Points", "$exp / 100", Icons.stars_rounded,
                    const Color(0xFF7C3AED)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: exp / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                  ),
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildStatRow("Coins", "$gold", Icons.monetization_on_rounded,
                    const Color(0xFF10B981)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Logout ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text("Sign Out",
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade800),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 15)),
          ],
        ),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}