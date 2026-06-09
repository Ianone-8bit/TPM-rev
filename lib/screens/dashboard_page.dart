import 'package:flutter/material.dart';

import 'dart:async';
import '../../services/auth_service.dart';
import '../../services/hunter_service.dart';
import '../../services/daily_reset_service.dart';
import '../../services/mission_db_service.dart';
import '../../services/notification_service.dart';
import '../../services/weekly_reset_service.dart';
import '../services/ai_service.dart';
import 'currency_converter_pager.dart';
import 'timezone_converter_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {
  Map<String, dynamic>? hunter;
  Timer? timer;
  Duration timeUntilReset =  Duration.zero;
  Duration timeUntilWeeklyReset = Duration.zero;

  bool weeklyResetExecuted = false;
  bool dailyResetExecuted = false;

  final TextEditingController goldController =
    TextEditingController();

final TextEditingController timeController =
    TextEditingController();

  double rupiahResult = 0;
  double usdResult = 0;

  int hunterMinutes = 0;
  String realWorldTime = "";

  @override
  void initState() {
    super.initState();
    loadHunter();
    updateResetTime();

    timer = Timer.periodic(
  const Duration(seconds: 1),
  (_) async {
    await updateResetTime();
    await updateWeeklyResetTime();
      }
    );
  }

    @override
    void dispose(){
      timer?.cancel();
      super.dispose();
    }

Future<void> updateWeeklyResetTime() async {
  final now = DateTime.now();

  int daysUntilSunday =
      7 - now.weekday;

  if (daysUntilSunday == 0) {
    daysUntilSunday = 7;
  }

  final nextSunday = DateTime(
    now.year,
    now.month,
    now.day + daysUntilSunday,
  );

  final difference =
      nextSunday.difference(now);

  if (mounted) {
    setState(() {
      timeUntilWeeklyReset =
          difference;
    });
  }

  if (difference.inSeconds <= 0 &&
      !weeklyResetExecuted) {
    weeklyResetExecuted = true;

    await MissionDbService.instance
        .resetWeeklyMissions();

    await NotificationService.instance
        .showNotification(
      title: "Weekly Quest Reset",
      body:
          "New weekly missions are available!",
    );
  }

  if (difference.inSeconds > 0) {
    weeklyResetExecuted = false;
  }
}

Future<void> updateResetTime() async {
  final now = DateTime.now();

  final tomorrow = DateTime(
    now.year,
    now.month,
    now.day + 1,
  );

  final difference =
      tomorrow.difference(now);

  if (mounted) {
    setState(() {
      timeUntilReset = difference;
    });
  }

  if (difference.inSeconds <= 0 &&
      !dailyResetExecuted) {
    dailyResetExecuted = true;

    await MissionDbService.instance
        .resetDailyMissions();

    await NotificationService.instance
        .showNotification(
      title: "Daily Quest Reset",
      body:
          "Hunter, new daily missions are available!",
    );
  }

  if (difference.inSeconds > 0) {
    dailyResetExecuted = false;
  }
}
  Future<void> loadHunter() async {
    String username =
        await AuthService.instance
            .currentUser();

    final data =
        await HunterService.instance
            .getHunter(username);

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

  void convertGold() {
  double gold =
      double.tryParse(
            goldController.text,
          ) ??
          0;

  setState(() {
    rupiahResult = gold * 1000;
    usdResult = rupiahResult / 16000;
  });
}

void convertHunterTime() {
  int minutes =
      int.tryParse(
            timeController.text,
          ) ??
          0;

  final duration =
      Duration(minutes: minutes);

  setState(() {
    realWorldTime =
        "${duration.inHours} jam "
        "${duration.inMinutes % 60} menit";
  });
}

  @override
  Widget build(BuildContext context) {
    if (hunter == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    int level = hunter!['level'];
    int exp = hunter!['exp'];
    int gold = hunter!['gold'];
    String rank = getRank(level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
              ]
            ),
            child: Column(
              children: [
                Text(hunter!['username'].toString().toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                const SizedBox(height: 5),
                Text("RANK $rank HUNTER", style: const TextStyle(fontSize: 16, color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn("LEVEL", "$level"),
                    _buildStatColumn("EXP", "$exp/100"),
                    _buildStatColumn("GOLD", "$gold"),
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: exp / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTimerCard("DAILY RESET", "${timeUntilReset.inHours.toString().padLeft(2, '0')}:${(timeUntilReset.inMinutes % 60).toString().padLeft(2, '0')}:${(timeUntilReset.inSeconds % 60).toString().padLeft(2, '0')}")),
              const SizedBox(width: 15),
              Expanded(child: _buildTimerCard("WEEKLY RESET", "${timeUntilWeeklyReset.inDays}d ${(timeUntilWeeklyReset.inHours % 24).toString().padLeft(2, '0')}h")),
            ],
          ),
          const SizedBox(height: 20),
          const Text("SYSTEM TOOLS", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.psychology, color: Colors.black),
            label: const Text("AI HUNTER ADVISOR", style: TextStyle(color: Colors.black)),
            onPressed: _showAiAdvice,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.currency_exchange, color: Colors.black),
            label: const Text("CURRENCY CONVERTER", style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyConverterPage())),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.schedule, color: Colors.black),
            label: const Text("TIME ZONE CONVERTER", style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeConverterPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimerCard(String title, String time) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(time, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _showAiAdvice() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
    );
    int level = hunter!['level'];
    int exp = hunter!['exp'];
    int gold = hunter!['gold'];
    String rank = getRank(level);
    final advice = await AiService.instance.getHunterAdvice(level: level, exp: exp, gold: gold, rank: rank);
    if (!mounted) return;
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("HUNTER ANALYSIS", style: TextStyle(color: Color(0xFF00E5FF))),
          content: SingleChildScrollView(child: Text(advice, style: const TextStyle(color: Colors.white))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ACKNOWLEDGE", style: TextStyle(color: Color(0xFF00E5FF))),
            )
          ],
        );
      },
    );
  }
}