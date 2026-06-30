import 'package:flutter/material.dart';

import 'dart:async';
import '../services/auth_service.dart';
import '../services/hunter_service.dart';
import '../services/mission_db_service.dart';
import '../services/notification_service.dart';
import '../services/ai_service.dart';
import 'currency_converter_pager.dart';
import 'timezone_converter_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? hunter;
  Timer? timer;
  Duration timeUntilReset = Duration.zero;
  Duration timeUntilWeeklyReset = Duration.zero;

  bool weeklyResetExecuted = false;
  bool dailyResetExecuted = false;

  @override
  void initState() {
    super.initState();
    loadHunter();
    updateResetTime();

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await updateResetTime();
      await updateWeeklyResetTime();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> updateWeeklyResetTime() async {
    final now = DateTime.now();
    int daysUntilSunday = 7 - now.weekday;
    if (daysUntilSunday == 0) daysUntilSunday = 7;

    final nextSunday = DateTime(now.year, now.month, now.day + daysUntilSunday);
    final difference = nextSunday.difference(now);

    if (mounted) {
      setState(() => timeUntilWeeklyReset = difference);
    }

    if (difference.inSeconds <= 0 && !weeklyResetExecuted) {
      weeklyResetExecuted = true;
      await MissionDbService.instance.resetWeeklyMissions();
      await NotificationService.instance.showNotification(
        title: "Goals Mingguan Baru!",
        body: "Goals minggu ini sudah direset. Semangat! 💪",
      );
    }
    if (difference.inSeconds > 0) weeklyResetExecuted = false;
  }

  Future<void> updateResetTime() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);

    if (mounted) {
      setState(() => timeUntilReset = difference);
    }

    if (difference.inSeconds <= 0 && !dailyResetExecuted) {
      dailyResetExecuted = true;
      await MissionDbService.instance.resetDailyMissions();
      await NotificationService.instance.showNotification(
        title: "Hari Baru, Semangat Baru! 🌅",
        body: "Kebiasaan harian sudah direset. Yuk mulai!",
      );
    }
    if (difference.inSeconds > 0) dailyResetExecuted = false;
  }

  Future<void> loadHunter() async {
    String username = await AuthService.instance.currentUser();
    final data = await HunterService.instance.getHunter(username);
    setState(() => hunter = data);
  }

  String getBadge(int level) {
    if (level >= 50) return '🏆 Legend';
    if (level >= 40) return '⭐ Master';
    if (level >= 30) return '💎 Expert';
    if (level >= 20) return '🥈 Intermediate';
    if (level >= 10) return '🥉 Learner';
    return '🌱 Beginner';
  }

  Color getBadgeColor(int level) {
    if (level >= 50) return const Color(0xFFFFD700);
    if (level >= 40) return const Color(0xFF7C3AED);
    if (level >= 30) return const Color(0xFF06B6D4);
    if (level >= 20) return const Color(0xFF10B981);
    if (level >= 10) return const Color(0xFFD97706);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    if (hunter == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
      );
    }

    int level = hunter!['level'];
    int exp = hunter!['exp'];
    int gold = hunter!['gold'];
    String badge = getBadge(level);
    Color badgeColor = getBadgeColor(level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),

          // ── Profile Card ──
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C3AED).withOpacity(0.35),
                  const Color(0xFF10B981).withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF7C3AED).withOpacity(0.3),
                  child: Text(
                    hunter!['username'].toString()[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hunter!['username'].toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                        color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn("Level", "$level", Icons.trending_up_rounded),
                    _buildStatColumn("Points", "$exp/100", Icons.stars_rounded),
                    _buildStatColumn("Coins", "$gold", Icons.monetization_on_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress ke level berikutnya',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        ),
                        Text(
                          '$exp / 100',
                          style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: exp / 100,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Timer Cards ──
          Row(
            children: [
              Expanded(
                child: _buildTimerCard(
                  "Reset Harian",
                  "${timeUntilReset.inHours.toString().padLeft(2, '0')}:${(timeUntilReset.inMinutes % 60).toString().padLeft(2, '0')}:${(timeUntilReset.inSeconds % 60).toString().padLeft(2, '0')}",
                  Icons.wb_sunny_outlined,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimerCard(
                  "Reset Mingguan",
                  "${timeUntilWeeklyReset.inDays}h ${(timeUntilWeeklyReset.inHours % 24).toString().padLeft(2, '0')}j",
                  Icons.calendar_today_outlined,
                  const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Tools section ──
          Row(
            children: [
              const Icon(Icons.build_outlined, color: Color(0xFF7C3AED), size: 18),
              const SizedBox(width: 8),
              const Text(
                "Tools",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildToolButton(
            icon: Icons.psychology_outlined,
            label: "AI Growth Advisor",
            subtitle: "Dapatkan saran pengembangan diri",
            color: const Color(0xFF7C3AED),
            onPressed: _showAiAdvice,
          ),
          const SizedBox(height: 10),
          _buildToolButton(
            icon: Icons.currency_exchange_outlined,
            label: "Konversi Mata Uang",
            subtitle: "Konversi Gold ke IDR / USD / JPY",
            color: const Color(0xFF10B981),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrencyConverterPage()),
            ),
          ),
          const SizedBox(height: 10),
          _buildToolButton(
            icon: Icons.schedule_outlined,
            label: "Konversi Zona Waktu",
            subtitle: "Cek waktu di berbagai kota dunia",
            color: const Color(0xFF06B6D4),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimeConverterPage()),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF7C3AED), size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ],
    );
  }

  Widget _buildTimerCard(String title, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.55), fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(time,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Future<void> _showAiAdvice() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF7C3AED)),
              SizedBox(height: 16),
              Text("Menganalisis perkembanganmu...",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );

    int level = hunter!['level'];
    int exp = hunter!['exp'];
    int gold = hunter!['gold'];
    String badge = getBadge(level);

    final advice = await AiService.instance.getHunterAdvice(
      level: level,
      exp: exp,
      gold: gold,
      rank: badge,
    );

    if (!mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_outlined,
                    color: Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Growth Analysis",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(advice, style: const TextStyle(color: Colors.white70, height: 1.5)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Mengerti"),
            ),
          ],
        );
      },
    );
  }
}